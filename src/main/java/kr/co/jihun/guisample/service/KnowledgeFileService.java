package kr.co.jihun.guisample.service;

import kr.co.jihun.guisample.dto.EmbeddingResponse;
import kr.co.jihun.guisample.mapper.KnowledgeFileMapper;
import kr.co.jihun.guisample.dto.KnowledgeChunkDTO;
import kr.co.jihun.guisample.dto.KnowledgeFileDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

/**
 * 지식파일 서비스.
 * <ul>
 *   <li>knowledge_files 목록 조회/카운트 (지식파일 목록 그리드용)</li>
 *   <li>지식파일 업로드 오케스트레이션: 청킹·임베딩 적재 → 디스크 저장 → knowledge_files insert</li>
 * </ul>
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class KnowledgeFileService
{
    private static final String DEFAULT_USER_ID = "sunjeehun";

    /** 업로드 파일 저장 루트 (요구사항 7.9). .env 의 UPLOAD_FILE_PATH 값을 주입받는다. */
    @Value("${UPLOAD_FILE_PATH}")
    private String uploadDir;

    private final KnowledgeFileMapper knowledgeFileMapper;
    private final EmbeddingService embeddingService;

    /* ── 목록 조회 ───────────────────────────────────────── */

    public List<KnowledgeFileDTO> selectKnowledgeFileList(HashMap<String, Object> param)
    {
        return knowledgeFileMapper.selectKnowledgeFileList(param);
    }

    public int countKnowledgeFile(HashMap<String, Object> param)
    {
        return knowledgeFileMapper.countKnowledgeFile(param);
    }

    /**
     * 특정 지식파일(parent_document_id = file_id)의 청크 목록을 chunk_index 오름차순으로 조회한다.
     *
     * @param parentDocumentId 선택된 지식파일 ID (vector_store 청크 metadata.parent_document_id)
     */
    public List<KnowledgeChunkDTO> selectKnowledgeChunkList(String parentDocumentId)
    {
        HashMap<String, Object> param = new HashMap<>();
        param.put("parentDocumentId", parentDocumentId);
        return knowledgeFileMapper.selectKnowledgeChunkList(param);
    }

    /* ── 업로드 ─────────────────────────────────────────── */

    /**
     * 지식파일 업로드.
     * <ol>
     *   <li>file_id(UUID) 생성</li>
     *   <li>plain text(UTF-8) 본문 추출</li>
     *   <li>청킹(800토큰)·임베딩 → vector_store 적재 (부모 Document id = file_id)</li>
     *   <li>원본 파일을 디스크에 저장</li>
     *   <li>knowledge_files 테이블에 메타 정보 insert</li>
     * </ol>
     * 성공/실패 모두 EmbeddingResponse 로 매핑하며, 실패 시 success=false 로 통일한다.
     *
     * @param file       업로드된 plain text(UTF-8) 파일
     * @param categoryId 왼쪽 카테고리 그리드에서 선택된 카테고리 ID (metadata.source 및 category_id)
     */
    public EmbeddingResponse upload(MultipartFile file, String categoryId)
    {
        // 입력 검증
        if (file == null || file.isEmpty())
        {
            return new EmbeddingResponse(false, null, categoryId, null, 0, "업로드된 파일이 없습니다.");
        }
        if (categoryId == null || categoryId.isBlank())
        {
            return new EmbeddingResponse(false, null, categoryId, null, 0,
                    "카테고리를 선택해 주세요. (왼쪽 카테고리 목록에서 행을 선택)");
        }

        String originalName = file.getOriginalFilename();
        if (originalName == null || originalName.isBlank())
        {
            originalName = "untitled.txt";
        }

        try
        {
            // 1) 본문 추출 (UTF-8)
            byte[] bytes = file.getBytes();
            String text = new String(bytes, StandardCharsets.UTF_8);
            if (text.isBlank())
            {
                return new EmbeddingResponse(false, null, categoryId, originalName, 0,
                        "빈 파일입니다. 내용이 있는 텍스트 파일을 업로드해 주세요.");
            }

            // 2) file_id (UUID) — vector_store 청크 metadata 의 parent_document_id 와 동일
            String fileId = UUID.randomUUID().toString();

            // 3) 청킹·임베딩 적재 (부모 Document id = fileId, metadata.source = categoryId)
            int chunkCount = embeddingService.embed(text, categoryId, fileId);
            if (chunkCount == 0)
            {
                return new EmbeddingResponse(false, fileId, categoryId, originalName, 0,
                        "추출된 내용이 너무 짧아 저장할 청크가 없습니다.");
            }

            // 4) 원본 파일 디스크 저장 (파일명 충돌 방지를 위해 file_id 접두)
            saveToDisk(bytes, fileId, originalName);

            // 5) knowledge_files 메타 정보 insert
            KnowledgeFileDTO vo = new KnowledgeFileDTO();
            vo.setFileId(fileId);
            vo.setCategoryId(categoryId);
            vo.setFileName(originalName);
            vo.setCreateUserId(DEFAULT_USER_ID);
            vo.setUpdateUserId(DEFAULT_USER_ID);
            knowledgeFileMapper.insertKnowledgeFile(vo);

            log.info("지식파일 업로드 완료 - fileId={}, categoryId={}, fileName={}, chunkCount={}",
                    fileId, categoryId, originalName, chunkCount);
            return new EmbeddingResponse(true, fileId, categoryId, originalName, chunkCount,
                    originalName + " · " + chunkCount + "개 청크 저장 완료");
        }
        catch (Exception e)
        {
            log.error("지식파일 업로드 실패 - categoryId={}, fileName={}", categoryId, originalName, e);
            return new EmbeddingResponse(false, null, categoryId, originalName, 0,
                    "파일 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
    }

    /** 업로드 디렉터리를 보장하고 원본 바이트를 저장한다. 저장 파일명: {fileId}_{원본파일명} */
    private void saveToDisk(byte[] bytes, String fileId, String originalName) throws IOException
    {
        Path dir = Paths.get(uploadDir);
        Files.createDirectories(dir);
        Path target = dir.resolve(fileId + "_" + originalName);
        Files.write(target, bytes);
    }
}
