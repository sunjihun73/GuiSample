<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.springframework.web.util.HtmlUtils" %>
<%
    /* Keycloak preferred_username — 상단바 표시용. HTML 이스케이프 후 출력한다. */
    java.security.Principal principal = request.getUserPrincipal();
    String loginName = (principal != null) ? HtmlUtils.htmlEscape(principal.getName()) : "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>프로젝트목록 — 기술테스트 시스템</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">

    <%-- CSRF 토큰 — /js/csrf.js 가 읽어 모든 비-GET ajax 요청 헤더에 부착한다. --%>
    <meta name="_csrf" content="${_csrf.token}">
    <meta name="_csrf_header" content="${_csrf.headerName}">

    <!-- jQuery UI (jqGrid 테마) -->
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.min.css">
    <!-- free-jqGrid CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/free-jqgrid/4.15.5/css/ui.jqgrid.min.css">
</head>
<body>

<!-- ── Top Bar ── -->
<header class="topbar">
    <a href="/" class="topbar__brand">기술테스트 시스템</a>
    <div class="topbar__user">
        <span class="topbar__username"><%= loginName %></span>
        <form action="${pageContext.request.contextPath}/logout" method="post">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <button type="submit" class="topbar__logout">로그아웃</button>
        </form>
    </div>
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
                    <span class="nav-label">RAG 챗봇</span>
                </a>
                <span class="tooltip">RAG 챗봇</span>
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
            <p class="page-header__eyebrow">Projects</p>
            <h1 class="page-header__title">프로젝트 목록</h1>
            <p class="page-header__desc">등록된 프로젝트를 조회하고 관리합니다.</p>
        </header>

        <!-- 조회 조건 -->
        <form id="searchForm" class="search-form" onsubmit="return false;">
            <label for="searchProjectName" class="search-form__label">프로젝트명</label>
            <input type="text" id="searchProjectName" name="projectName"
                   class="search-form__input" placeholder="프로젝트명을 입력하세요">
            <div class="search-form__actions">
                <button type="button" id="btnSearch" class="search-form__btn search-form__btn--ghost">
                    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
                        <circle cx="7.2" cy="7.2" r="4.2" stroke="currentColor" stroke-width="1.5"/>
                        <path d="m10.4 10.4 3 3" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                    </svg>
                    조회
                </button>
                <button type="button" id="btnCreate" class="search-form__btn">
                    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
                        <path d="M8 3.5v9M3.5 8h9" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
                    </svg>
                    등록
                </button>
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
            <p class="layer-popup__desc" id="projectPopupDesc">프로젝트 정보를 입력한 뒤 저장하세요.</p>
            <button type="button" class="layer-popup__close" id="btnPopupClose" aria-label="닫기">
                <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
                    <path d="m4 4 8 8M12 4l-8 8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                </svg>
            </button>
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
            <div class="form-field">
                <label for="popupProjectDescription" class="form-field__label">프로젝트 설명</label>
                <textarea id="popupProjectDescription" name="popupProjectDescription"
                          placeholder="프로젝트 설명을 입력하세요"></textarea>
            </div>
        </div>
        <div class="layer-popup__footer">
            <button type="button" id="btnPopupCancel" class="search-form__btn search-form__btn--ghost">취소</button>
            <button type="button" id="btnPopupSave"   class="search-form__btn">저장</button>
        </div>
    </div>
</div>

<!-- jQuery / jqGrid -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/free-jqgrid/4.15.5/jquery.jqgrid.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/free-jqgrid/4.15.5/i18n/grid.locale-kr.min.js"></script>
<script src="${pageContext.request.contextPath}/js/csrf.js"></script>

<!-- TinyMCE 6.8.6 (로컬 static 서빙, MIT) -->
<script src="${pageContext.request.contextPath}/tinymce/tinymce.min.js"></script>

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

        /* ── 프로젝트 설명 TinyMCE (팝업 최초 오픈 시 1회 초기화 후 재사용) ── */
        var TINYMCE_BASE = '${pageContext.request.contextPath}/tinymce';

        var descEditor        = null;    // 초기화 완료된 TinyMCE Editor 인스턴스
        var descEditorLoading = false;   // 중복 초기화 방지
        var pendingDescHtml   = '';      // 에디터 초기화 완료 전 적용 대기 HTML

        /* 팝업이 display:none 인 동안 초기화하면 iframe 크기 계산이 깨지므로
           팝업이 열린(is-open) 뒤 최초 1회만 초기화한다. */
        function ensureDescEditor() {
            if (descEditor || descEditorLoading) return;
            descEditorLoading = true;

            tinymce.init({
                selector:     '#popupProjectDescription',
                language:     'ko_KR',
                language_url: TINYMCE_BASE + '/langs/ko_KR.js',
                height:       300,
                menubar:      false,
                statusbar:    false,
                branding:     false,
                promotion:    false,
                convert_urls: false,
                plugins:      'lists link table autolink searchreplace charmap',
                content_style: 'body { font-family: Inter, ui-sans-serif, system-ui, -apple-system, ' +
                               '"Apple SD Gothic Neo", "Noto Sans KR", sans-serif; font-size: 14px; ' +
                               'line-height: 1.6; color: #0f172a; }',
                toolbar:      'undo redo | blocks fontsize | bold italic underline strikethrough forecolor backcolor | ' +
                              'alignleft aligncenter alignright | bullist numlist | table link charmap | removeformat'
            }).then(function (editors) {
                descEditor = editors[0];
                descEditor.setContent(pendingDescHtml);
            });
        }

        /* 에디터 내용 전체 교체 (초기화 전이면 대기시켰다가 init 완료 시 반영) */
        function setDescHtml(html) {
            pendingDescHtml = html || '';
            if (descEditor) {
                descEditor.setContent(pendingDescHtml);
            }
        }

        /* 에디터 내용 조회 — 초기화 완료 전이면 마지막 setDescHtml 값을 반환해
           수정 모드의 설명 유실을 막는다. */
        function getDescHtml() {
            if (!descEditor) return pendingDescHtml;
            return descEditor.getContent();
        }

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
            $("#projectPopupDesc").text("프로젝트 정보를 입력한 뒤 저장하세요.");
            $("#popupProjectIdField").hide();
            $("#popupProjectId").val("");
            $("#popupProjectName").val("");
            $("#popupProjectOwnerName").val("");
            $popup.addClass("is-open").attr("aria-hidden", "false");
            ensureDescEditor();     // 팝업이 보이는 상태에서 생성해야 크기 계산이 정상
            setDescHtml("");
            $("#popupProjectName").trigger("focus");
        }

        // project: 단건 조회 API(GET /projects/{id})의 project 객체
        function openEditPopup(project) {
            popupMode = "edit";
            $("#projectPopupTitle").text("프로젝트 수정");
            $("#projectPopupDesc").text("변경할 내용을 수정한 뒤 저장하세요.");
            // projectId 항목은 화면에 노출하지 않고(숨김 유지), 값만 채워 수정 시 PATCH URL 식별자로 사용한다.
            $("#popupProjectIdField").hide();
            $("#popupProjectId").val(project.projectId);
            $("#popupProjectName").val(project.projectName);
            $("#popupProjectOwnerName").val(project.projectOwnerName);
            $popup.addClass("is-open").attr("aria-hidden", "false");
            ensureDescEditor();     // 팝업이 보이는 상태에서 생성해야 크기 계산이 정상
            setDescHtml(project.projectDescription || "");
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
                    projectName:        projectName,
                    projectOwnerName:   projectOwnerName,
                    projectDescription: getDescHtml()
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

        // "상세" 버튼 클릭 → 단건 조회 후 수정 팝업 오픈
        // (projectDescription은 HTML이라 그리드 셀에 싣지 않고 매번 단건 API로 로드.
        //  조회 실패 시 팝업을 열지 않음 — UPDATE가 description을 무조건 SET 하므로
        //  미로드 상태로 저장하면 기존 설명이 빈 값으로 덮어써지는 유실이 생긴다.)
        $("#projectGrid").on("click", ".btn-detail", function () {
            var $btn  = $(this);
            var rowId = $btn.data("id");

            $btn.prop("disabled", true);

            $.getJSON(saveUrl + "/" + encodeURIComponent(rowId))
                .done(function (data) {
                    if (data && data.success) {
                        openEditPopup(data.project);
                    } else {
                        alert("프로젝트 상세 조회에 실패했습니다.\n" + ((data && data.message) || ""));
                    }
                })
                .fail(function (xhr, status, error) {
                    alert("프로젝트 상세 조회 중 오류가 발생했습니다.\n" + status + " : " + error);
                })
                .always(function () {
                    $btn.prop("disabled", false);
                });
        });

        $("#btnCreate").on("click", openCreatePopup);
        $("#btnPopupCancel").on("click", closePopup);
        $("#btnPopupClose").on("click", closePopup);
        $("#projectPopupDim").on("click", closePopup);
        $("#btnPopupSave").on("click", saveProject);
    });
</script>

</body>
</html>