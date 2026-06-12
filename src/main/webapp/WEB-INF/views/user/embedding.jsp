<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Embedding — 업무관리 시스템</title>
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
            <li class="nav-menu__item">
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
            <li class="nav-menu__item active">
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
            <h1 class="page-header__title">Embedding</h1>
        </header>

        <div class="content-split">

            <!-- ── 좌측: 카테고리 목록 그리드 ── -->
            <div class="content-split__col">
                <div class="grid-header">
                    <span class="grid-header__title">카테고리 목록</span>
                    <div class="search-form__actions">
                        <button type="button" id="btnCategoryRead" class="search-form__btn">조회</button>
                        <button type="button" id="btnCategoryCreate" class="search-form__btn">등록</button>
                    </div>
                </div>

                <div class="grid-wrap">
                    <table id="categoryGrid"></table>
                    <div id="categoryGridPager"></div>
                </div>
            </div>

            <!-- ── 우측: 지식파일 목록 그리드 ── -->
            <div class="content-split__col">
                <div class="grid-header">
                    <span class="grid-header__title">지식파일 목록</span>
                    <div class="search-form__actions">
                        <button type="button" id="btnKnowledgeRead"   class="search-form__btn">조회</button>
                        <button type="button" id="btnKnowledgeCreate" class="search-form__btn">등록</button>
                    </div>
                </div>

                <div class="grid-wrap">
                    <table id="knowledgeGrid"></table>
                    <div id="knowledgeGridPager"></div>
                </div>
            </div>

        </div>

    </main>
</div>

<!-- ── 카테고리 등록 레이어 팝업 ── -->
<div class="layer-popup" id="categoryPopup" aria-hidden="true">
    <div class="layer-popup__dim" id="categoryPopupDim"></div>
    <div class="layer-popup__panel" role="dialog" aria-modal="true" aria-labelledby="categoryPopupTitle">
        <div class="layer-popup__header">
            <h2 class="layer-popup__title" id="categoryPopupTitle">카테고리 등록</h2>
        </div>
        <div class="layer-popup__body">
            <div class="form-field">
                <label for="popupCategoryName" class="form-field__label">카테고리명</label>
                <input type="text" id="popupCategoryName" class="form-field__input"
                       placeholder="카테고리명을 입력하세요" maxlength="200">
            </div>
        </div>
        <div class="layer-popup__footer">
            <button type="button" id="btnCategoryPopupSave"   class="search-form__btn">저장</button>
            <button type="button" id="btnCategoryPopupCancel" class="search-form__btn search-form__btn--ghost">취소</button>
        </div>
    </div>
</div>

<!-- ── 지식파일 등록(파일선택) 레이어 팝업 ── -->
<div class="layer-popup" id="knowledgePopup" aria-hidden="true">
    <div class="layer-popup__dim" id="knowledgePopupDim"></div>
    <div class="layer-popup__panel" role="dialog" aria-modal="true" aria-labelledby="knowledgePopupTitle">
        <div class="layer-popup__header">
            <h2 class="layer-popup__title" id="knowledgePopupTitle">지식파일 등록</h2>
        </div>
        <div class="layer-popup__body">
            <div class="form-field">
                <label for="knowledgePopupCategory" class="form-field__label">선택된 카테고리</label>
                <input type="text" id="knowledgePopupCategory" class="form-field__input" readonly
                       placeholder="왼쪽 카테고리 목록에서 카테고리를 선택하세요">
            </div>

            <div class="form-field">
                <label for="knowledgeFile" class="form-field__label">텍스트 파일</label>
                <input type="file" id="knowledgeFile" class="embed-file" accept=".txt,.md,text/*">
            </div>

            <div id="knowledgePopupResult" class="embed-result" role="status" aria-live="polite"></div>
        </div>
        <div class="layer-popup__footer">
            <button type="button" id="btnKnowledgePopupUpload" class="search-form__btn">업로드</button>
            <button type="button" id="btnKnowledgePopupCancel" class="search-form__btn search-form__btn--ghost">취소</button>
        </div>
    </div>
</div>

<script>
    /* ── 사이드바 토글 (다른 페이지와 동일) ───────────────── */
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
</script>

<!-- jQuery / jqGrid (카테고리 목록 그리드용) -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/free-jqgrid/4.15.5/jquery.jqgrid.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/free-jqgrid/4.15.5/i18n/grid.locale-kr.min.js"></script>

<script>
    $(function () {
        var listUrl          = '${pageContext.request.contextPath}/user/category/categories';
        var knowledgeListUrl = '${pageContext.request.contextPath}/user/knowledge/knowledges';
        var uploadUrl        = '${pageContext.request.contextPath}/user/rag/embedding';

        // 왼쪽 카테고리 그리드에서 선택된 행 (지식파일 업로드 시 사용)
        var selectedCategoryId   = null;
        var selectedCategoryName = null;

        // yyyy-mm-dd hh:mm:ss 형태로 변환 (DB 타임스탬프 문자열의 앞 19자리 사용)
        function dateTimeFormatter(cellValue) {
            if (!cellValue) {
                return "";
            }
            return String(cellValue).replace("T", " ").substring(0, 19);
        }

        // 페이지 로딩 시 GET /user/category/categories 로 목록 자동 조회
        $("#categoryGrid").jqGrid({
            url:       listUrl,
            datatype:  "json",
            mtype:     "GET",
            colNames:  ["카테고리 ID", "카테고리명", "생성일"],
            colModel: [
                { name: "categoryId",   index: "categoryId",   width: 120, align: "center", hidden: true },
                { name: "categoryName", index: "categoryName", width: 200 },
                { name: "createDate",   index: "createDate",   width: 160, align: "center", formatter: dateTimeFormatter }
            ],
            jsonReader: {
                root:        "rows",
                page:        "page",
                total:       "total",
                records:     "records",
                repeatitems: false,
                id:          "categoryId"
            },
            pager:        "#categoryGridPager",
            rownumbers:   true,
            rownumWidth:  56,
            rowNum:       10,
            rowList:      [10, 20, 50, 100],
            viewrecords:  true,
            autowidth:    true,
            height:       "520",
            emptyrecords: "조회된 데이터가 없습니다.",
            // 행 선택 시 categoryId/categoryName 보관 → 우측 지식파일 목록을 해당 카테고리로 조회
            onSelectRow: function (rowId) {
                var row = $("#categoryGrid").jqGrid("getRowData", rowId);
                selectedCategoryId   = rowId;                       // jsonReader.id = categoryId
                selectedCategoryName = (row && row.categoryName) ? row.categoryName : rowId;
                reloadKnowledgeGrid();                              // 선택한 category_id 기준으로 우측 목록 필터 조회
            },
            loadError: function (xhr, status, error) {
                alert("목록 조회 중 오류가 발생했습니다.\n" + status + " : " + error);
            }
        });

        // "조회" 클릭 → 카테고리 목록 조회 (jqGrid 내부 jQuery $.ajax GET)
        $("#btnCategoryRead").on("click", function () {
            $("#categoryGrid").jqGrid("setGridParam", {
                datatype: "json",
                url:      listUrl,
                page:     1
            }).trigger("reloadGrid");
        });

        /* ── 카테고리 등록 레이어 팝업 (projects.jsp 패턴) ── */
        var saveUrl = listUrl;   // POST /user/category/categories
        var $popup  = $("#categoryPopup");

        function openCreatePopup() {
            $("#popupCategoryName").val("");
            $popup.addClass("is-open").attr("aria-hidden", "false");
            $("#popupCategoryName").trigger("focus");
        }

        function closePopup() {
            $popup.removeClass("is-open").attr("aria-hidden", "true");
        }

        function saveCategory() {
            var categoryName = $.trim($("#popupCategoryName").val());

            if (categoryName === "") {
                alert("카테고리명을 입력하세요.");
                $("#popupCategoryName").trigger("focus");
                return;
            }

            $("#btnCategoryPopupSave").prop("disabled", true);

            $.ajax({
                url:         saveUrl,
                type:        "POST",
                contentType: "application/json",
                dataType:    "json",
                data:        JSON.stringify({ categoryName: categoryName })
            }).done(function (data) {
                if (data && data.success) {
                    closePopup();
                    $("#categoryGrid").jqGrid("setGridParam", {
                        datatype: "json",
                        url:      listUrl,
                        page:     1
                    }).trigger("reloadGrid");
                } else {
                    alert("저장에 실패했습니다.\n" + ((data && data.message) || ""));
                }
            })
            .fail(function (xhr, status, error) {
                alert("저장 중 오류가 발생했습니다.\n" + status + " : " + error);
            })
            .always(function () {
                $("#btnCategoryPopupSave").prop("disabled", false);
            });
        }

        $("#btnCategoryCreate").on("click", openCreatePopup);
        $("#btnCategoryPopupCancel").on("click", closePopup);
        $("#categoryPopupDim").on("click", closePopup);
        $("#btnCategoryPopupSave").on("click", saveCategory);

        /* ══════════════════════════════════════════════════════════
           지식파일 목록 그리드 + 파일선택(등록) 레이어 팝업
           - 목록: GET /user/knowledge/knowledges (jqGrid 표준 shape)
           - 업로드: POST /user/rag/embedding  multipart { file, categoryId }
                     → 200 JSON { success, fileId, categoryId, fileName, chunkCount, message }
           ══════════════════════════════════════════════════════════ */

        // 페이지 로딩 시 GET /user/knowledge/knowledges 로 목록 자동 조회
        $("#knowledgeGrid").jqGrid({
            url:       knowledgeListUrl,
            datatype:  "json",
            mtype:     "GET",
            colNames:  ["카테고리명", "파일 ID", "파일명", "생성일"],
            colModel: [
                { name: "categoryName", index: "categoryName", width: 160, align: "left" },
                { name: "fileId",       index: "fileId",       width: 120, align: "center", hidden: true },
                { name: "fileName",     index: "fileName",     width: 220 },
                { name: "createDate",   index: "createDate",   width: 160, align: "center", formatter: dateTimeFormatter }
            ],
            jsonReader: {
                root:        "rows",
                page:        "page",
                total:       "total",
                records:     "records",
                repeatitems: false,
                id:          "fileId"
            },
            pager:        "#knowledgeGridPager",
            rownumbers:   true,
            rownumWidth:  56,
            rowNum:       10,
            rowList:      [10, 20, 50, 100],
            viewrecords:  true,
            autowidth:    true,
            height:       "520",
            emptyrecords: "조회된 데이터가 없습니다.",
            loadError: function (xhr, status, error) {
                alert("지식파일 목록 조회 중 오류가 발생했습니다.\n" + status + " : " + error);
            }
        });

        function reloadKnowledgeGrid() {
            // 선택된 카테고리가 있으면 category_id 로 필터, 없으면 전체 조회
            $("#knowledgeGrid").jqGrid("setGridParam", {
                datatype: "json",
                url:      knowledgeListUrl,
                page:     1,
                postData: { categoryId: selectedCategoryId || "" }
            }).trigger("reloadGrid");
        }

        // "조회" 클릭 → 지식파일 목록 재조회
        $("#btnKnowledgeRead").on("click", reloadKnowledgeGrid);

        /* ── 파일선택(등록) 레이어 팝업 ── */
        var $knowledgePopup = $("#knowledgePopup");

        // 결과 영역 텍스트 표시 — textContent 로만 삽입(XSS 방지)
        function showKnowledgeResult(text, state) {
            var el = document.getElementById("knowledgePopupResult");
            el.className = "embed-result" + (state ? " is-" + state : "");
            el.textContent = text;
        }

        function openKnowledgePopup() {
            // 왼쪽 카테고리 목록에서 행이 선택되어 있어야 업로드 가능
            if (!selectedCategoryId) {
                alert("왼쪽 '카테고리 목록'에서 카테고리를 먼저 선택하세요.");
                return;
            }
            $("#knowledgePopupCategory").val(selectedCategoryName);
            $("#knowledgeFile").val("");
            showKnowledgeResult("", null);
            $knowledgePopup.addClass("is-open").attr("aria-hidden", "false");
        }

        function closeKnowledgePopup() {
            $knowledgePopup.removeClass("is-open").attr("aria-hidden", "true");
        }

        function uploadKnowledgeFile() {
            // 팝업이 열린 사이 선택 카테고리가 풀렸는지 한 번 더 방어
            if (!selectedCategoryId) {
                showKnowledgeResult("카테고리가 선택되지 않았습니다. 왼쪽 목록에서 선택하세요.", "error");
                return;
            }

            var fileInput = document.getElementById("knowledgeFile");
            var file = fileInput.files && fileInput.files[0];
            if (!file) {
                showKnowledgeResult("업로드할 텍스트 파일을 선택해 주세요.", "error");
                return;
            }

            var formData = new FormData();
            // 필드명은 백엔드 @RequestParam 과 정확히 일치해야 한다.
            formData.append("file", file);
            formData.append("categoryId", selectedCategoryId);

            var $btn = $("#btnKnowledgePopupUpload");
            $btn.prop("disabled", true);
            showKnowledgeResult("업로드 중...", "loading");

            // FormData 사용 시 contentType/processData 를 끈다(브라우저가 multipart boundary 자동 설정)
            $.ajax({
                url:         uploadUrl,
                type:        "POST",
                data:        formData,
                processData: false,
                contentType: false,
                dataType:    "json"
            }).done(function (data) {
                if (data && data.success) {
                    closeKnowledgePopup();
                    reloadKnowledgeGrid();
                } else {
                    showKnowledgeResult((data && data.message) ? data.message : "업로드에 실패했습니다.", "error");
                }
            })
            .fail(function (xhr, status, error) {
                showKnowledgeResult("업로드 중 오류가 발생했습니다. (" + status + " : " + error + ")", "error");
            })
            .always(function () {
                $btn.prop("disabled", false);
            });
        }

        $("#btnKnowledgeCreate").on("click", openKnowledgePopup);
        $("#btnKnowledgePopupCancel").on("click", closeKnowledgePopup);
        $("#knowledgePopupDim").on("click", closeKnowledgePopup);
        $("#btnKnowledgePopupUpload").on("click", uploadKnowledgeFile);
    });
</script>

</body>
</html>