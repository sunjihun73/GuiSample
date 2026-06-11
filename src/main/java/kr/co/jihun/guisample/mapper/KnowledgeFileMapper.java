package kr.co.jihun.guisample.mapper;

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
}
