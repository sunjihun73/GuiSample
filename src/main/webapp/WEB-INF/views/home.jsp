<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    /* 로그아웃 직후 돌아오는 지점이기도 하므로 인증 여부에 따라 CTA 를 바꾼다. */
    boolean signedIn = request.getUserPrincipal() != null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>기술테스트 시스템</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
</head>
<body>

<!-- ── Top Bar ── -->
<header class="topbar">
    <a href="/" class="topbar__brand">기술테스트 시스템</a>
</header>

<main class="landing">
    <div class="landing__card">
        <h1 class="landing__title">기술테스트 시스템</h1>
        <% if (signedIn) { %>
            <p class="landing__desc">이미 로그인되어 있습니다.</p>
            <a class="landing__btn" href="${pageContext.request.contextPath}/user/dashboard">대시보드로 이동</a>
        <% } else { %>
            <p class="landing__desc">Keycloak 계정으로 로그인하세요.</p>
            <a class="landing__btn"
               href="${pageContext.request.contextPath}/oauth2/authorization/keycloak">로그인</a>
        <% } %>
    </div>
</main>

</body>
</html>
