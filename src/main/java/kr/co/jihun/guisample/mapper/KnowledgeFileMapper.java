package kr.co.jihun.guisample.mapper;

import kr.co.jihun.guisample.dto.KnowledgeChunkDTO;
import kr.co.jihun.guisample.dto.KnowledgeFileDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.HashMap;
import java.util.List;

@Mapper
public interface KnowledgeFileMapper
{
    List<KnowledgeFileDTO> selectKnowledgeFileList(HashMap<String, Object> param);

    int countKnowledgeFile(HashMap<String, Object> param);

    int insertKnowledgeFile(KnowledgeFileDTO knowledgeFile);

    /**
     * 특정 지식파일(parent_document_id)에 속한 청크 목록을 chunk_index 오름차순으로 조회한다.
     *
     * @param param parentDocumentId(필수)
     */
    List<KnowledgeChunkDTO> selectKnowledgeChunkList(HashMap<String, Object> param);
}
