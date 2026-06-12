package kr.co.jihun.guisample.controller.user;

import kr.co.jihun.guisample.dto.EmbeddingResponse;
import kr.co.jihun.guisample.service.AIService;
import kr.co.jihun.guisample.service.KnowledgeFileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;

import java.util.Map;

/**
 * Spring AI 기반 RAG 기능 REST 엔드포인트.
 */
@RestController
@RequestMapping("/user/rag")
@RequiredArgsConstructor
public class AIRestController
{
    private final AIService aiService;
    private final KnowledgeFileService knowledgeFileService;

    /**
     * RAG 답변 스트리밍(SSE). 전체 경로: POST /user/rag/docs
     * 각 답변 토큰을 text/event-stream 의 data 이벤트로 전송한다.
     *
     * @param body { "query": "질문", "categoryId": "카테고리 UUID(선택)" }
     *             categoryId 가 null/누락/공백이면 필터 없이 전체 벡터 검색.
     * @return 답변 토큰 스트림
     */
    @PostMapping(value = "/docs", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> getDocs(@RequestBody Map<String, Object> body)
    {
        Object query      = body == null ? null : body.get("query");
        Object categoryId = body == null ? null : body.get("categoryId");
        return aiService.getDocs(
                query == null ? null : query.toString(),
                categoryId == null ? null : categoryId.toString());
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
