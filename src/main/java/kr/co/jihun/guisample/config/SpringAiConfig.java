package kr.co.jihun.guisample.config;

import kr.co.jihun.guisample.advisor.KananaSafeGuardAdvisor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.ai.openai.OpenAiChatOptions;
import org.springframework.ai.openai.api.OpenAiApi;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.Ordered;

/**
 * Spring AI ChatClient 구성.
 * spring-ai-starter-model-openai 가 자동 구성한 {@link ChatClient.Builder}(OpenAI gpt-4o-mini)
 * 로부터 애플리케이션 전역에서 재사용할 RAG ChatClient 빈을 만든다.
 *
 * <p>추가로 <b>Kanana SafeGuard</b> 가드레일을 위해, OpenAI 호환 API 로 서비스되는 Kanana 모델을
 * 가리키는 별도 ChatClient 와 {@link KananaSafeGuardAdvisor} 빈을 구성한다.
 */
@Configuration
public class SpringAiConfig
{
    /**
     * RAG 답변 생성용 기본 ChatClient (OpenAI gpt-4o-mini). 타입 중복(가드용 ChatClient)이 있으므로
     * {@link Primary} 로 지정해 일반적인 ChatClient 주입 시 이 빈이 선택되도록 한다.
     */
    @Bean
    @Primary
    public ChatClient chatClient(ChatClient.Builder builder)
    {
        return builder.build();
    }

    /**
     * Kanana SafeGuard 모델 전용 ChatClient.
     * <p>OpenAI 호환 엔드포인트(예: {@code http://192.168.35.59:1234})를 별도 {@link OpenAiApi} 로 구성해
     * gpt-4o-mini RAG ChatClient 와 분리한다(가드 어드바이저 재귀 호출 방지 + 모델/주소 독립 설정).
     * temperature 0 으로 판정 일관성을 높인다.
     */
    @Bean
    public ChatClient kananaGuardChatClient(
            @Value("${guardrail.kanana.base-url:http://192.168.35.59:1234}") String baseUrl,
            @Value("${guardrail.kanana.api-key:not-needed}") String apiKey,
            @Value("${guardrail.kanana.model:kanana-safeguard}") String model,
            @Value("${guardrail.kanana.completions-path:/v1/chat/completions}") String completionsPath)
    {
        OpenAiApi api = OpenAiApi.builder()
                .baseUrl(baseUrl)
                .apiKey(apiKey)                     // OpenAI 호환 로컬 서버는 키 미검증 — 더미 값 허용
                .completionsPath(completionsPath)
                .build();

        OpenAiChatModel chatModel = OpenAiChatModel.builder()
                .openAiApi(api)
                .defaultOptions(OpenAiChatOptions.builder()
                        .model(model)
                        .temperature(0.0)
                        .build())
                .build();

        return ChatClient.create(chatModel);
    }

    /**
     * Kanana 기반 입력 가드레일 어드바이저 빈.
     * order 는 최고 우선순위로 두어 실제 답변 생성 어드바이저보다 먼저 실행되게 한다.
     */
    @Bean
    public KananaSafeGuardAdvisor kananaSafeGuardAdvisor(
            @Qualifier("kananaGuardChatClient") ChatClient kananaGuardChatClient,
            @Value("${guardrail.kanana.enabled:true}") boolean enabled,
            @Value("${guardrail.kanana.system-prompt:}") String systemPrompt,
            @Value("${guardrail.kanana.failure-response:죄송합니다. 요청하신 내용은 안전 정책에 따라 답변할 수 없습니다.}") String failureResponse)
    {
        return new KananaSafeGuardAdvisor(
                kananaGuardChatClient, enabled, systemPrompt, failureResponse, Ordered.HIGHEST_PRECEDENCE);
    }
}
