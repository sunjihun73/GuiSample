package kr.co.jihun.guisample.mapper;

import kr.co.jihun.guisample.dto.ChatMasterDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.HashMap;
import java.util.List;

@Mapper
public interface ChatMasterMapper
{
    List<ChatMasterDTO> selectChatMasterList(HashMap<String, Object> param);

    int countChatMaster(HashMap<String, Object> param);

    int insertChatMaster(ChatMasterDTO chatMaster);

    ChatMasterDTO selectChatMaster(@Param("sessionId") String sessionId);

    int updateChatMasterTitle(@Param("sessionId") String sessionId,
                              @Param("title") String title,
                              @Param("updateUserId") String updateUserId);
}
