package kr.co.jihun.guisample.advisor;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.ChatClientRequest;
import org.springframework.ai.chat.client.ChatClientResponse;
import org.springframework.ai.chat.client.advisor.api.CallAdvisor;
import org.springframework.ai.chat.client.advisor.api.CallAdvisorChain;
import org.springframework.ai.chat.client.advisor.api.StreamAdvisor;
import org.springframework.ai.chat.client.advisor.api.StreamAdvisorChain;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.model.Generation;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.scheduler.Schedulers;

import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Kanana SafeGuard 모델 기반 입력 가드레일 어드바이저.
 *
 * <p>Spring AI 기본 {@code SafeGuardAdvisor} 는 민감어 substring 매칭만 수행해 모델을 사용할 수 없으므로,
 * 동일한 {@link CallAdvisor}/{@link StreamAdvisor} 구조를 따르되 <b>Kanana SafeGuard 모델</b>
 * (OpenAI 호환 API)로 사용자 질문을 분류하는 커스텀 어드바이저로 구현한다.
 *
 * <p>동작:
 * <ul>
 *   <li>사용자 질문을 Kanana 가드 {@link ChatClient} 로 분류한다.</li>
 *   <li>응답 라벨에 {@code "unsafe"} 가 포함되면 실제 모델 호출을 <b>단락(short-circuit)</b>하고
 *       거부 메시지를 반환한다({@code chain.next...} 미호출 → gpt-4o-mini 미호출).</li>
 *   <li>{@code "safe"} 등 그 외에는 {@code chain.nextCall/nextStream} 으로 정상 진행한다.</li>
 * </ul>
 *
 * <p>정책:
 * <ul>
 *   <li><b>Fail-open</b>: 가드 모델 호출 실패/미응답(예: LAN 서버 다운)은 로그만 남기고 질문을 통과시킨다.
 *       (가용성 우선 — 가드 장애가 RAG 챗봇 전체를 멈추지 않도록)</li>
 *   <li>라벨 판정은 {@code "safe"} 가 {@code "unsafe"} 의 부분문자열이므로 <b>unsafe 를 먼저</b> 확인한다.</li>
 *   <li>스트리밍 경로의 블로킹 분류 호출은 {@link Schedulers#boundedElastic()} 로 오프로딩한다.</li>
 * </ul>
 */
@Slf4j
public class KananaSafeGuardAdvisor implements CallAdvisor, StreamAdvisor
{
    /** Kanana SafeGuard 모델을 호출하는 전용 ChatClient (OpenAI 호환, gpt-4o-mini RAG ChatClient 와 분리). */
    private final ChatClient guardChatClient;

    /** 가드레일 활성화 여부. false 면 분류 없이 항상 통과. */
    private final boolean enabled;

    /** 가드 모델에 전달할 시스템 프롬프트(선택). 공백이면 시스템 메시지를 전송하지 않는다. */
    private final String systemPrompt;

    /** unsafe 판정 시 사용자에게 반환할 거부 메시지. */
    private final String failureResponse;

    /** 어드바이저 실행 순서(작을수록 먼저). 가드는 실제 답변 생성보다 앞서야 한다. */
    private final int order;

    public KananaSafeGuardAdvisor(ChatClient guardChatClient, boolean enabled,
                                  String systemPrompt, String failureResponse, int order)
    {
        this.guardChatClient  = guardChatClient;
        this.enabled          = enabled;
        this.systemPrompt     = systemPrompt;
        this.failureResponse  = failureResponse;
        this.order            = order;
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
    // 동기(.call()) 경로 — 분류 후 unsafe 면 단락, 아니면 다음 어드바이저로 진행
    // ------------------------------------------------------------------
    @Override
    public ChatClientResponse adviseCall(ChatClientRequest request, CallAdvisorChain chain)
    {
        if (isUnsafe(request))
        {
            return createFailureResponse(request);
        }
        return chain.nextCall(request);
    }

    // ------------------------------------------------------------------
    // 스트리밍(.stream()) 경로 — 블로킹 분류를 boundedElastic 로 오프로딩 후 분기
    // ------------------------------------------------------------------
    @Override
    public Flux<ChatClientResponse> adviseStream(ChatClientRequest request, StreamAdvisorChain chain)
    {
        return Mono.fromCallable(() -> isUnsafe(request))
                .subscribeOn(Schedulers.boundedElastic())
                .flatMapMany(unsafe -> unsafe
                        ? Flux.just(createFailureResponse(request))
                        : chain.nextStream(request));
    }

    /**
     * 사용자 질문을 Kanana SafeGuard 모델로 분류한다.
     * 라벨에 {@code "unsafe"} 가 포함되면 true. 비활성/질문 공백/호출 실패는 false(통과, fail-open).
     */
    private boolean isUnsafe(ChatClientRequest request)
    {
        if (!enabled)
        {
            return false;
        }
        try
        {
            UserMessage userMessage = request.prompt().getUserMessage();
            String userText = userMessage == null ? null : userMessage.getText();
            if (userText == null || userText.isBlank())
            {
                return false;
            }

            ChatClient.ChatClientRequestSpec spec = guardChatClient.prompt();
            if (systemPrompt != null && !systemPrompt.isBlank())
            {
                spec = spec.system(systemPrompt);
            }
            String verdict = spec.user(userText).call().content();

            // 'safe' 는 'unsafe' 의 부분문자열이므로 unsafe 를 먼저 확인한다.
            String normalized = verdict == null ? "" : verdict.toLowerCase(Locale.ROOT);
            boolean unsafe = normalized.contains("unsafe");
            if (unsafe)
            {
                log.info("[Kanana 가드레일] 차단 — verdict='{}'", verdict.strip());
            }
            return unsafe;
        }
        catch (Exception e)
        {
            // 가드 모델 장애는 RAG 흐름을 막지 않는다(fail-open).
            log.warn("[Kanana 가드레일] 분류 실패 — fail-open(질문 통과)", e);
            return false;
        }
    }

    /** unsafe 단락 시, 거부 메시지를 담은 ChatClientResponse 생성(기본 SafeGuardAdvisor 와 동일 형태). */
    private ChatClientResponse createFailureResponse(ChatClientRequest request)
    {
        return ChatClientResponse.builder()
                .chatResponse(ChatResponse.builder()
                        .generations(List.of(new Generation(new AssistantMessage(failureResponse))))
                        .build())
                .context(Map.copyOf(request.context()))
                .build();
    }
}
