package kr.co.jihun.guisample.config;

import kr.co.jihun.guisample.advisor.RagContextAdvisor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;

/**
 * Spring AI ChatClient 구성.
 * spring-ai-starter-model-openai 가 자동 구성한 {@link ChatClient.Builder}(OpenAI gpt-4o-mini)
 * 로부터 애플리케이션 전역에서 재사용할 RAG ChatClient 빈을 만든다.
 */
@Configuration
public class SpringAiConfig
{
    /** RAG 답변 생성용 ChatClient (OpenAI gpt-4o-mini). */
    @Bean
    public ChatClient chatClient(ChatClient.Builder builder)
    {
        return builder.build();
    }

    /**
     * RAG 컨텍스트 주입 어드바이저 빈.
     * <p>체인 내 유일한 어드바이저이므로 order 는 최고 우선순위 계열({@code HIGHEST_PRECEDENCE + 100})로 둔다.
     */
    @Bean
    public RagContextAdvisor ragContextAdvisor(VectorStore vectorStore)
    {
        return new RagContextAdvisor(vectorStore, 4, Ordered.HIGHEST_PRECEDENCE + 100);
    }
}
