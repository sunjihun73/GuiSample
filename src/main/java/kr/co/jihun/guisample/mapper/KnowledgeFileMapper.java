package kr.co.jihun.guisample.mapper;

import kr.co.jihun.guisample.vo.KnowledgeChunkVO;
import kr.co.jihun.guisample.vo.KnowledgeFileVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.HashMap;
import java.util.List;

@Mapper
public interface KnowledgeFileMapper
{
    List<KnowledgeFileVO> selectKnowledgeFileList(HashMap<String, Object> param);

    int countKnowledgeFile(HashMap<String, Object> param);

    int insertKnowledgeFile(KnowledgeFileVO knowledgeFile);

    /**
     * 특정 지식파일(parent_document_id)에 속한 청크 목록을 chunk_index 오름차순으로 조회한다.
     *
     * @param param parentDocumentId(필수)
     */
    List<KnowledgeChunkVO> selectKnowledgeChunkList(HashMap<String, Object> param);
}
