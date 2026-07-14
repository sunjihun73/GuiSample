package kr.co.jihun.guisample.service;

import kr.co.jihun.guisample.advisor.KananaSafeGuardAdvisor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.vectorstore.filter.Filter;
import org.springframework.ai.vectorstore.filter.FilterExpressionBuilder;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Spring AI 기반 RAG 서비스.
 * pgvector VectorStore 로 유사 문서를 검색하고, 그 컨텍스트를 ChatClient(gpt-4o-mini)에 주입해
 * 답변을 스트리밍으로 반환한다.
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class AIService
{
    private final VectorStore vectorStore;
    private final ChatClient chatClient;
    /** Kanana SafeGuard 기반 입력 가드레일 — RAG 답변 생성 전 unsafe 질문을 차단한다. */
    private final KananaSafeGuardAdvisor kananaSafeGuardAdvisor;

    /** 컨텍스트로 사용할 최대 문서 수 */
    private static final int TOP_K = 4;

    /** 자동 제목 요약 프롬프트(순수 요약 — RAG 컨텍스트/어드바이저 미사용). */
    private static final String TITLE_PROMPT = """
            다음 질문을 15자 이내의 짧은 명사형 한국어 제목으로 요약하라. 따옴표·마침표 없이 제목만 출력하라.
            질문: %s
            """;

    /** 요약 제목 저장 상한(컬럼 varchar(200) 안전 절삭). */
    private static final int MAX_TITLE_LEN = 200;

    /** LLM 실패/빈 응답 fallback 시 질문 원문 절삭 길이. */
    private static final int FALLBACK_TITLE_LEN = 20;

    /**
     * 시스템 프롬프트. {context} 자리에는 검색된 문서 본문이 param 값으로 주입된다.
     * param 값은 템플릿으로 재파싱되지 않으므로 문서에 중괄호가 있어도 안전하다.
     */
    private static final String SYSTEM_PROMPT = """
            당신은 사내 문서 기반 도우미입니다.
            아래 <context></context> 안의 내용만 근거로 한국어로 간결하고 정확하게 답하세요.
            컨텍스트에 근거가 없으면 "제공된 문서에서 관련 내용을 찾지 못했습니다." 라고만 답하세요. 추측하지 마세요.
            <context>
            {context}
            </context>
            """;

    /**
     * 질의에 대한 RAG 답변을 토큰(텍스트) 단위로 스트리밍한다. (기존 시그니처 — 하위호환 유지)
     *
     * @param query      사용자가 입력한 질문
     * @param categoryId 검색을 한정할 카테고리 ID (null/공백이면 전체 벡터 검색)
     * @return 답변 토큰 스트림 (질의가 비면 안내 메시지 1건)
     */
    public Flux<String> getDocs(String query, String categoryId)
    {
        if (query == null || query.isBlank())
        {
            return Flux.just("질문을 입력해 주세요.");
        }
        return streamChat(query, categoryId)
                .map(AIService::extractText)
                .filter(text -> !text.isEmpty());
    }

    /**
     * 질의에 대한 RAG 답변을 {@link ChatResponse} 단위로 스트리밍한다.
     * 텍스트뿐 아니라 model/usage(토큰) 메타데이터를 확보할 수 있어 대화 저장 경로에서 사용한다.
     *
     * <p>동작:
     * <ol>
     *   <li>pgvector 유사도 검색(top-k=4, category_id 메타 필터) 으로 컨텍스트 구성.</li>
     *   <li>ChatClient 스트림을 {@code .chatResponse()} 로 소비 → Flux&lt;ChatResponse&gt;.</li>
     * </ol>
     * 각 청크에서 {@link #extractText(ChatResponse)} 로 델타 텍스트를, 마지막 청크의
     * {@code getMetadata()} 에서 model/usage 를 얻는다. 질의가 비면 {@link Flux#empty()}.
     *
     * @param query      사용자가 입력한 질문
     * @param categoryId 검색을 한정할 카테고리 ID (null/공백이면 전체 벡터 검색)
     * @return ChatResponse 스트림
     */
    public Flux<ChatResponse> streamChat(String query, String categoryId)
    {
        if (query == null || query.isBlank())
        {
            return Flux.empty();
        }

        SearchRequest.Builder requestBuilder = SearchRequest.builder()
                .query(query)
                .topK(TOP_K);

        if (categoryId != null && !categoryId.isBlank())
        {
            // metadata->>'category_id' = ? 조건으로 변환되는 메타데이터 필터
            Filter.Expression filterExpression = new FilterExpressionBuilder()
                    .eq("category_id", categoryId)
                    .build();
            requestBuilder.filterExpression(filterExpression);
        }

        SearchRequest request = requestBuilder.build();

        List<Document> documents = vectorStore.similaritySearch(request);

        String context = (documents == null || documents.isEmpty())
                ? "(관련 문서가 없습니다.)"
                : documents.stream()
                        .map(Document::getText)
                        .collect(Collectors.joining("\n\n---\n\n"));

        return chatClient.prompt()
                // 가드레일: Kanana SafeGuard 로 질문을 분류해 unsafe 면 gpt-4o-mini 호출을 단락하고 거부 응답을 반환
                .advisors(kananaSafeGuardAdvisor)
                .system(spec -> spec.text(SYSTEM_PROMPT).param("context", context))
                .user(query)
                .stream()
                .chatResponse();
    }

    /**
     * ChatResponse 청크에서 델타 텍스트를 안전하게 추출한다.
     * 마지막 usage-only 청크 등 result/output 이 null 인 경우 빈 문자열을 반환한다.
     */
    public static String extractText(ChatResponse response)
    {
        if (response == null || response.getResult() == null
                || response.getResult().getOutput() == null)
        {
            return "";
        }
        String text = response.getResult().getOutput().getText();
        return text == null ? "" : text;
    }

    /**
     * 사용자 질문을 짧은 한국어 세션 제목으로 요약한다.
     * <p>RAG 어드바이저/벡터 컨텍스트 없이 ChatClient 를 비스트리밍(.call())으로 1회 호출하는
     * 가벼운 요약이다. LLM 호출 실패/빈 응답 시 질문 앞 {@value #FALLBACK_TITLE_LEN}자 절삭으로 fallback.
     * 결과는 varchar(200) 안전을 위해 {@value #MAX_TITLE_LEN}자로 절삭한다.
     *
     * @param question 사용자 질문
     * @return 요약 제목(항상 non-blank, question 이 공백이면 빈 문자열)
     */
    public String summarizeTitle(String question)
    {
        if (question == null || question.isBlank())
        {
            return "";
        }

        String fallback = truncate(question.trim(), FALLBACK_TITLE_LEN);

        try
        {
            String result = chatClient.prompt()
                    .user(String.format(TITLE_PROMPT, question))
                    .call()
                    .content();

            String cleaned = cleanTitle(result);
            return cleaned.isBlank() ? fallback : truncate(cleaned, MAX_TITLE_LEN);
        }
        catch (Exception e)
        {
            log.warn("세션 제목 요약 실패 — 질문 원문 절삭으로 fallback", e);
            return fallback;
        }
    }

    /** 요약 결과에서 앞뒤 공백/따옴표/마침표를 제거한다. */
    private static String cleanTitle(String raw)
    {
        if (raw == null)
        {
            return "";
        }
        // 앞뒤 공백·큰/작은따옴표·마침표 제거, 내부 개행은 공백으로
        String s = raw.replace("\r", " ").replace("\n", " ").trim();
        s = s.replaceAll("^[\"'`.\\s]+", "").replaceAll("[\"'`.\\s]+$", "");
        return s.trim();
    }

    /** 문자 수 기준 절삭(말줄임 없이 원문 절삭). */
    private static String truncate(String s, int max)
    {
        if (s == null)
        {
            return "";
        }
        return s.length() <= max ? s : s.substring(0, max);
    }
}
