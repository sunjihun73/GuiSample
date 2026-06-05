# QA Findings — 파일 업로드 임베딩 기능

> 검증: orchestrator(통합 검증) | 날짜: 2026-06-05

## 정적 검증 결과 (PASS)

| # | 요구사항 | 구현 위치 | 상태 |
|---|---------|----------|------|
| 1 | 파일 선택 + 업로드 + source 입력 | embedding.jsp 업로드 폼 | ✅ |
| 2 | POST /user/rag/embedding | AIRestController `@PostMapping("/embedding")` | ✅ |
| 3 | TokenTextSplitter 청킹 | EmbeddingService | ✅ |
| 4 | 청크 사이즈 800 토큰 | `withChunkSize(800)` | ✅ |
| 5 | vector_store 테이블 | pgvector starter 자동관리 | ✅ |
| 6 | id = GUID | `new Document(...)` → UUID 자동 | ✅ |
| 7 | content = 청크 텍스트 | VectorStore.add | ✅ |
| 8 | metadata {"source":값} | `Map.of("source", source)` | ✅ |
| 9 | embedding 컬럼 | VectorStore.add 내부 EmbeddingModel | ✅ |

## 경계면 교차 검증 (PASS)

- **컨트롤러 multipart 필드 ↔ FormData**: `@RequestParam("file"/"source")` ↔ `formData.append('file'/'source')` 일치 ✅
- **응답 DTO ↔ JS 파서**: record `{success, source, chunkCount, message}` ↔ `data.success/source/chunkCount/message` 일치 ✅
- **엔드포인트 경로**: `/user/rag/embedding` ↔ JS `EMBED_URL` 일치 ✅
- **FormData Content-Type**: JS에서 헤더 직접 미지정(브라우저 boundary 자동) ✅

## 빌드 검증

- `./gradlew compileJava` → BUILD SUCCESSFUL ✅

## 런타임 미검증 (제약)

- `bootRun` 기동 후 실제 업로드→DB 적재→챗봇 반영 시나리오는 **라이브 PostgreSQL(pgvector) + OPENAI_API_KEY 필요**로 본 단계에서 미실행.
- 권장 수동 검증: ① 텍스트 파일+source 업로드 → success:true/chunkCount>0, ② DB `vector_store`에서 `metadata->>'source'`, id(uuid), embedding non-null 확인, ③ 빈 파일 → success:false.
