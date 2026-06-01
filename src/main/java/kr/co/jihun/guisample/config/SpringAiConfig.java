package kr.co.jihun.guisample.config;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Spring AI ChatClient 구성.
 * spring-ai-starter-model-openai 가 자동 구성한 {@link ChatClient.Builder}(OpenAI gpt-4o-mini)
 * 로부터 애플리케이션 전역에서 재사용할 ChatClient 빈을 만든다.
 */
@Configuration
public class SpringAiConfig
{
    @Bean
    public ChatClient chatClient(ChatClient.Builder builder)
    {
        return builder.build();
    }
}
