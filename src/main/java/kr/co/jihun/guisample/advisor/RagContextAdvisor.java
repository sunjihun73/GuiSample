package kr.co.jihun.guisample.advisor;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClientRequest;
import org.springframework.ai.chat.client.ChatClientResponse;
import org.springframework.ai.chat.client.advisor.api.CallAdvisor;
import org.springframework.ai.chat.client.advisor.api.CallAdvisorChain;
import org.springframework.ai.chat.client.advisor.api.StreamAdvisor;
import org.springframework.ai.chat.client.advisor.api.StreamAdvisorChain;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.vectorstore.filter.Filter;
import org.springframework.ai.vectorstore.filter.FilterExpressionBuilder;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.util.List;
import java.util.stream.Collectors;

/**
 * RAG 컨텍스트 주입 어드바이저.
 *
 * <p>사용자 질문으로 pgvector {@link VectorStore} 유사도 검색을 수행하고, 검색된 문서 본문을
 * 시스템 프롬프트의 {@code <context>} 블록에 주입한 뒤 다음 어드바이저/모델로 전달한다.
 * 기존에 {@code AIService} 가 어드바이저 체인 <b>밖에서</b> 직접 하던 벡터 검색을 체인 <b>안으로</b>
 * 옮겨, 실행 순서 계약을 order 값으로 보장한다.
 *
 * <p><b>순서 계약:</b> 이 어드바이저의 order 는 {@link KananaSafeGuardAdvisor}
 * ({@link org.springframework.core.Ordered#HIGHEST_PRECEDENCE}) 보다 <b>뒤</b>
 * ({@code HIGHEST_PRECEDENCE + 100}) 여야 한다. 즉 <b>가드레일을 통과한 질문에 대해서만</b>
 * 벡터 검색이 실행된다. unsafe 질문은 가드가 체인을 단락하므로 검색 비용이 발생하지 않는다.
 *
 * <p>동작:
 * <ul>
 *   <li>request 의 마지막 user 메시지 텍스트로 {@link VectorStore#similaritySearch(SearchRequest)} 실행.</li>
 *   <li>{@code category_id} 필터: 요청 컨텍스트({@code request.context().get("category_id")})에 값이 있으면
 *       {@link FilterExpressionBuilder#eq} 로 메타데이터 필터를 적용, 없으면 전체 검색.</li>
 *   <li>문서 본문을 {@code "\n\n---\n\n"} 로 join(없으면 {@link #NO_CONTEXT}) 하여 시스템 프롬프트에 주입.</li>
 *   <li>주입은 {@link String#replace(CharSequence, CharSequence)} 리터럴 치환으로 수행 —
 *       문서 본문에 중괄호가 있어도 템플릿으로 재파싱되지 않아 안전하다.</li>
 * </ul>
 *
 * <p><b>user 메시지는 원문 그대로 유지</b>한다(가드가 본 질문과 동일). 시스템 메시지만 증강한다.
 * 스트리밍 경로의 블로킹 벡터 검색은 {@link Schedulers#boundedElastic()} 로 오프로딩한다.
 */
@Slf4j
public class RagContextAdvisor implements CallAdvisor, StreamAdvisor
{
    /** 검색된 컨텍스트가 없을 때 시스템 프롬프트에 주입할 안내 문구. */
    private static final String NO_CONTEXT = "(관련 문서가 없습니다.)";

    /** 여러 문서 본문을 하나의 컨텍스트로 이어붙일 때 사용하는 구분자. */
    private static final String CONTEXT_SEPARATOR = "\n\n---\n\n";

    /** 컨텍스트가 주입될 시스템 프롬프트 내 자리표시자. */
    private static final String CONTEXT_PLACEHOLDER = "{context}";

    /**
     * 시스템 프롬프트. {@value #CONTEXT_PLACEHOLDER} 자리에 검색된 문서 본문이 리터럴 치환된다.
     * 리터럴 치환이므로 문서에 중괄호가 있어도 재파싱되지 않아 안전하다.
     */
    private static final String SYSTEM_PROMPT = """
            당신은 사내 문서 기반 도우미입니다.
            아래 <context></context> 안의 내용만 근거로 한국어로 간결하고 정확하게 답하세요.
            컨텍스트에 근거가 없으면 "제공된 문서에서 관련 내용을 찾지 못했습니다." 라고만 답하세요. 추측하지 마세요.
            <context>
            {context}
            </context>
            """;

    /** pgvector 유사도 검색을 수행할 VectorStore. */
    private final VectorStore vectorStore;

    /** 컨텍스트로 사용할 최대 문서 수(top-k). */
    private final int topK;

    /** 어드바이저 실행 순서(작을수록 먼저). 가드레일보다 뒤여야 한다(순서 계약 참조). */
    private final int order;

    public RagContextAdvisor(VectorStore vectorStore, int topK, int order)
    {
        this.vectorStore = vectorStore;
        this.topK        = topK;
        this.order       = order;
    }

    @Override
    public String getName()
    {
        return this.getClass().getSimpleName();
    }

    @Override
    public int getOrder()
    {
        return this.order;
    }

    // ------------------------------------------------------------------
    // 동기(.call()) 경로 — 벡터 검색 후 컨텍스트 주입한 요청으로 다음 어드바이저 진행
    // ------------------------------------------------------------------
    @Override
    public ChatClientResponse adviseCall(ChatClientRequest request, CallAdvisorChain chain)
    {
        return chain.nextCall(augmentWithContext(request));
    }

    // ------------------------------------------------------------------
    // 스트리밍(.stream()) 경로 — 블로킹 벡터 검색을 boundedElastic 로 오프로딩 후 진행
    // ------------------------------------------------------------------
    @Override
    public Flux<ChatClientResponse> adviseStream(ChatClientRequest request, StreamAdvisorChain chain)
    {
        return Mono.fromCallable(() -> augmentWithContext(request))
                .subscribeOn(Schedulers.boundedElastic())
                .flatMapMany(chain::nextStream);
    }

    /**
     * 요청의 user 질문으로 벡터 검색을 수행하고, 검색된 컨텍스트를 시스템 메시지에 주입한 새 요청을 만든다.
     * user 메시지는 변경하지 않으며 시스템 메시지만 증강한다. 질문이 공백이면 원 요청을 그대로 반환한다.
     */
    private ChatClientRequest augmentWithContext(ChatClientRequest request)
    {
        UserMessage userMessage = request.prompt().getUserMessage();
        String userText = userMessage == null ? null : userMessage.getText();
        if (userText == null || userText.isBlank())
        {
            return request;
        }

        String context = retrieveContext(userText, request.context().get("category_id"));
        String systemText = SYSTEM_PROMPT.replace(CONTEXT_PLACEHOLDER, context);

        // 시스템 메시지만 증강(기존 시스템 메시지가 없으면 새로 추가), user 메시지는 원문 유지.
        Prompt augmentedPrompt = request.prompt().augmentSystemMessage(systemText);
        return request.mutate().prompt(augmentedPrompt).build();
    }

    /**
     * 질문 텍스트로 pgvector 유사도 검색을 수행해 컨텍스트 문자열을 구성한다.
     *
     * @param query      검색 질의(원문 user 텍스트)
     * @param categoryId 요청 컨텍스트에서 읽은 category_id (null/공백이면 전체 검색)
     * @return 문서 본문을 join 한 컨텍스트(검색 결과가 없으면 {@link #NO_CONTEXT})
     */
    private String retrieveContext(String query, Object categoryId)
    {
        SearchRequest.Builder requestBuilder = SearchRequest.builder()
                .query(query)
                .topK(topK);

        if (categoryId != null && !categoryId.toString().isBlank())
        {
            // metadata->>'category_id' = ? 조건으로 변환되는 메타데이터 필터
            Filter.Expression filterExpression = new FilterExpressionBuilder()
                    .eq("category_id", categoryId.toString())
                    .build();
            requestBuilder.filterExpression(filterExpression);
        }

        List<Document> documents = vectorStore.similaritySearch(requestBuilder.build());

        if (documents == null || documents.isEmpty())
        {
            return NO_CONTEXT;
        }
        return documents.stream()
                .map(Document::getText)
                .collect(Collectors.joining(CONTEXT_SEPARATOR));
    }
}
