<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>대시보드 — 업무관리 시스템</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
</head>
<body>

<!-- ── Top Bar ── -->
<header class="topbar">
    <a href="/" class="topbar__brand">업무관리 시스템</a>
</header>

<div class="app-shell">

    <!-- ── Sidebar ── -->
    <aside class="sidebar" id="sidebar">

        <!-- 토글 버튼 -->
        <div class="sidebar__toggle">
            <button class="toggle-btn" id="toggleBtn" aria-label="메뉴 접기/펼치기" title="메뉴 접기/펼치기">
                <!-- 왼쪽 화살표 (펼쳐진 상태) → 접히면 CSS로 180도 회전 -->
                <svg viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 3L5 8L10 13" stroke="currentColor" stroke-width="1.5"
                          stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </button>
        </div>

        <p class="sidebar__section-label">메뉴</p>

        <ul class="nav-menu">
            <li class="nav-menu__item active">
                <a href="/user/dashboard">
                    <svg class="nav-icon" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                        <rect x="1" y="1" width="6" height="6" rx="1.5"/>
                        <rect x="9" y="1" width="6" height="6" rx="1.5"/>
                        <rect x="1" y="9" width="6" height="6" rx="1.5"/>
                        <rect x="9" y="9" width="6" height="6" rx="1.5"/>
                    </svg>
                    <span class="nav-label">대시보드</span>
                </a>
                <span class="tooltip">대시보드</span>
            </li>
            <li class="nav-menu__item">
                <a href="/user/projects">
                    <svg class="nav-icon" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd" clip-rule="evenodd"
                              d="M2 2.5A1.5 1.5 0 0 1 3.5 1h5.586a1 1 0 0 1 .707.293l3.414 3.414A1 1 0 0 1 13.5 5.5V13.5A1.5 1.5 0 0 1 12 15H3.5A1.5 1.5 0 0 1 2 13.5v-11ZM3.5 2a.5.5 0 0 0-.5.5v11a.5.5 0 0 0 .5.5H12a.5.5 0 0 0 .5-.5V6H9.5A1.5 1.5 0 0 1 8 4.5V2H3.5Zm5 .207V4.5a.5.5 0 0 0 .5.5h2.293L8.5 2.207Z"/>
                    </svg>
                    <span class="nav-label">프로젝트</span>
                </a>
                <span class="tooltip">프로젝트</span>
            </li>
        </ul>
    </aside>

    <!-- ── Main Content ── -->
    <main class="main-content">

        <header class="page-header">
            <h1 class="page-header__title">대시보드</h1>
        </header>

        <div class="stat-grid">
            <div class="stat-card">
                <p class="stat-card__label">전체 프로젝트</p>
                <p class="stat-card__value">12</p>
                <p class="stat-card__delta up">+2 이번 달</p>
            </div>
            <div class="stat-card">
                <p class="stat-card__label">진행 중</p>
                <p class="stat-card__value">5</p>
                <p class="stat-card__delta">변동 없음</p>
            </div>
            <div class="stat-card">
                <p class="stat-card__label">완료</p>
                <p class="stat-card__value">7</p>
                <p class="stat-card__delta up">+1 이번 주</p>
            </div>
            <div class="stat-card">
                <p class="stat-card__label">팀원</p>
                <p class="stat-card__value">24</p>
                <p class="stat-card__delta up">+3 신규</p>
            </div>
        </div>

        <h2 class="section-title">최근 활동</h2>
        <div class="activity-list">
            <div class="activity-item">
                <span class="activity-item__dot"></span>
                <span class="activity-item__text">프로젝트 <strong>Alpha</strong> 가 완료되었습니다.</span>
                <span class="activity-item__time">방금 전</span>
            </div>
            <div class="activity-item">
                <span class="activity-item__dot"></span>
                <span class="activity-item__text">새 프로젝트 <strong>Beta</strong> 가 생성되었습니다.</span>
                <span class="activity-item__time">1시간 전</span>
            </div>
            <div class="activity-item">
                <span class="activity-item__dot"></span>
                <span class="activity-item__text">팀원 <strong>김철수</strong> 님이 합류했습니다.</span>
                <span class="activity-item__time">3시간 전</span>
            </div>
            <div class="activity-item">
                <span class="activity-item__dot"></span>
                <span class="activity-item__text">프로젝트 <strong>Gamma</strong> 마일스톤 달성.</span>
                <span class="activity-item__time">어제</span>
            </div>
        </div>

    </main>
</div>

<script>
    (function () {
        var sidebar   = document.getElementById('sidebar');
        var toggleBtn = document.getElementById('toggleBtn');
        var STORAGE_KEY = 'sidebar_collapsed';

        /* 저장된 상태 복원 */
        if (sessionStorage.getItem(STORAGE_KEY) === 'true') {
            sidebar.classList.add('collapsed');
        }

        toggleBtn.addEventListener('click', function () {
            var isCollapsed = sidebar.classList.toggle('collapsed');
            sessionStorage.setItem(STORAGE_KEY, isCollapsed);
        });
    })();
</script>

</body>
</html>
