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
            <li class="nav-menu__item">
                <a href="/user/rag">
                    <svg class="nav-icon" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="8" cy="1.75" r="1"/>
                        <path fill-rule="evenodd" clip-rule="evenodd"
                              d="M8 2.5a.6.6 0 0 1 .6.6V4h2.9A2.5 2.5 0 0 1 14 6.5v4A2.5 2.5 0 0 1 11.5 13h-7A2.5 2.5 0 0 1 2 10.5v-4A2.5 2.5 0 0 1 4.5 4h2.9v-.9A.6.6 0 0 1 8 2.5ZM4.5 5.5a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1h7a1 1 0 0 0 1-1v-4a1 1 0 0 0-1-1h-7Z"/>
                        <circle cx="6" cy="8.5" r="1"/>
                        <circle cx="10" cy="8.5" r="1"/>
                        <path d="M.75 7.5a.75.75 0 0 1 .75.75v1a.75.75 0 0 1-1.5 0v-1a.75.75 0 0 1 .75-.75Zm14.5 0a.75.75 0 0 1 .75.75v1a.75.75 0 0 1-1.5 0v-1a.75.75 0 0 1 .75-.75Z"/>
                    </svg>
                    <span class="nav-label">RAG</span>
                </a>
                <span class="tooltip">RAG</span>
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
            <div class="search-form__actions">
                <button type="button" id="btnSearch" class="search-form__btn">조회</button>
                <button type="button" id="btnCreate" class="search-form__btn">등록</button>
            </div>
        </form>

        <!-- jqGrid -->
        <div class="grid-wrap">
            <table id="projectGrid"></table>
            <div id="projectGridPager"></div>
        </div>

    </main>
</div>

<!-- ── 프로젝트 등록 레이어 팝업 ── -->
<div class="layer-popup" id="projectPopup" aria-hidden="true">
    <div class="layer-popup__dim" id="projectPopupDim"></div>
    <div class="layer-popup__panel" role="dialog" aria-modal="true" aria-labelledby="projectPopupTitle">
        <div class="layer-popup__header">
            <h2 class="layer-popup__title" id="projectPopupTitle">프로젝트 등록</h2>
        </div>
        <div class="layer-popup__body">
            <div class="form-field">
                <label for="popupProjectName" class="form-field__label">프로젝트명</label>
                <input type="text" id="popupProjectName" class="form-field__input"
                       placeholder="프로젝트명을 입력하세요" maxlength="200">
            </div>
            <div class="form-field">
                <label for="popupProjectOwnerName" class="form-field__label">담당자</label>
                <input type="text" id="popupProjectOwnerName" class="form-field__input"
                       placeholder="담당자를 입력하세요" maxlength="100">
            </div>
        </div>
        <div class="layer-popup__footer">
            <button type="button" id="btnPopupSave"   class="search-form__btn">저장</button>
            <button type="button" id="btnPopupCancel" class="search-form__btn search-form__btn--ghost">취소</button>
        </div>
    </div>
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
        var listUrl = '${pageContext.request.contextPath}/user/project/projects';

        // yyyy-mm-dd hh:mm:ss 형태로 변환 (DB 타임스탬프 문자열의 앞 19자리 사용)
        function dateTimeFormatter(cellValue) {
            if (!cellValue) {
                return "";
            }
            return String(cellValue).replace("T", " ").substring(0, 19);
        }

        $("#projectGrid").jqGrid({
            url:       listUrl,
            datatype:  "json",
            mtype:     "GET",
            colNames:  ["프로젝트 ID", "프로젝트명", "담당자", "생성일", "생성자", "수정일", "수정자"],
            colModel: [
                { name: "projectId",        index: "projectId",        width: 120, align: "center" },
                { name: "projectName",      index: "projectName",      width: 240 },
                { name: "projectOwnerName", index: "projectOwnerName", width: 120, align: "center" },
                { name: "createDate",       index: "createDate",       width: 160, align: "center", formatter: dateTimeFormatter },
                { name: "createUserId",     index: "createUserId",     width: 100, align: "center" },
                { name: "updateDate",       index: "updateDate",       width: 160, align: "center", formatter: dateTimeFormatter },
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
            rownumbers:   true,
            rownumWidth:  56,
            rowNum:       10,
            rowList:      [10, 20, 50, 100],
            sortname:     "createDate",
            sortorder:    "desc",
            viewrecords:  true,
            autowidth:    true,
            height:       "420",
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

        /* ── 프로젝트 등록 레이어 팝업 ── */
        var saveUrl   = '${pageContext.request.contextPath}/user/project/projects';
        var $popup    = $("#projectPopup");

        function openPopup() {
            $("#popupProjectName").val("");
            $("#popupProjectOwnerName").val("");
            $popup.addClass("is-open").attr("aria-hidden", "false");
            $("#popupProjectName").trigger("focus");
        }

        function closePopup() {
            $popup.removeClass("is-open").attr("aria-hidden", "true");
        }

        function saveProject() {
            var projectName      = $.trim($("#popupProjectName").val());
            var projectOwnerName = $.trim($("#popupProjectOwnerName").val());

            if (projectName === "") {
                alert("프로젝트명을 입력하세요.");
                $("#popupProjectName").trigger("focus");
                return;
            }
            if (projectOwnerName === "") {
                alert("담당자를 입력하세요.");
                $("#popupProjectOwnerName").trigger("focus");
                return;
            }

            $("#btnPopupSave").prop("disabled", true);

            $.ajax({
                url:         saveUrl,
                type:        "POST",
                contentType: "application/json",
                dataType:    "json",
                data:        JSON.stringify({
                    projectName:      projectName,
                    projectOwnerName: projectOwnerName
                })
            }).done(function (data) {
                if (data && data.success) {
                    closePopup();
                    $("#projectGrid").trigger("reloadGrid");
                } else {
                    alert("저장에 실패했습니다.\n" + ((data && data.message) || ""));
                }
            })
            .fail(function (xhr, status, error) {
                alert("저장 중 오류가 발생했습니다.\n" + status + " : " + error);
            })
            .always(function () {
                $("#btnPopupSave").prop("disabled", false);
            });
        }

        $("#btnCreate").on("click", openPopup);
        $("#btnPopupCancel").on("click", closePopup);
        $("#projectPopupDim").on("click", closePopup);
        $("#btnPopupSave").on("click", saveProject);
    });
</script>

</body>
</html>