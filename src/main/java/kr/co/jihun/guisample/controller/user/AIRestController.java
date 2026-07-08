package kr.co.jihun.guisample.controller.user;

import kr.co.jihun.guisample.dto.ChatDetailDTO;
import kr.co.jihun.guisample.dto.ChatMasterDTO;
import kr.co.jihun.guisample.dto.EmbeddingResponse;
import kr.co.jihun.guisample.dto.MessageListResponse;
import kr.co.jihun.guisample.dto.MessageRow;
import kr.co.jihun.guisample.dto.SessionCreateResponse;
import kr.co.jihun.guisample.dto.SessionListResponse;
import kr.co.jihun.guisample.dto.SessionRow;
import kr.co.jihun.guisample.service.AIService;
import kr.co.jihun.guisample.service.ChatService;
import kr.co.jihun.guisample.service.KnowledgeFileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.metadata.ChatResponseMetadata;
import org.springframework.ai.chat.metadata.Usage;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;

/**
 * Spring AI 기반 RAG 기능 REST 엔드포인트.
 * <p>세션/대화 저장(chat_master/chat_detail) 엔드포인트를 함께 제공한다.
 */
@RestController
@RequestMapping("/user/rag")
@RequiredArgsConstructor
@Slf4j
public class AIRestController
{
    private final AIService aiService;
    private final ChatService chatService;
    private final KnowledgeFileService knowledgeFileService;

    // ------------------------------------------------------------------
    // A. 세션 목록
    // ------------------------------------------------------------------

    /**
     * 세션 목록 조회. 전체 경로: GET /user/rag/sessions
     *
     * @param page 페이지 번호(기본 1)
     * @param rows 페이지 크기(기본 100)
     * @return {@link SessionListResponse} (rows: sessionId/title/createDate, create_date DESC)
     */
    @GetMapping(value = "/sessions", produces = MediaType.APPLICATION_JSON_VALUE)
    public SessionListResponse sessions(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "100") int rows)
    {
        HashMap<String, Object> param = new HashMap<>();
        int totalRecords = chatService.countSessions(param);
        int totalPages   = totalRecords == 0 ? 0 : (int) Math.ceil((double) totalRecords / rows);

        // 페이징 사용 시 startRow/pageSize 를 반드시 함께 세팅 (mapper LIMIT/OFFSET 가드 대응)
        param.put("startRow", (page - 1) * rows);
        param.put("pageSize", rows);

        List<ChatMasterDTO> list = chatService.selectSessions(param);
        List<SessionRow> sessionRows = list.stream()
                .map(m -> SessionRow.builder()
                        .sessionId(m.getChatSessionId())
                        .title(m.getChatTitleName())
                        .createDate(m.getCreateDate())
                        .build())
                .collect(Collectors.toList());

        return SessionListResponse.builder()
                .page(page)
                .total(totalPages)
                .records(totalRecords)
                .rows(sessionRows)
                .build();
    }

    // ------------------------------------------------------------------
    // B. 세션 생성
    // ------------------------------------------------------------------

    /**
     * 새 세션 생성. 전체 경로: POST /user/rag/sessions
     *
     * @param body { "title": "새로운채팅"(선택) } — 없거나 공백이면 서버가 "새로운채팅" 기본값
     * @return {@link SessionCreateResponse}
     */
    @PostMapping(value = "/sessions", produces = MediaType.APPLICATION_JSON_VALUE)
    public SessionCreateResponse createSession(@RequestBody(required = false) Map<String, Object> body)
    {
        try
        {
            Object title = body == null ? null : body.get("title");
            ChatMasterDTO created = chatService.createSession(title == null ? null : title.toString());
            return SessionCreateResponse.builder()
                    .success(true)
                    .sessionId(created.getChatSessionId())
                    .title(created.getChatTitleName())
                    .build();
        }
        catch (Exception e)
        {
            log.error("세션 생성 실패", e);
            return SessionCreateResponse.builder()
                    .success(false)
                    .message(e.getMessage())
                    .build();
        }
    }

    // ------------------------------------------------------------------
    // C. 세션 대화 복원
    // ------------------------------------------------------------------

    /**
     * 세션 대화 복원. 전체 경로: GET /user/rag/sessions/{sessionId}/messages
     *
     * @param sessionId 조회할 세션 ID
     * @return {@link MessageListResponse} (rows: role/content/model?/promptTokens?/completionTokens?/createDate, chat_content_id ASC)
     */
    @GetMapping(value = "/sessions/{sessionId}/messages", produces = MediaType.APPLICATION_JSON_VALUE)
    public MessageListResponse messages(@PathVariable String sessionId)
    {
        List<ChatDetailDTO> list = chatService.selectMessages(sessionId);
        List<MessageRow> messageRows = list.stream()
                .map(d -> MessageRow.builder()
                        .role(d.getRole())
                        .content(d.getChatContent())
                        .model(d.getModel())
                        .promptTokens(d.getPromptTokens())
                        .completionTokens(d.getCompletionTokens())
                        .createDate(d.getCreateDate())
                        .build())
                .collect(Collectors.toList());

        return MessageListResponse.builder()
                .sessionId(sessionId)
                .rows(messageRows)
                .build();
    }

    // ------------------------------------------------------------------
    // D. RAG 답변 스트리밍 + 대화 저장 (기존 확장)
    // ------------------------------------------------------------------

    /**
     * RAG 답변 스트리밍(SSE). 전체 경로: POST /user/rag/docs
     * 각 답변 토큰을 text/event-stream 의 data 이벤트로 전송한다(기존 동작 유지).
     * <p>{@code sessionId} 가 있으면: 스트림 시작 전 user 메시지 저장, 스트림 완료 후 assistant
     * 메시지(모델명/토큰) 저장. 블로킹 JDBC 저장은 {@link Schedulers#boundedElastic()} 로 오프로딩.
     * 저장 실패는 로그만 남기고 스트림은 정상 종료(사용자 경험 우선).
     *
     * @param body { "query": "질문", "categoryId": "카테고리 UUID(선택)", "sessionId": "세션 ID(선택)" }
     * @return 답변 토큰 스트림
     */
    @PostMapping(value = "/docs", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> getDocs(@RequestBody Map<String, Object> body)
    {
        String query      = str(body, "query");
        String categoryId = str(body, "categoryId");
        String sessionId  = str(body, "sessionId");

        if (query == null || query.isBlank())
        {
            return Flux.just("질문을 입력해 주세요.");
        }

        boolean hasSession = sessionId != null && !sessionId.isBlank();

        // 스트림 동안 서버가 답변 텍스트/메타데이터를 누적
        StringBuilder answer = new StringBuilder();
        AtomicReference<String>  model            = new AtomicReference<>(null);
        AtomicReference<Integer> promptTokens     = new AtomicReference<>(null);
        AtomicReference<Integer> completionTokens = new AtomicReference<>(null);

        Flux<String> textStream = aiService.streamChat(query, categoryId)
                .doOnNext(resp -> captureMetadata(resp.getMetadata(), model, promptTokens, completionTokens))
                .map(AIService::extractText)
                .filter(text -> !text.isEmpty())
                .doOnNext(answer::append);

        if (!hasSession)
        {
            // 방어적: sessionId 누락 시 저장 없이 답변만 스트리밍
            return textStream;
        }

        // user 저장(스트림 시작 전, 독립 트랜잭션) — 블로킹이므로 boundedElastic 오프로딩
        Mono<Void> saveUser = Mono.<Void>fromRunnable(() -> {
            try
            {
                chatService.saveUserMessage(sessionId, query);
            }
            catch (Exception e)
            {
                log.error("user 메시지 저장 실패 (sessionId={})", sessionId, e);
            }
        }).subscribeOn(Schedulers.boundedElastic());

        // assistant 저장 + 세션 제목 자동 변경(스트림 완료 후, 독립 트랜잭션) — 텍스트 스트림 뒤에 이어 붙임
        Flux<String> saveAssistantTail = Mono.<Void>fromRunnable(() -> {
            try
            {
                chatService.saveAssistantMessage(sessionId, answer.toString(),
                        model.get(), promptTokens.get(), completionTokens.get());
            }
            catch (Exception e)
            {
                log.error("assistant 메시지 저장 실패 (sessionId={})", sessionId, e);
            }
            // 첫 질문 기반 세션 제목 자동 변경(제목이 기본값일 때만 1회). 실패해도 스트림 영향 없음.
            autoRenameTitle(sessionId, query);
        }).subscribeOn(Schedulers.boundedElastic()).thenMany(Flux.<String>empty());

        return saveUser.thenMany(textStream).concatWith(saveAssistantTail);
    }

    /**
     * 세션 제목을 첫 질문 요약으로 자동 변경한다(제목이 기본값 "새로운채팅"일 때만 1회).
     * <p>불필요한 LLM 호출을 피하기 위해 선(先) 제목 확인 후 요약을 수행하고,
     * 실제 갱신은 트랜잭션 내에서 기본값을 재확인해 반영한다(레이스 안전).
     * 모든 실패는 로그만 남기고 스트림/응답에 영향을 주지 않는다.
     */
    private void autoRenameTitle(String sessionId, String query)
    {
        try
        {
            ChatMasterDTO session = chatService.selectSession(sessionId);
            if (session == null || !ChatService.DEFAULT_TITLE.equals(session.getChatTitleName()))
            {
                // 세션 없음 or 이미 수동 변경됨 → LLM 호출 없이 종료
                return;
            }
            String title = aiService.summarizeTitle(query);
            chatService.autoRenameTitleIfDefault(sessionId, title);
        }
        catch (Exception e)
        {
            log.error("세션 제목 자동 변경 실패 (sessionId={})", sessionId, e);
        }
    }

    /** 마지막 청크 등에서 model/usage 를 확보. 값이 있을 때만 덮어쓴다. */
    private static void captureMetadata(ChatResponseMetadata metadata,
                                        AtomicReference<String> model,
                                        AtomicReference<Integer> promptTokens,
                                        AtomicReference<Integer> completionTokens)
    {
        if (metadata == null)
        {
            return;
        }
        String m = metadata.getModel();
        if (m != null && !m.isBlank())
        {
            model.set(m);
        }
        Usage usage = metadata.getUsage();
        if (usage != null)
        {
            if (usage.getPromptTokens() != null)
            {
                promptTokens.set(usage.getPromptTokens());
            }
            if (usage.getCompletionTokens() != null)
            {
                completionTokens.set(usage.getCompletionTokens());
            }
        }
    }

    private static String str(Map<String, Object> body, String key)
    {
        Object v = body == null ? null : body.get(key);
        return v == null ? null : v.toString();
    }

    /**
     * 지식파일 업로드(인덱싱). 전체 경로: POST /user/rag/embedding
     * 업로드 파일을 청킹·임베딩하여 pgvector(vector_store)에 적재하고,
     * 원본 파일을 디스크에 저장한 뒤 knowledge_files 테이블에 메타 정보를 기록한다.
     *
     * @param file       업로드된 plain text(UTF-8) 파일 (필수)
     * @param categoryId 지식파일이 속한 카테고리 ID — metadata.source 및 knowledge_files.category_id (필수)
     * @return 적재 결과 EmbeddingResponse (성공/실패 모두 HTTP 200 JSON)
     */
    @PostMapping(value = "/embedding",
                 consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
                 produces = MediaType.APPLICATION_JSON_VALUE)
    public EmbeddingResponse embedding(@RequestParam("file") MultipartFile file,
                                       @RequestParam("categoryId") String categoryId)
    {
        return knowledgeFileService.upload(file, categoryId);
    }
}
