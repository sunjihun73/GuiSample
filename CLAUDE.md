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