<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RAG — 업무관리 시스템</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">

    <!-- ── 채팅 UI 전용 스타일 ───────────────────────────── -->
    <style>
        /* 메인 영역을 세로 플렉스로: 상단 제목 고정 + 채팅창이 남는 높이를 채움 */
        .main-content.rag-chat {
            display: flex;
            flex-direction: column;
            overflow: hidden;            /* 스크롤은 메시지 영역이 담당 */
        }

        /* 채팅 카드 (메시지 + 입력창을 감싸는 컨테이너) */
        .chat-window {
            flex: 1;
            min-height: 0;               /* 자식 overflow가 동작하도록 */
            display: flex;
            flex-direction: column;
            background: var(--canvas);
            border: 1px solid var(--hairline);
            border-radius: var(--rounded-lg);
            overflow: hidden;
        }

        /* 메시지 표시 영역 (위쪽, 스크롤) */
        .chat-messages {
            flex: 1;
            min-height: 0;
            overflow-y: auto;
            padding: var(--sp-lg);
            display: flex;
            flex-direction: column;
            gap: var(--sp-md);
        }

        /* 메시지 행 */
        .chat-msg {
            display: flex;
            max-width: 78%;
        }
        .chat-msg--user {
            align-self: flex-end;
            justify-content: flex-end;
        }
        .chat-msg--bot {
            align-self: flex-start;
        }

        /* 말풍선 */
        .chat-bubble {
            padding: var(--sp-sm) var(--sp-md);
            border-radius: var(--rounded-lg);
            font-size: 15px;
            line-height: 1.5;
            letter-spacing: -0.224px;
            white-space: pre-wrap;
            word-break: break-word;
        }
        .chat-msg--user .chat-bubble {
            background: var(--primary);
            color: #fff;
            border-bottom-right-radius: var(--rounded-sm);
        }
        .chat-msg--bot .chat-bubble {
            background: var(--canvas-parchment);
            color: var(--ink);
            border: 1px solid var(--hairline);
            border-bottom-left-radius: var(--rounded-sm);
        }

        /* 타이핑 인디케이터 */
        .chat-typing { display: flex; gap: 4px; align-items: center; }
        .chat-typing span {
            width: 7px; height: 7px;
            border-radius: 50%;
            background: var(--ink-muted-48);
            opacity: 0.5;
            animation: chat-blink 1.2s infinite ease-in-out both;
        }
        .chat-typing span:nth-child(2) { animation-delay: 0.2s; }
        .chat-typing span:nth-child(3) { animation-delay: 0.4s; }
        @keyframes chat-blink {
            0%, 80%, 100% { opacity: 0.25; transform: translateY(0); }
            40%           { opacity: 1;    transform: translateY(-3px); }
        }

        /* 입력 바 (아래쪽 고정) */
        .chat-input-bar {
            flex-shrink: 0;
            display: flex;
            align-items: flex-end;
            gap: var(--sp-sm);
            padding: var(--sp-md) var(--sp-lg);
            border-top: 1px solid var(--hairline);
            background: var(--canvas);
        }
        .chat-input {
            flex: 1;
            resize: none;
            max-height: 140px;
            min-height: 44px;
            padding: 11px 18px;
            font-family: var(--font-text);
            font-size: 15px;
            line-height: 1.47;
            letter-spacing: -0.224px;
            color: var(--ink);
            background: var(--canvas);
            border: 1px solid var(--hairline);
            border-radius: var(--rounded-lg);
            outline: none;
            transition: border-color 0.12s, box-shadow 0.12s;
        }
        .chat-input::placeholder { color: var(--ink-muted-48); }
        .chat-input:focus {
            border-color: var(--primary-focus);
            box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.15);
        }
        .chat-send-btn {
            flex-shrink: 0;
            height: 44px;
            padding: 0 24px;
            font-family: var(--font-text);
            font-size: 15px;
            font-weight: 600;
            line-height: 1;
            letter-spacing: -0.224px;
            color: #fff;
            background: var(--primary);
            border: none;
            border-radius: var(--rounded-pill);
            cursor: pointer;
            transition: background-color 0.12s, transform 0.08s ease-out;
        }
        .chat-send-btn:hover  { background: var(--primary-focus); }
        .chat-send-btn:active { transform: scale(0.96); }
        .chat-send-btn:disabled {
            background: var(--hairline);
            color: var(--ink-muted-48);
            cursor: default;
        }

        /* 스트리밍 중인 봇 말풍선 끝에 깜빡이는 커서 */
        .chat-bubble.is-streaming::after {
            content: '▋';
            margin-left: 1px;
            color: var(--ink-muted-48);
            animation: chat-caret 1s steps(1) infinite;
        }
        @keyframes chat-caret {
            0%, 50% { opacity: 1; }
            50.01%, 100% { opacity: 0; }
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
            <li class="nav-menu__item active">
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
    <main class="main-content rag-chat">

        <header class="page-header">
            <h1 class="page-header__title">RAG</h1>
        </header>

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

        /* /user/rag/docs 답변 스트림 소비.
           fetch ReadableStream을 직접 읽어 SSE(data: 라인)를 파싱하고
           토큰마다 onToken(text)을 호출한다. (EventSource는 GET만 지원하므로 미사용)
           Spring SSE는 'data:' 뒤에 공백을 추가하지 않으므로 slice(5)로 원문을 보존한다. */
        async function streamAnswer(query, onToken) {
            var res = await fetch(DOCS_URL, {
                method:  'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept':       'text/event-stream'
                },
                body: JSON.stringify({ query: query })
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