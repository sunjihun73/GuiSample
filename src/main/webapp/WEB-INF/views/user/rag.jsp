<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RAG — 기술테스트 시스템</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
</head>
<body>

<!-- ── Top Bar ── -->
<header class="topbar">
    <a href="/" class="topbar__brand">기술테스트 시스템</a>
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
            <li class="nav-menu__item active">
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
    <main class="main-content rag-chat">

        <header class="page-header">
            <h1 class="page-header__title">RAG 챗봇</h1>
        </header>

        <!-- 본문: 좌측 카테고리 패널 + 우측 채팅 UI -->
        <div class="rag-body">

            <!-- 카테고리 선택 패널 (좌측 약 1/5) -->
            <aside class="rag-cat-panel" aria-label="카테고리 선택">
                <p class="rag-cat-panel__title">카테고리</p>
                <div id="ragCatList" class="rag-cat-list" role="group" aria-label="카테고리 목록">
                    <button type="button" class="rag-cat-btn is-selected"
                            data-category-id="" aria-pressed="true">전체</button>
                </div>
                <p id="ragCatMsg" class="rag-cat-msg"></p>
            </aside>

            <!-- 채팅 UI -->
            <div class="chat-window">
            <!-- 메시지 표시 영역 (위쪽) -->
            <div id="chatMessages" class="chat-messages" aria-live="polite">
                <div class="chat-msg chat-msg--bot">
                    <div class="chat-bubble">안녕하세요. 무엇을 도와드릴까요? 궁금한 내용을 입력해 주세요.</div>
                </div>
            </div>

            <!-- 입력 바 (아래쪽) -->
            <form id="chatForm" class="chat-input-bar" onsubmit="return false;">
                <textarea id="chatInput" class="chat-input" rows="1" aria-label="메시지 입력"
                          placeholder="메시지를 입력하세요  (Enter 전송 · Shift+Enter 줄바꿈)"></textarea>
                <button type="submit" id="chatSendBtn" class="chat-send-btn">전송</button>
            </form>
            </div>

        </div>

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

    /* ── 카테고리 목록 로딩 + 단일 선택 ───────────────────── */
    (function () {
        /* 백엔드 응답: GET /user/category/categories?page=1&rows=1000
           →  200  { page, total, records, rows: [{ categoryId, categoryName, … }] } */
        var CATEGORIES_URL = '${pageContext.request.contextPath}/user/category/categories?page=1&rows=1000';

        var listEl = document.getElementById('ragCatList');
        var msgEl  = document.getElementById('ragCatMsg');

        /* 클릭한 버튼만 선택 표시 (단일 선택) */
        listEl.addEventListener('click', function (e) {
            var btn = e.target.closest('.rag-cat-btn');
            if (!btn) return;

            listEl.querySelectorAll('.rag-cat-btn').forEach(function (b) {
                b.classList.remove('is-selected');
                b.setAttribute('aria-pressed', 'false');
            });
            btn.classList.add('is-selected');
            btn.setAttribute('aria-pressed', 'true');
        });

        /* 카테고리 목록 로딩 — 실패해도 "전체" 검색은 계속 동작 */
        (async function loadCategories() {
            try {
                var res = await fetch(CATEGORIES_URL, {
                    headers: { 'Accept': 'application/json' }
                });
                if (!res.ok) throw new Error('HTTP ' + res.status);

                var data = await res.json();
                var rows = data && Array.isArray(data.rows) ? data.rows : [];

                rows.forEach(function (cat) {
                    if (!cat || !cat.categoryId) return;

                    var btn = document.createElement('button');
                    btn.type = 'button';
                    btn.className = 'rag-cat-btn';
                    btn.dataset.categoryId = cat.categoryId;
                    btn.setAttribute('aria-pressed', 'false');
                    btn.textContent = cat.categoryName || '(이름 없음)';   /* XSS 방지 */
                    btn.title = cat.categoryName || '';
                    listEl.appendChild(btn);
                });

                if (!rows.length) {
                    msgEl.textContent = '등록된 카테고리가 없습니다.';
                }
            } catch (e) {
                msgEl.textContent = '카테고리 목록을 불러오지 못했습니다. (' + e.message + ')';
                msgEl.classList.add('is-error');
            }
        })();
    })();

    /* ── RAG 답변 스트리밍 ────────────────────────────────── */
    (function () {
        /* 백엔드 응답: POST /user/rag/docs  body { query }
           →  200  text/event-stream  (data: 토큰 …)  답변 토큰 스트림 */
        var DOCS_URL = '${pageContext.request.contextPath}/user/rag/docs';

        var messagesEl = document.getElementById('chatMessages');
        var formEl     = document.getElementById('chatForm');
        var inputEl    = document.getElementById('chatInput');
        var sendBtn    = document.getElementById('chatSendBtn');

        /* 메시지 말풍선 추가 — 텍스트는 textContent로 삽입(XSS 방지).
           말풍선(.chat-bubble) 요소를 반환해 스트리밍 토큰을 이어붙일 수 있게 한다. */
        function appendMessage(role, text) {
            var row = document.createElement('div');
            row.className = 'chat-msg chat-msg--' + role;

            var bubble = document.createElement('div');
            bubble.className = 'chat-bubble';
            bubble.textContent = text;

            row.appendChild(bubble);
            messagesEl.appendChild(row);
            scrollToBottom();
            return bubble;
        }

        /* 타이핑 인디케이터 표시/제거 */
        function showTyping() {
            var row = document.createElement('div');
            row.className = 'chat-msg chat-msg--bot';
            row.id = 'chatTyping';

            var bubble = document.createElement('div');
            bubble.className = 'chat-bubble';

            var typing = document.createElement('div');
            typing.className = 'chat-typing';
            typing.appendChild(document.createElement('span'));
            typing.appendChild(document.createElement('span'));
            typing.appendChild(document.createElement('span'));

            bubble.appendChild(typing);
            row.appendChild(bubble);
            messagesEl.appendChild(row);
            scrollToBottom();
        }
        function removeTyping() {
            var t = document.getElementById('chatTyping');
            if (t) t.remove();
        }

        function scrollToBottom() {
            messagesEl.scrollTop = messagesEl.scrollHeight;
        }

        /* textarea 높이 자동 조절 */
        function autoGrow() {
            inputEl.style.height = 'auto';
            inputEl.style.height = Math.min(inputEl.scrollHeight, 140) + 'px';
        }

        /* 좌측 패널에서 선택된 카테고리 ID 반환 ("전체"면 빈 문자열) */
        function getSelectedCategoryId() {
            var sel = document.querySelector('#ragCatList .rag-cat-btn.is-selected');
            return sel ? sel.dataset.categoryId : '';
        }

        /* /user/rag/docs 답변 스트림 소비.
           fetch ReadableStream을 직접 읽어 SSE(data: 라인)를 파싱하고
           토큰마다 onToken(text)을 호출한다. (EventSource는 GET만 지원하므로 미사용)
           Spring SSE는 'data:' 뒤에 공백을 추가하지 않으므로 slice(5)로 원문을 보존한다. */
        async function streamAnswer(query, onToken) {
            /* 카테고리 선택 시 categoryId를 함께 전송 — 서버가 metadata 필터로 사용.
               "전체"(빈 값)면 필드를 생략하여 전체 벡터 검색. */
            var payload = { query: query };
            var categoryId = getSelectedCategoryId();
            if (categoryId) payload.categoryId = categoryId;

            var res = await fetch(DOCS_URL, {
                method:  'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept':       'text/event-stream'
                },
                body: JSON.stringify(payload)
            });
            if (!res.ok)   throw new Error('HTTP ' + res.status);
            if (!res.body) throw new Error('스트림을 지원하지 않는 브라우저입니다.');

            var reader  = res.body.getReader();
            var decoder = new TextDecoder('utf-8');
            var buffer  = '';

            while (true) {
                var chunk = await reader.read();
                if (chunk.done) break;

                buffer += decoder.decode(chunk.value, { stream: true });

                /* 이벤트 경계는 빈 줄(\n\n). 마지막 미완성 조각은 버퍼에 남긴다. */
                var events = buffer.split('\n\n');
                buffer = events.pop();

                events.forEach(function (evt) {
                    var dataLines = [];
                    evt.split('\n').forEach(function (line) {
                        if (line.indexOf('data:') === 0) {
                            dataLines.push(line.slice(5));
                        }
                    });
                    if (dataLines.length) onToken(dataLines.join('\n'));
                });
            }
        }

        async function handleSend() {
            var text = inputEl.value.trim();
            if (!text) return;

            appendMessage('user', text);
            inputEl.value = '';
            autoGrow();
            inputEl.focus();

            sendBtn.disabled = true;
            showTyping();

            var bubble = null;
            try {
                await streamAnswer(text, function (token) {
                    if (!bubble) {
                        removeTyping();
                        bubble = appendMessage('bot', '');
                        bubble.classList.add('is-streaming');
                    }
                    bubble.textContent += token;
                    scrollToBottom();
                });

                if (!bubble) {
                    removeTyping();
                    appendMessage('bot', '응답을 받지 못했습니다.');
                } else {
                    bubble.classList.remove('is-streaming');
                }
            } catch (e) {
                removeTyping();
                if (bubble) {
                    bubble.classList.remove('is-streaming');
                    bubble.textContent += '\n[오류] ' + e.message;
                } else {
                    appendMessage('bot', '답변 생성 중 오류가 발생했습니다. (' + e.message + ')');
                }
            } finally {
                sendBtn.disabled = false;
            }
        }

        formEl.addEventListener('submit', handleSend);
        inputEl.addEventListener('input', autoGrow);

        /* Enter 전송, Shift+Enter 줄바꿈 */
        inputEl.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                handleSend();
            }
        });

        inputEl.focus();
    })();
</script>

</body>
</html>