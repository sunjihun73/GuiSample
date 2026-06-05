<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Embedding — 업무관리 시스템</title>
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
                    <span class="nav-label">RAG</span>
                </a>
                <span class="tooltip">RAG</span>
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

        <!-- ── 문서 업로드 폼 ── -->
        <form id="embedForm" class="embed-card" onsubmit="return false;">
            <div class="form-field">
                <label for="embedSource" class="form-field__label">출처(source)</label>
                <input type="text" id="embedSource" name="source"
                       class="form-field__input"
                       placeholder="예: 사내규정-v1" maxlength="200">
            </div>

            <div class="form-field">
                <label for="embedFile" class="form-field__label">텍스트 파일</label>
                <input type="file" id="embedFile" name="file"
                       class="embed-file"
                       accept=".txt,.md,text/*">
            </div>

            <div class="embed-card__actions">
                <button type="button" id="embedBtn" class="search-form__btn">업로드</button>
            </div>

            <div id="embedResult" class="embed-result" role="status" aria-live="polite"></div>
        </form>

    </main>
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

    /* ── 문서 업로드 (파일 → 청킹 → 임베딩 적재) ──────────── */
    (function () {
        /* 백엔드: POST /user/rag/embedding  multipart/form-data { file, source }
           → 200 application/json { success, source, chunkCount, message }
             (성공/실패 모두 200, success 불리언으로 분기) */
        var EMBED_URL = '${pageContext.request.contextPath}/user/rag/embedding';

        var formEl   = document.getElementById('embedForm');
        var sourceEl = document.getElementById('embedSource');
        var fileEl   = document.getElementById('embedFile');
        var btnEl    = document.getElementById('embedBtn');
        var resultEl = document.getElementById('embedResult');

        /* 결과 영역에 텍스트 표시 — textContent로만 삽입(XSS 방지). */
        function showResult(text, state) {
            resultEl.className = 'embed-result' + (state ? ' is-' + state : '');
            resultEl.textContent = text;
        }

        async function handleUpload() {
            var source = sourceEl.value.trim();
            var file   = fileEl.files && fileEl.files[0];

            if (!source) {
                showResult('출처(source)를 입력해 주세요.', 'error');
                sourceEl.focus();
                return;
            }
            if (!file) {
                showResult('업로드할 텍스트 파일을 선택해 주세요.', 'error');
                fileEl.focus();
                return;
            }

            var formData = new FormData();
            /* 필드명은 백엔드 @RequestParam 과 정확히 일치해야 한다. */
            formData.append('file', file);
            formData.append('source', source);

            btnEl.disabled = true;
            var originalLabel = btnEl.textContent;
            btnEl.textContent = '업로드 중...';
            showResult('업로드 중...', 'loading');

            try {
                /* FormData 사용 시 Content-Type 을 직접 지정하지 않는다
                   (브라우저가 multipart boundary 를 자동 설정). */
                var res = await fetch(EMBED_URL, {
                    method: 'POST',
                    body:   formData
                });

                if (!res.ok) {
                    throw new Error('HTTP ' + res.status);
                }

                var data = await res.json();

                if (data && data.success) {
                    var src   = (data.source != null) ? String(data.source) : source;
                    var count = (data.chunkCount != null) ? data.chunkCount : 0;
                    showResult(src + ' · ' + count + '개 청크 저장 완료', 'success');
                } else {
                    var msg = (data && data.message)
                        ? String(data.message)
                        : '업로드에 실패했습니다.';
                    showResult(msg, 'error');
                }
            } catch (e) {
                showResult('업로드 중 오류가 발생했습니다. (' + e.message + ')', 'error');
            } finally {
                btnEl.disabled = false;
                btnEl.textContent = originalLabel;
            }
        }

        btnEl.addEventListener('click', handleUpload);
        formEl.addEventListener('submit', function (e) {
            e.preventDefault();
            handleUpload();
        });
    })();
</script>

</body>
</html>