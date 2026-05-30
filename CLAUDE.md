# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
./gradlew build          # compile and package
./gradlew bootRun        # run with embedded Tomcat (DevTools enabled)
./gradlew test           # run all tests
./gradlew test --tests "kr.co.jihun.guisample.GuiSampleApplicationTests"  # run a single test class
./gradlew clean build    # clean then full build
```

WAR output: `build/libs/guiSample-0.0.1-SNAPSHOT.war`

## Tech Stack

- **Java 17**, Spring Boot 4.0.6, Spring MVC
- **Gradle 9.4.1** (use `./gradlew`, not system gradle)
- **Lombok** — use its annotations freely; annotation processing is configured
- **JUnit 5** for tests

## Architecture

Minimal Spring Boot starter. The app supports two deployment modes:
- **Embedded** (`bootRun`): `GuiSampleApplication` bootstraps embedded Tomcat
- **WAR** (external container): `ServletInitializer` extends `SpringBootServletInitializer`

Root package: `kr.co.jihun.guisample`

Static assets go in `src/main/resources/static/`, templates in `src/main/resources/templates/`, JSP views in `src/main/webapp/WEB-INF/views/`.

Configuration is in `src/main/resources/application.yaml`.

## 하네스: Spring AI/RAG 기능 개발

**목표:** Spring Boot 4 + MyBatis + PostgreSQL(pgvector) + JSP 환경에서 RAG 기능을 백엔드·데이터·프론트 전 계층에 걸쳐 일관되게 추가·수정한다.

**트리거:** RAG/Spring AI/벡터 검색/문서 인덱싱/챗봇 등 RAG 관련 신규·후속 작업 요청 시 `rag-feature-orchestrator` 스킬을 사용하라. 단순 질문(설계 조언, 사용법 문의)이나 1~2줄 수정은 직접 응답 가능.

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-05-30 | 초기 구성 (에이전트 5, 스킬 6) | 전체 | - |
