<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>프로젝트목록 — 업무관리 시스템</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">

    <!-- jQuery UI (jqGrid 테마) -->
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.min.css">
    <!-- free-jqGrid CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/free-jqgrid/4.15.5/css/ui.jqgrid.min.css">

    <style>
        /* ── Apple-style search form ─────────────────────────────── */
        .search-form {
            display: flex;
            gap: var(--sp-md);
            align-items: center;
            margin-bottom: var(--sp-lg);
            padding: var(--sp-lg);
            background: var(--canvas);
            border: 1px solid var(--hairline);
            border-radius: var(--rounded-lg);
        }
        .search-form__label {
            font-family: var(--font-text);
            font-size: 14px;
            font-weight: 600;
            letter-spacing: -0.224px;
            color: var(--ink);
        }
        .search-form__input {
            flex: 0 0 280px;
            height: 44px;
            padding: 0 20px;
            font-family: var(--font-text);
            font-size: 17px;
            line-height: 1.47;
            letter-spacing: -0.374px;
            color: var(--ink);
            background: var(--canvas);
            border: 1px solid var(--hairline);
            border-radius: var(--rounded-pill);
            outline: none;
            transition: border-color 0.12s, box-shadow 0.12s;
        }
        .search-form__input::placeholder { color: var(--ink-muted-48); }
        .search-form__input:focus {
            border-color: var(--primary-focus);
            box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.15);
        }
        .search-form__btn {
            height: 44px;
            padding: 0 22px;
            font-family: var(--font-text);
            font-size: 17px;
            font-weight: 400;
            line-height: 1;
            letter-spacing: -0.374px;
            color: #fff;
            background: var(--primary);
            border: none;
            border-radius: var(--rounded-pill);
            cursor: pointer;
            transition: background-color 0.12s, transform 0.08s ease-out;
        }
        .search-form__btn:hover  { background: var(--primary-focus); }
        .search-form__btn:active { transform: scale(0.95); }

        /* ── jqGrid 컨테이너 (Apple-style card) ──────────────────── */
        .grid-wrap {
            background: var(--canvas);
            border: 1px solid var(--hairline);
            border-radius: var(--rounded-lg);
            overflow: hidden;
        }

        /* common.css의 * { margin:0; padding:0; box-sizing:border-box } 영향 격리 */
        .grid-wrap .ui-jqgrid,
        .grid-wrap .ui-jqgrid * { box-sizing: content-box; }

        /* ── jqGrid 외곽 ─────────────────────────────────────────── */
        .grid-wrap .ui-jqgrid {
            font-family: var(--font-text) !important;
            background: var(--canvas) !important;
            color: var(--ink) !important;
            border: none !important;
            border-radius: 0 !important;
        }
        .grid-wrap .ui-jqgrid .ui-jqgrid-view {
            background: var(--canvas) !important;
            border: none !important;
        }
        .grid-wrap .ui-jqgrid .ui-widget-content,
        .grid-wrap .ui-jqgrid .ui-widget-header,
        .grid-wrap .ui-jqgrid .ui-state-default {
            background-image: none !important;
            border-color: transparent !important;
        }

        /* ── 타이틀바 (caption) ──────────────────────────────────── */
        .grid-wrap .ui-jqgrid .ui-jqgrid-titlebar {
            padding: var(--sp-md) var(--sp-lg) !important;
            background: var(--canvas) !important;
            border: none !important;
            border-bottom: 1px solid var(--divider-soft) !important;
            border-radius: 0 !important;
            color: var(--ink) !important;
            font-family: var(--font-display) !important;
            font-size: 14px !important;
            font-weight: 600 !important;
            line-height: 1.29 !important;
            letter-spacing: -0.224px !important;
            text-transform: uppercase;
        }
        .grid-wrap .ui-jqgrid .ui-jqgrid-titlebar-close { display: none !important; }

        /* ── 컬럼 헤더 ───────────────────────────────────────────── */
        .grid-wrap .ui-jqgrid .ui-jqgrid-hdiv {
            background: var(--canvas-parchment) !important;
            border: none !important;
            border-bottom: 1px solid var(--hairline) !important;
        }
        .grid-wrap .ui-jqgrid .ui-jqgrid-htable { border: none !important; }
        .grid-wrap .ui-jqgrid .ui-jqgrid-htable th,
        .grid-wrap .ui-jqgrid .ui-jqgrid-htable .ui-th-column {
            background: var(--canvas-parchment) !important;
            border: none !important;
            border-right: 1px solid var(--hairline) !important;
            padding: 14px 16px !important;
            font-family: var(--font-text) !important;
            font-size: 14px !important;
            font-weight: 600 !important;
            line-height: 1.29 !important;
            letter-spacing: -0.224px !important;
            color: var(--ink) !important;
            text-align: left;
        }
        .grid-wrap .ui-jqgrid .ui-jqgrid-htable th:last-child { border-right: none !important; }
        .grid-wrap .ui-jqgrid .ui-jqgrid-htable .ui-jqgrid-sortable { color: var(--ink) !important; }
        .grid-wrap .ui-jqgrid .s-ico { margin-left: 6px !important; }
        .grid-wrap .ui-jqgrid .ui-icon { color: var(--ink-muted-48) !important; }

        /* ── 데이터 행 ───────────────────────────────────────────── */
        .grid-wrap .ui-jqgrid .ui-jqgrid-bdiv  { background: var(--canvas) !important; }
        .grid-wrap .ui-jqgrid .ui-jqgrid-btable { border: none !important; }
        .grid-wrap .ui-jqgrid .jqgrow td,
        .grid-wrap .ui-jqgrid .ui-row-ltr td {
            padding: 14px 16px !important;
            border: none !important;
            border-bottom: 1px solid var(--divider-soft) !important;
            background: var(--canvas) !important;
            font-family: var(--font-text) !important;
            font-size: 14px !important;
            font-weight: 400 !important;
            line-height: 1.43 !important;
            letter-spacing: -0.224px !important;
            color: var(--ink) !important;
            height: auto !important;
        }
        .grid-wrap .ui-jqgrid .jqgrow:hover td,
        .grid-wrap .ui-jqgrid .ui-row-ltr:hover td {
            background: var(--canvas-parchment) !important;
        }
        .grid-wrap .ui-jqgrid tr.ui-state-highlight td,
        .grid-wrap .ui-jqgrid .ui-state-highlight {
            background: #e8f0fb !important;
            color: var(--ink) !important;
            border-color: transparent !important;
        }
        .grid-wrap .ui-jqgrid .jqgrid-emptyrecords {
            padding: 32px 16px !important;
            text-align: center !important;
            color: var(--ink-muted-48) !important;
            font-size: 14px !important;
        }

        /* ── 페이저 ──────────────────────────────────────────────── */
        .grid-wrap .ui-jqgrid-pager {
            background: var(--canvas) !important;
            border: none !important;
            border-top: 1px solid var(--hairline) !important;
            padding: 10px var(--sp-lg) !important;
            color: var(--ink-muted-80) !important;
            font-family: var(--font-text) !important;
            font-size: 12px !important;
            letter-spacing: -0.12px !important;
            height: auto !important;
            border-radius: 0 !important;
        }
        .grid-wrap .ui-pager-control { padding: 0 !important; }
        .grid-wrap .ui-jqgrid-pager .ui-pg-button {
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            border: 1px solid var(--hairline) !important;
            background: var(--canvas) !important;
            border-radius: var(--rounded-sm) !important;
            margin: 0 3px !important;
            padding: 4px 8px !important;
            color: var(--ink-muted-80) !important;
            cursor: pointer !important;
            transition: background 0.12s, color 0.12s, transform 0.08s ease-out !important;
        }
        .grid-wrap .ui-jqgrid-pager .ui-pg-button:hover {
            background: var(--canvas-parchment) !important;
            color: var(--ink) !important;
        }
        .grid-wrap .ui-jqgrid-pager .ui-pg-button:active { transform: scale(0.95) !important; }
        .grid-wrap .ui-jqgrid-pager .ui-state-disabled,
        .grid-wrap .ui-jqgrid-pager .ui-pg-button.ui-state-disabled {
            border-color: var(--divider-soft) !important;
            color: #c0c0c0 !important;
            cursor: default !important;
            background: var(--canvas) !important;
        }
        .grid-wrap .ui-jqgrid-pager .ui-pg-input,
        .grid-wrap .ui-jqgrid-pager .ui-pg-selbox {
            height: 28px !important;
            padding: 0 10px !important;
            font-family: var(--font-text) !important;
            font-size: 12px !important;
            color: var(--ink) !important;
            background: var(--canvas) !important;
            border: 1px solid var(--hairline) !important;
            border-radius: var(--rounded-sm) !important;
            outline: none !important;
        }
        .grid-wrap .ui-jqgrid-pager .ui-pg-input:focus,
        .grid-wrap .ui-jqgrid-pager .ui-pg-selbox:focus {
            border-color: var(--primary-focus) !important;
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
                <svg viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 3L5 8L10 13" stroke="currentColor" stroke-width="1.5"
                          stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </button>
        </div>

        <p class="sidebar__section-label">메뉴</p>

        <ul class="nav-menu">
            <li class="nav-menu__item">
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
            <li class="nav-menu__item active">
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
            <h1 class="page-header__title">프로젝트 목록</h1>
        </header>

        <!-- 조회 조건 -->
        <form id="searchForm" class="search-form" onsubmit="return false;">
            <label for="searchProjectName" class="search-form__label">프로젝트명</label>
            <input type="text" id="searchProjectName" name="projectName"
                   class="search-form__input" placeholder="프로젝트명을 입력하세요">
            <button type="button" id="btnSearch" class="search-form__btn">조회</button>
        </form>

        <!-- jqGrid -->
        <div class="grid-wrap">
            <table id="projectGrid"></table>
            <div id="projectGridPager"></div>
        </div>

    </main>
</div>

<!-- jQuery / jqGrid -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/free-jqgrid/4.15.5/jquery.jqgrid.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/free-jqgrid/4.15.5/i18n/grid.locale-kr.min.js"></script>

<script>
    (function () {
        var sidebar   = document.getElementById('sidebar');
        var toggleBtn = document.getElementById('toggleBtn');
        var STORAGE_KEY = 'sidebar_collapsed';

        if (sessionStorage.getItem(STORAGE_KEY) === 'true') {
            sidebar.classList.add('collapsed');
        }

        toggleBtn.addEventListener('click', function () {
            var isCollapsed = sidebar.classList.toggle('collapsed');
            sessionStorage.setItem(STORAGE_KEY, isCollapsed);
        });
    })();

    $(function () {
        var listUrl = '${pageContext.request.contextPath}/user/projects/list.json';

        $("#projectGrid").jqGrid({
            url:       listUrl,
            datatype:  "json",
            mtype:     "GET",
            colNames:  ["프로젝트 ID", "프로젝트명", "담당자", "생성일", "생성자", "수정일", "수정자"],
            colModel: [
                { name: "projectId",        index: "projectId",        width: 120, align: "center" },
                { name: "projectName",      index: "projectName",      width: 240 },
                { name: "projectOwnerName", index: "projectOwnerName", width: 120, align: "center" },
                { name: "createDate",       index: "createDate",       width: 140, align: "center" },
                { name: "createUserId",     index: "createUserId",     width: 100, align: "center" },
                { name: "updateDate",       index: "updateDate",       width: 140, align: "center" },
                { name: "updateUserId",     index: "updateUserId",     width: 100, align: "center" }
            ],
            jsonReader: {
                root:        "rows",
                page:        "page",
                total:       "total",
                records:     "records",
                repeatitems: false,
                id:          "projectId"
            },
            pager:        "#projectGridPager",
            rowNum:       10,
            rowList:      [10, 20, 50, 100],
            sortname:     "createDate",
            sortorder:    "desc",
            viewrecords:  true,
            autowidth:    true,
            height:       "auto",
            caption:      "프로젝트",
            emptyrecords: "조회된 데이터가 없습니다.",
            loadError: function (xhr, status, error) {
                alert("목록 조회 중 오류가 발생했습니다.\n" + status + " : " + error);
            }
        });

        function reloadGrid() {
            $("#projectGrid").jqGrid("setGridParam", {
                postData: { projectName: $("#searchProjectName").val() },
                page:     1
            }).trigger("reloadGrid");
        }

        $("#btnSearch").on("click", reloadGrid);

        $("#searchProjectName").on("keydown", function (e) {
            if (e.key === "Enter") {
                e.preventDefault();
                reloadGrid();
            }
        });
    });
</script>

</body>
</html>