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
        /* 그리드 셀 padding 축소 → row 높이 감소 */
        #projectGrid.ui-jqgrid-btable td {
            padding-top: 2px;
            padding-bottom: 2px;
        }

        /* 수정 불가 projectId 필드: 회색 배경 + 편집 불가 표시 */
        #popupProjectId[readonly] {
            background: var(--divider-soft, #f0f0f0);
            color: #888;
            cursor: not-allowed;
        }

        /* "상세" 버튼 컴팩트 스타일 (기본 .search-form__btn 의 height:44px 를 덮어씀) */
        .btn-detail {
            height: 22px;
            padding: 0 8px;
            font-size: 12px;
            line-height: 1;
            border-radius: 4px;
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
                              d="M1 4a2 2 0 0 1 2-2h3.172a2 2 0 0 1 1.414.586l.828.828A1 1 0 0 0 9.121 4H13a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V4Zm2-.5a.5.5 0 0 0-.5.5v8a.5.5 0 0 0 .5.5h10a.5.5 0 0 0 .5-.5V6a.5.5 0 0 0-.5-.5H9.121a2 2 0 0 1-1.414-.586l-.828-.828A.5.5 0 0 0 6.172 3.5H3Z"/>
                    </svg>
                    <span class="nav-label">프로젝트</span>
                </a>
                <span class="tooltip">프로젝트</span>
            </li>
            <li class="nav-menu__item">
                <a href="/user/rag">
                    <svg class="nav-icon" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd" clip-rule="evenodd"
                              d="M3 2.5A1.5 1.5 0 0 0 1.5 4v6A1.5 1.5 0 0 0 3 11.5h1.5v2.19a.5.5 0 0 0 .82.385L8.68 11.5H13A1.5 1.5 0 0 0 14.5 10V4A1.5 1.5 0 0 0 13 2.5H3ZM3 4h10v6H8.5a.5.5 0 0 0-.32.115L6 11.94V11a1 1 0 0 0-1-1H3V4Z"/>
                        <circle cx="5.5" cy="7" r="0.9"/>
                        <circle cx="8" cy="7" r="0.9"/>
                        <circle cx="10.5" cy="7" r="0.9"/>
                    </svg>
                    <span class="nav-label">RAG</span>
                </a>
                <span class="tooltip">RAG</span>
            </li>
            <li class="nav-menu__item">
                <a href="/user/embedding">
                    <svg class="nav-icon" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                        <path d="M3.6 3.9 12.4 3.9M3.6 3.9 7.7 12.1M12.4 3.9 7.7 12.1"
                              stroke="currentColor" stroke-width="1.1" fill="none"/>
                        <circle cx="3.6" cy="3.9" r="1.9"/>
                        <circle cx="12.4" cy="3.9" r="1.9"/>
                        <circle cx="7.7" cy="12.1" r="1.9"/>
                    </svg>
                    <span class="nav-label">Embedding</span>
                </a>
                <span class="tooltip">Embedding</span>
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
            <div class="form-field" id="popupProjectIdField" style="display:none;">
                <label for="popupProjectId" class="form-field__label">프로젝트 ID</label>
                <input type="text" id="popupProjectId" class="form-field__input"
                       readonly tabindex="-1">
            </div>
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

        // "상세" 버튼 렌더링 (rowId 는 projectId)
        function detailButtonFormatter(cellValue, options) {
            return '<button type="button" class="search-form__btn btn-detail" data-id="'
                + options.rowId + '">상세</button>';
        }

        $("#projectGrid").jqGrid({
            url:       listUrl,
            datatype:  "json",
            mtype:     "GET",
            colNames:  ["프로젝트 ID", "상세", "프로젝트명", "담당자", "생성일", "생성자", "수정일", "수정자"],
            colModel: [
                { name: "projectId",        index: "projectId",        width: 120, align: "center", hidden : true },
                { name: "detail",           width: 70,  align: "center", sortable: false, search: false, formatter: detailButtonFormatter },
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

        /* ── 프로젝트 등록/수정 레이어 팝업 ── */
        var saveUrl   = '${pageContext.request.contextPath}/user/project/projects';
        var $popup    = $("#projectPopup");
        var popupMode = "create";   // "create" | "edit"

        function openCreatePopup() {
            popupMode = "create";
            $("#projectPopupTitle").text("프로젝트 등록");
            $("#popupProjectIdField").hide();
            $("#popupProjectId").val("");
            $("#popupProjectName").val("");
            $("#popupProjectOwnerName").val("");
            $popup.addClass("is-open").attr("aria-hidden", "false");
            $("#popupProjectName").trigger("focus");
        }

        function openEditPopup(rowData) {
            popupMode = "edit";
            $("#projectPopupTitle").text("프로젝트 수정");
            $("#popupProjectIdField").show();
            $("#popupProjectId").val(rowData.projectId);
            $("#popupProjectName").val(rowData.projectName);
            $("#popupProjectOwnerName").val(rowData.projectOwnerName);
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

            var ajaxUrl, ajaxType;
            if (popupMode === "edit") {
                ajaxUrl  = saveUrl + "/" + encodeURIComponent($("#popupProjectId").val());
                ajaxType = "PATCH";
            } else {
                ajaxUrl  = saveUrl;
                ajaxType = "POST";
            }

            $("#btnPopupSave").prop("disabled", true);

            $.ajax({
                url:         ajaxUrl,
                type:        ajaxType,
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

        // "상세" 버튼 클릭 → 선택 row 데이터로 수정 팝업 오픈
        $("#projectGrid").on("click", ".btn-detail", function () {
            var rowId   = $(this).data("id");
            var rowData = $("#projectGrid").jqGrid("getRowData", rowId);
            openEditPopup(rowData);
        });

        $("#btnCreate").on("click", openCreatePopup);
        $("#btnPopupCancel").on("click", closePopup);
        $("#projectPopupDim").on("click", closePopup);
        $("#btnPopupSave").on("click", saveProject);
    });
</script>

</body>
</html>