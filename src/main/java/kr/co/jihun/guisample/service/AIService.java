package kr.co.jihun.guisample.service;

import lombok.RequiredArgsConstructor;
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
 * 답변 토큰을 스트리밍으로 반환한다.
 */
@Service
@RequiredArgsConstructor
public class AIService
{
    private final VectorStore vectorStore;
    private final ChatClient chatClient;

    /** 컨텍스트로 사용할 최대 문서 수 */
    private static final int TOP_K = 4;

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
     * 질의에 대한 RAG 답변을 토큰 단위로 스트리밍한다.
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
                .system(spec -> spec.text(SYSTEM_PROMPT).param("context", context))
                .user(query)
                .stream()
                .content();
    }
}
