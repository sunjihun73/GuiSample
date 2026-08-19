package kr.co.jihun.guisample.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import kr.co.jihun.guisample.service.UserMasterService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Keycloak 로그인 사용자를 user_master 에 자동 등록하는 필터.
 *
 * <p>동작 조건 — 인증된 OIDC 사용자이면서 이 세션에서 아직 등록 확인을 하지 않은 경우에만
 * {@code keycloak_id}({@code sub}) 로 조회하고, 없으면 등록한다.
 *
 * <p><b>실행 시점</b> — OAuth2 콜백({@code /login/oauth2/code/keycloak}) 요청은
 * {@code OAuth2LoginAuthenticationFilter} 가 리다이렉트로 끝내므로 이 필터까지 오지 않는다.
 * 따라서 실제 등록은 <b>로그인 직후 첫 인증 요청</b>(기본값 {@code /user/dashboard})에서 일어난다.
 *
 * <p><b>세션 가드</b> — 매 요청마다 DB 를 조회하지 않도록 세션에 확인 완료 표시를 남긴다.
 * 표시는 성공했을 때만 남기므로, DB 장애로 실패하면 다음 요청에서 자동으로 재시도된다.
 *
 * <p><b>실패 정책</b> — 등록 실패가 로그인 자체를 막지 않도록 예외를 삼키고 로그만 남긴다
 * (fail-open). 사용자 등록은 부가 작업이며, 여기서 예외를 던지면 화면 전체가 500 이 된다.
 *
 * <p>Spring Boot 가 {@code Filter} 타입 빈을 서블릿 컨테이너에 자동 등록해 이중 실행되는 것을
 * 막기 위해 이 클래스는 빈으로 만들지 않고 {@code SecurityConfig} 에서 직접 생성해 체인에 넣는다.
 */
@Slf4j
@RequiredArgsConstructor
public class KeycloakUserProvisioningFilter extends OncePerRequestFilter
{
    /** 이 세션에서 user_master 등록 확인을 마쳤는지 표시하는 세션 속성 키. */
    private static final String PROVISIONED_ATTR =
            KeycloakUserProvisioningFilter.class.getName() + ".PROVISIONED";

    private final UserMasterService userMasterService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException
    {
        OidcUser oidcUser = currentOidcUser();

        if (oidcUser != null)
        {
            /* 세션이 없으면 만들지 않는다(false) — 인증 상태면 로그인 시점에 이미 존재한다. */
            HttpSession session = request.getSession(false);

            if (session != null && session.getAttribute(PROVISIONED_ATTR) == null)
            {
                provision(oidcUser, session);
            }
        }

        filterChain.doFilter(request, response);
    }

    /** 등록을 시도하고, 성공적으로 끝나면 세션에 확인 완료 표시를 남긴다. */
    private void provision(OidcUser oidcUser, HttpSession session)
    {
        try
        {
            userMasterService.registerIfAbsent(oidcUser);
            session.setAttribute(PROVISIONED_ATTR, Boolean.TRUE);
        }
        catch (Exception e)
        {
            /* 표시를 남기지 않으므로 다음 요청에서 다시 시도된다. */
            log.error("user_master 사용자 자동 등록 실패 (keycloakId={})", oidcUser.getSubject(), e);
        }
    }

    /** 현재 인증 주체가 OIDC 사용자면 반환, 아니면(익명 포함) null. */
    private OidcUser currentOidcUser()
    {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated())
        {
            return null;
        }

        return (authentication.getPrincipal() instanceof OidcUser oidcUser) ? oidcUser : null;
    }
}
