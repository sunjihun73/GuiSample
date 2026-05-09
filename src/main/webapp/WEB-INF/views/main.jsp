<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>대시보드 — 업무관리 시스템</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --primary:          #0066cc;
            --primary-focus:    #0071e3;
            --ink:              #1d1d1f;
            --ink-muted-80:     #333333;
            --ink-muted-48:     #7a7a7a;
            --canvas:           #ffffff;
            --canvas-parchment: #f5f5f7;
            --hairline:         #e0e0e0;
            --divider-soft:     #f0f0f0;

            --rounded-sm:   8px;
            --rounded-md:   11px;
            --rounded-lg:   18px;
            --rounded-pill: 9999px;

            --sp-xxs: 4px;
            --sp-xs:  8px;
            --sp-sm:  12px;
            --sp-md:  17px;
            --sp-lg:  24px;
            --sp-xl:  32px;
            --sp-xxl: 48px;

            --font-display: "SF Pro Display", system-ui, -apple-system, sans-serif;
            --font-text:    "SF Pro Text",    system-ui, -apple-system, sans-serif;

            --sidebar-width:     240px;
            --sidebar-collapsed: 56px;
            --topbar-height:      52px;
            --sidebar-transition: width 0.22s cubic-bezier(0.4, 0, 0.2, 1);
        }

        body {
            font-family: var(--font-text);
            font-size: 17px;
            font-weight: 400;
            line-height: 1.47;
            letter-spacing: -0.374px;
            color: var(--ink);
            background: var(--canvas-parchment);
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        /* ── Top Bar ──────────────────────────────────────────── */
        .topbar {
            position: fixed;
            top: 0; left: 0; right: 0;
            z-index: 100;
            height: var(--topbar-height);
            background: var(--canvas);
            border-bottom: 1px solid var(--hairline);
            display: flex;
            align-items: center;
            padding: 0 var(--sp-lg);
        }

        .topbar__brand {
            font-family: var(--font-display);
            font-size: 21px;
            font-weight: 600;
            line-height: 1.19;
            letter-spacing: 0.231px;
            color: var(--ink);
            text-decoration: none;
        }

        /* ── App Shell ────────────────────────────────────────── */
        .app-shell {
            display: flex;
            margin-top: var(--topbar-height);
            height: calc(100vh - var(--topbar-height));
        }

        /* ── Sidebar ──────────────────────────────────────────── */
        .sidebar {
            width: var(--sidebar-width);
            flex-shrink: 0;
            background: var(--canvas);
            border-right: 1px solid var(--hairline);
            display: flex;
            flex-direction: column;
            overflow: hidden;               /* 텍스트가 삐져나오지 않게 */
            transition: var(--sidebar-transition);
        }

        .sidebar.collapsed {
            width: var(--sidebar-collapsed);
        }

        /* ── 토글 버튼 ────────────────────────────────────────── */
        .sidebar__toggle {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding: var(--sp-sm) var(--sp-sm) 0;
            flex-shrink: 0;
        }

        .sidebar.collapsed .sidebar__toggle {
            justify-content: center;
        }

        .toggle-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            border: 1px solid var(--hairline);
            border-radius: var(--rounded-sm);
            background: var(--canvas);
            cursor: pointer;
            color: var(--ink-muted-48);
            transition: background 0.12s, color 0.12s;
            flex-shrink: 0;
        }

        .toggle-btn:hover {
            background: var(--canvas-parchment);
            color: var(--ink);
        }

        .toggle-btn svg {
            width: 16px;
            height: 16px;
            transition: transform 0.22s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* 접혔을 때 화살표 방향 반전 */
        .sidebar.collapsed .toggle-btn svg {
            transform: rotate(180deg);
        }

        /* ── 섹션 레이블 ──────────────────────────────────────── */
        .sidebar__section-label {
            font-size: 12px;
            font-weight: 400;
            line-height: 1.0;
            letter-spacing: -0.12px;
            color: var(--ink-muted-48);
            text-transform: uppercase;
            padding: var(--sp-lg) var(--sp-lg) var(--sp-sm);
            white-space: nowrap;
            overflow: hidden;
            opacity: 1;
            transition: opacity 0.15s, padding 0.22s;
        }

        .sidebar.collapsed .sidebar__section-label {
            opacity: 0;
            padding-top: var(--sp-sm);
            padding-bottom: var(--sp-sm);
            pointer-events: none;
        }

        /* ── Nav Menu ─────────────────────────────────────────── */
        .nav-menu { list-style: none; }

        .nav-menu__item a {
            display: flex;
            align-items: center;
            gap: var(--sp-sm);
            padding: 9px var(--sp-lg);
            font-size: 14px;
            font-weight: 400;
            line-height: 1.29;
            letter-spacing: -0.224px;
            color: var(--ink-muted-80);
            text-decoration: none;
            border-radius: var(--rounded-md);
            margin: 1px var(--sp-sm);
            white-space: nowrap;
            transition: background 0.12s, padding 0.22s;
        }

        /* 접혔을 때 아이콘만 보이도록 패딩 중앙 정렬 */
        .sidebar.collapsed .nav-menu__item a {
            padding: 9px 0;
            margin: 1px var(--sp-xs);
            justify-content: center;
        }

        .nav-menu__item a:hover {
            background: var(--canvas-parchment);
            color: var(--ink);
        }

        .nav-menu__item.active a {
            background: #e8f0fb;
            color: var(--primary);
            font-weight: 600;
        }

        .nav-menu__item .nav-icon {
            width: 16px;
            height: 16px;
            flex-shrink: 0;
            opacity: 0.55;
        }

        .nav-menu__item.active .nav-icon,
        .nav-menu__item a:hover .nav-icon { opacity: 1; }

        .nav-menu__item.active .nav-icon { color: var(--primary); }

        /* 레이블 텍스트 fade */
        .nav-label {
            opacity: 1;
            max-width: 160px;
            overflow: hidden;
            transition: opacity 0.15s, max-width 0.22s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .sidebar.collapsed .nav-label {
            opacity: 0;
            max-width: 0;
        }

        /* ── Tooltip (접혔을 때 메뉴명 표시) ─────────────────── */
        .nav-menu__item {
            position: relative;
        }

        .nav-menu__item .tooltip {
            display: none;
            position: absolute;
            left: calc(var(--sidebar-collapsed) + 4px);
            top: 50%;
            transform: translateY(-50%);
            background: var(--ink);
            color: #fff;
            font-size: 12px;
            font-weight: 400;
            letter-spacing: -0.12px;
            padding: 4px 10px;
            border-radius: var(--rounded-sm);
            white-space: nowrap;
            pointer-events: none;
            z-index: 200;
        }

        .sidebar.collapsed .nav-menu__item:hover .tooltip {
            display: block;
        }

        /* ── Main Content ─────────────────────────────────────── */
        .main-content {
            flex: 1;
            background: var(--canvas-parchment);
            overflow-y: auto;
            padding: var(--sp-xxl);
        }

        .page-header { margin-bottom: var(--sp-xxl); }

        .page-header__eyebrow {
            font-size: 12px;
            font-weight: 400;
            letter-spacing: -0.12px;
            color: var(--ink-muted-48);
            margin-bottom: var(--sp-xxs);
        }

        .page-header__title {
            font-family: var(--font-display);
            font-size: 40px;
            font-weight: 600;
            line-height: 1.1;
            letter-spacing: -0.374px;
            color: var(--ink);
        }

        /* ── Stat Cards ───────────────────────────────────────── */
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: var(--sp-lg);
            margin-bottom: var(--sp-xxl);
        }

        .stat-card {
            background: var(--canvas);
            border: 1px solid var(--hairline);
            border-radius: var(--rounded-lg);
            padding: var(--sp-lg);
        }

        .stat-card__label {
            font-size: 14px;
            font-weight: 400;
            letter-spacing: -0.224px;
            color: var(--ink-muted-48);
            margin-bottom: var(--sp-xs);
        }

        .stat-card__value {
            font-family: var(--font-display);
            font-size: 34px;
            font-weight: 600;
            line-height: 1.47;
            letter-spacing: -0.374px;
            color: var(--ink);
        }

        .stat-card__delta {
            font-size: 12px;
            letter-spacing: -0.12px;
            color: var(--ink-muted-48);
            margin-top: 2px;
        }

        .stat-card__delta.up   { color: #34c759; }
        .stat-card__delta.down { color: #ff3b30; }

        /* ── Activity Section ─────────────────────────────────── */
        .section-title {
            font-family: var(--font-display);
            font-size: 21px;
            font-weight: 600;
            line-height: 1.19;
            letter-spacing: 0.231px;
            color: var(--ink);
            margin-bottom: var(--sp-lg);
        }

        .activity-list {
            background: var(--canvas);
            border: 1px solid var(--hairline);
            border-radius: var(--rounded-lg);
            overflow: hidden;
        }

        .activity-item {
            display: flex;
            align-items: center;
            gap: var(--sp-lg);
            padding: var(--sp-md) var(--sp-lg);
            border-bottom: 1px solid var(--divider-soft);
        }

        .activity-item:last-child { border-bottom: none; }

        .activity-item__dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--primary);
            flex-shrink: 0;
        }

        .activity-item__text {
            flex: 1;
            font-size: 17px;
            color: var(--ink);
        }

        .activity-item__time {
            font-size: 12px;
            letter-spacing: -0.12px;
            color: var(--ink-muted-48);
            white-space: nowrap;
        }
    </style>
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
                <a href="/main">
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
                <a href="/project">
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
            <p class="page-header__eyebrow">개요</p>
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
