# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
./gradlew bootRun        # 임베디드 Tomcat 실행 (DevTools). 기본 프로파일 local
./gradlew build          # 컴파일 + WAR 패키징 → build/libs/guiSample-0.0.1-SNAPSHOT.war
./gradlew clean build
SPRING_PROFILES_ACTIVE=e2e ./gradlew bootRun   # e2e 프로파일로 기동
```

`src/test` 가 없으므로 `./gradlew test` 는 아무 테스트도 돌리지 않는다. **이 프로젝트의 실제 테스트는 `e2e/` 의 Playwright 스위트**다 (아래 참조).

Java 툴체인은 **21** (`build.gradle`). README.md 의 "Java 17" 표기는 오래된 값이다.

### E2E (Playwright)

`e2e/` 는 Gradle 빌드에 포함되지 않는 별도 npm 프로젝트다.

```bash
cd e2e
npm install && npm run install:browser   # 최초 1회
npm test          # @guardrail 태그 제외 (기본)
npm run test:all  # 전체 — LiteLLM 가드레일 백엔드(LM Studio) 필요
npm run test:ui / npm run report
```

앱을 포함해 pgvector·Keycloak·LiteLLM·nginx 가 **모두 떠 있어야** 하고 `/etc/hosts` 에 `mytechtest.jihun.com` / `keycloak.jihun.com` / `litellm.jihun.com` 이 등록돼 있어야 한다. 누락 시 `setup/preflight.ts` 가 무엇을 어떻게 띄우는지 찍고 중단한다. 상세 절차와 자주 막히는 지점은 `e2e/README.md`.

Playwright 스펙은 JSP 의 실제 `id`/`class` 셀렉터에 직접 의존한다(`chat.spec.ts` 상단 주석에 목록). **JSP 의 id/class 를 바꾸면 e2e 가 깨진다.**

## 설정 · 프로파일

- `application.yaml` 은 **프로파일 선택만** 한다: `spring.profiles.active: ${SPRING_PROFILES_ACTIVE:local}`.
- 실제 설정은 전부 `application-local.yaml` / `application-e2e.yaml` 에 **각각 완전한 형태로** 들어 있다. 두 파일의 현재 유일한 차이는 `spring.ai.openai.chat.options.model` (`gpt-4o-mini` vs `e2e-mock`). **설정을 바꿀 때는 두 파일을 함께 고쳐야 한다.**
- 비밀값은 루트 `.env`(gitignore) 에서 `spring.config.import: optional:file:.env[.properties]` 로 주입: `OPENAI_API_KEY`, `KEYCLOAK_CLIENT_SECRET`, `UPLOAD_FILE_PATH`.
- OpenAI 호출은 실제 OpenAI 가 아니라 **LiteLLM 프록시**(`base-url: http://litellm.jihun.com`)를 거친다. 가드레일도 LiteLLM 쪽에 있다.

## 아키텍처

Spring Boot 4 + Spring AI(2.0.0-M4) + MyBatis + PostgreSQL(pgvector) + JSP. 루트 패키지 `kr.co.jihun.guisample`. 임베디드(`GuiSampleApplication`)와 외부 WAR(`ServletInitializer`) 두 배포 모드를 모두 지원한다.

### 단일 DataSource — 자동구성 비활성

`DataSourceConfig` 가 `HikariDataSource` 빈을 직접 선언하므로 **Boot 의 DataSource/MyBatis 자동구성이 꺼진다**. 따라서 `SqlSessionFactory` 도 여기서 명시 구성한다: `mapUnderscoreToCamelCase=true`, `typeAliasesPackage=...dto`, `mapperLocations=classpath:mapper/**/*.xml`. Spring AI pgvector 와 MyBatis 매퍼가 이 DataSource 하나를 공유한다. 커넥션 설정은 `spring.datasource` (Hikari 키 — `jdbc-url`, `maximum-pool-size` 등) 아래에 있다.

### 인증 — Keycloak(OIDC) + 세션 사용자

- `SecurityConfig`: `PUBLIC_PATHS`(랜딩·정적·`/actuator/health/**`) 외 전부 인증. AJAX/SSE 요청(`X-Requested-With` 또는 Accept 가 JSON/event-stream)은 302 대신 **401** 로 끊는다 — 그래야 fetch/jqGrid 가 로그인 HTML 을 파싱하다 죽지 않는다.
- `KeycloakUserProvisioningFilter` 는 **빈으로 만들지 않고** `SecurityConfig` 에서 직접 생성해 `AuthorizationFilter` 뒤에 넣는다(Boot 의 Filter 빈 자동 등록으로 인한 이중 실행 방지). OAuth2 콜백 요청은 여기까지 오지 않으므로 실제 프로비저닝은 **로그인 후 첫 인증 요청**에서 일어난다. 실패는 fail-open(로그만).
- `LoginUserSession` 이 로그인 사용자에 접근하는 **유일한 통로**다. 컨트롤러/서비스는 `SecurityContextHolder`·`OidcUser` 를 직접 뒤지지 않는다. `require()`/`requireUserName()` 은 값이 없으면 예외를 던진다 — 조회 조건이 조용히 빠져 남의 데이터가 노출되는 것을 막기 위해서다.
- **주의**: `LoginUserSession` 은 요청 스레드 바인딩 프록시다. `Schedulers.boundedElastic()` 안에서 호출하면 실패한다. SSE 저장 경로처럼 비동기로 넘기는 값은 **컨트롤러 메서드 본문에서 미리 꺼내 파라미터로 전달**할 것 (`AIRestController.getDocs` 참조).

### 데이터 소유권 규칙

`user_master.user_name` 이 모든 조회의 소유권 필터 키다.

- 소유자 컬럼이 있는 테이블: `chat_master.chat_owner_user_id`, `knowledge_files.create_user_id`.
- 소유자 컬럼이 **없는** `chat_detail` 과 Spring AI 의 `vector_store` 는 **상위 엔터티의 소유권을 먼저 확인**하고(아니면 빈 목록) 접근한다 — `ChatService.selectMessages`, `KnowledgeFileService.selectKnowledgeChunkList` 가 그 패턴이다.
- jqGrid 계열 목록 컨트롤러에서는 **소유자 조건을 count 호출 전에** param 에 넣는다(총건수와 목록이 같은 조건을 봐야 한다). 페이징 키는 그 뒤에 `startRow`/`pageSize` 로 넣는다 — mapper XML 이 `pageSize != null` 일 때만 LIMIT/OFFSET 을 붙인다.

### RAG 파이프라인

- 벡터 검색은 서비스가 아니라 **어드바이저 체인 안**에서 일어난다: `RagContextAdvisor`(`CallAdvisor`+`StreamAdvisor`, order `HIGHEST_PRECEDENCE+100`, topK=4). 시스템 메시지만 `augmentSystemMessage` 로 증강하고 user 메시지는 원문 유지. 컨텍스트 주입은 `String.replace` **리터럴 치환** — 문서 본문의 중괄호가 프롬프트 템플릿으로 재파싱되지 않게 하기 위함이다. 스트리밍 경로의 블로킹 검색은 `boundedElastic` 로 오프로딩한다.
- 카테고리 한정 검색은 `chatClient...advisors(spec -> spec.param("category_id", ...))` 로 넘기고 어드바이저가 `request.context()` 에서 읽어 메타데이터 필터로 변환한다.
- 인덱싱(`EmbeddingService.embed`): 부모 `Document` 의 id 를 `fileId` 로 지정 → `TokenTextSplitter`(chunkSize 800)가 청크 metadata 에 `parent_document_id` 를 자동 주입 → `knowledge_files.file_id` 와 일치. 그래서 청크 조회를 파일 소유권으로 막을 수 있다.
- `POST /user/rag/docs` 는 `text/event-stream` 이라 **예외를 절대 밖으로 던지면 안 된다**. 던지면 Accept 협상 실패로 500 + 본문 없음이 된다. `onErrorResume` 으로 모든 실패를 텍스트 1건 + 정상 종료(200)로 바꾼다. LiteLLM 가드레일 차단은 400 응답 본문의 표식(`GUARDRAIL_MARKERS`)으로 설정 오류 400 과 구분한다.

### 프론트 규약 (JSP)

- 뷰는 `src/main/webapp/WEB-INF/views/`, 라우팅은 `MainController`(`/user/**`). 스타일은 `static/css/common.css` 단일 파일(화면별 인라인 스타일 금지).
- CSRF: 각 JSP `<head>` 의 `<meta name="_csrf">` / `_csrf_header` 를 `static/js/csrf.js` 가 읽어 jQuery ajax 에 자동 부착하고 fetch 용으로 `window.csrfHeader()` 를 노출한다. 401/403 이면 페이지를 새로고침해 Keycloak 로그인 흐름으로 되돌린다.
- JSP EL 은 자동 이스케이프가 없다 — 사용자 유래 문자열은 `HtmlUtils.htmlEscape` 로 직접 이스케이프한다.
- JSP 내 JS 변수 선언은 `var` 가 아니라 **`let`** 을 쓴다(커밋 90b316b 로 통일).
- REST 목록 응답은 jqGrid shape `{ page, total, records, rows[] }` 를 유지한다.

### 스키마 · 마이그레이션

- `src/main/resources/db/*.sql` 은 **수동 적용** 대상이다. 부팅 시 자동 실행되지 않는다.
- `vector_store` 테이블만 `spring.ai.vectorstore.pgvector.initialize-schema: true` 로 자동 생성된다(HNSW, cosine, 1536차원). 도메인 테이블(`user_master`, `project_master`, `category_master`, `knowledge_files`, `chat_master`, `chat_detail`)은 직접 만들어야 한다.
- 매퍼는 interface(`mapper/`)와 XML(`resources/mapper/`)이 짝을 이루며 namespace 가 일치해야 한다. 명시적 `resultMap` 을 쓰고, 동적 조건은 `<sql>` 조각으로 재사용한다(`KnowledgeFileMapper.xml` 이 표준형).

## 문서

- `src/docs/adr/` — 결정 기록: 0001 pgvector 채택, 0002 RAG 파이프라인·가드레일 LiteLLM 위임, 0003 Keycloak SSO·세션 관리. **인증/RAG 흐름을 바꾸기 전에 읽을 것.**
- `_workspace/00_architect_design.md` — 채팅 세션 기능(chat_master/chat_detail) 상세 설계. 나머지 `_workspace/*` 는 하위 에이전트 작업 요약, `_workspace_prev_*` 는 이전 회차 보관본.
- `README.md` — 기능·API 개요. 단, 자바 버전과 `vo` 패키지(현재는 `dto`) 표기는 낡았다.
- `DESIGN.md` — 앱 아키텍처가 아니라 UI 디자인 토큰(Apple 스타일) 스펙이다.

## 하네스: Spring AI/RAG 기능 개발

**목표:** Spring Boot 4 + MyBatis + PostgreSQL(pgvector) + JSP 환경에서 RAG 기능을 백엔드·데이터·프론트 전 계층에 걸쳐 일관되게 추가·수정한다.

**트리거:** RAG/Spring AI/벡터 검색/문서 인덱싱/챗봇 등 RAG 관련 신규·후속 작업 요청 시 `rag-feature-orchestrator` 스킬을 사용하라. 단순 질문(설계 조언, 사용법 문의)이나 1~2줄 수정은 직접 응답 가능.

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-05-30 | 초기 구성 (에이전트 5, 스킬 6) | 전체 | - |
| 2026-09-09 | 아키텍처·설정·E2E 섹션 보강 (/init) | 전체 | 코드 실사와 문서 불일치 해소 |
