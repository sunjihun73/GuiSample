package kr.co.jihun.guisample.service;

import kr.co.jihun.guisample.dto.EmbeddingResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.document.Document;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/**
 * 텍스트 파일 인덱싱 서비스.
 * 업로드된 plain text(UTF-8) 파일을 800토큰 단위로 청킹한 뒤,
 * EmbeddingModel 임베딩을 거쳐 pgvector VectorStore 에 적재한다.
 * (LLM 호출 없이 EmbeddingModel 만 사용 — VectorStore.add() 내부에서 자동 호출)
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EmbeddingService
{
    private final VectorStore vectorStore;

    /** 청킹 단위(토큰). 요구사항 명시값. */
    private static final int CHUNK_SIZE = 800;

    /**
     * 업로드 파일을 청킹·임베딩하여 vector_store 에 적재한다.
     * 성공/실패 모두 EmbeddingResponse 로 매핑하며, 실패 시 success=false 로 통일한다.
     *
     * @param file   업로드된 plain text(UTF-8) 파일
     * @param source 메타데이터에 저장할 출처 식별자
     * @return 적재 결과(성공 여부, source 에코백, 청크 수, 메시지)
     */
    public EmbeddingResponse ingest(MultipartFile file, String source)
    {
        // 입력 검증
        if (file == null || file.isEmpty())
        {
            return new EmbeddingResponse(false, source, 0, "업로드된 파일이 없습니다.");
        }
        if (source == null || source.isBlank())
        {
            return new EmbeddingResponse(false, source, 0, "source(출처 식별자)를 입력해 주세요.");
        }

        try
        {
            // 1) 텍스트 추출 (UTF-8)
            String text = new String(file.getBytes(), StandardCharsets.UTF_8);
            if (text.isBlank())
            {
                return new EmbeddingResponse(false, source, 0, "빈 파일입니다. 내용이 있는 텍스트 파일을 업로드해 주세요.");
            }

            // 2) 원본 Document 1건 생성 (id 미지정 → build 시 UUID 자동 부여)
            Document parent = new Document(text, Map.of("source", source));

            // 3) 800토큰 청킹 (무인자 생성자 deprecated → 빌더 사용)
            TokenTextSplitter splitter = TokenTextSplitter.builder()
                    .withChunkSize(CHUNK_SIZE)
                    .build();
            List<Document> chunks = splitter.apply(List.of(parent));

            // 최소 청크 길이 미만 등으로 청크가 0건일 수 있음
            if (chunks == null || chunks.isEmpty())
            {
                return new EmbeddingResponse(false, source, 0, "추출된 내용이 너무 짧아 저장할 청크가 없습니다.");
            }

            // 4) 벡터 저장 (EmbeddingModel 호출 후 id+content+metadata+embedding insert)
            vectorStore.add(chunks);

            int chunkCount = chunks.size();
            log.info("임베딩 적재 완료 - source={}, chunkCount={}", source, chunkCount);
            return new EmbeddingResponse(true, source, chunkCount, chunkCount + "개 청크를 저장했습니다.");
        }
        catch (Exception e)
        {
            log.error("임베딩 적재 실패 - source={}", source, e);
            return new EmbeddingResponse(false, source, 0, "파일 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
}
