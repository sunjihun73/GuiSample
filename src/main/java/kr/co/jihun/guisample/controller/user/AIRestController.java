package kr.co.jihun.guisample.controller.user;

import kr.co.jihun.guisample.service.AIService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
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
}
