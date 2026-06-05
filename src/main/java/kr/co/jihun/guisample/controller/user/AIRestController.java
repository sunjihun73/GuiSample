package kr.co.jihun.guisample.controller.user;

import kr.co.jihun.guisample.dto.EmbeddingResponse;
import kr.co.jihun.guisample.service.AIService;
import kr.co.jihun.guisample.service.EmbeddingService;
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
    private final EmbeddingService embeddingService;

    /**
     * RAG 답변 스트리밍(SSE). 전체 경로: POST /user/rag/docs
     * 각 답변 토큰을 text/event-stream 의 data 이벤트로 전송한다.
     *
     * @param body { "query": "질문" }
     * @return 답변 토큰 스트림
     */
    @PostMapping(value = "/docs", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> getDocs(@RequestBody Map<String, Object> body)
    {
        Object query = body == null ? null : body.get("query");
        return aiService.getDocs(query == null ? null : query.toString());
    }

    /**
     * 텍스트 파일 인덱싱. 전체 경로: POST /user/rag/embedding
     * 업로드 파일을 청킹·임베딩하여 pgvector(vector_store)에 적재한다.
     *
     * @param file   업로드된 plain text(UTF-8) 파일 (필수)
     * @param source 메타데이터에 저장할 출처 식별자 (필수)
     * @return 적재 결과 EmbeddingResponse (성공/실패 모두 HTTP 200 JSON)
     */
    @PostMapping(value = "/embedding",
                 consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
                 produces = MediaType.APPLICATION_JSON_VALUE)
    public EmbeddingResponse embedding(@RequestParam("file") MultipartFile file,
                                       @RequestParam("source") String source)
    {
        return embeddingService.ingest(file, source);
    }
}
