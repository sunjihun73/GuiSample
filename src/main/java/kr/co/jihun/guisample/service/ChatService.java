package kr.co.jihun.guisample.service;

import kr.co.jihun.guisample.dto.ChatDetailDTO;
import kr.co.jihun.guisample.dto.ChatMasterDTO;
import kr.co.jihun.guisample.mapper.ChatDetailMapper;
import kr.co.jihun.guisample.mapper.ChatMasterMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.UUID;

/**
 * 채팅 세션(chat_master) + 대화 메시지(chat_detail) 비즈니스 계층.
 *
 * <p>설계(00_architect_design.md §8) 원칙:
 * <ul>
 *   <li>세션 소유자/감사 컬럼은 인증 도입 전까지 고정값 {@link #DEFAULT_USER_ID}.</li>
 *   <li>저장 메서드는 각각 독립된 짧은 트랜잭션 — 스트림 전체를 트랜잭션으로 감싸지 않는다.</li>
 *   <li>날짜(create/update_date)는 mapper XML 의 NOW() 가 처리.</li>
 * </ul>
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class ChatService
{
    /** 인증 미도입 상태의 고정 사용자 식별자 (owner/create/update user). */
    public static final String DEFAULT_USER_ID = "sunjeehun";

    /** 신규 세션 기본 제목. */
    public static final String DEFAULT_TITLE = "새로운채팅";

    private final ChatMasterMapper chatMasterMapper;
    private final ChatDetailMapper chatDetailMapper;

    /**
     * 새 채팅 세션을 생성한다.
     *
     * @param title 세션 제목. null/공백이면 "새로운채팅".
     * @return 생성된 세션 DTO(생성 직후 상태 — createDate 는 미조회 상태로 null 일 수 있음)
     */
    @Transactional
    public ChatMasterDTO createSession(String title)
    {
        ChatMasterDTO dto = new ChatMasterDTO();
        dto.setChatSessionId(UUID.randomUUID().toString());
        dto.setChatTitleName((title == null || title.isBlank()) ? DEFAULT_TITLE : title.trim());
        dto.setChatOwnerUserId(DEFAULT_USER_ID);
        dto.setCreateUserId(DEFAULT_USER_ID);
        dto.setUpdateUserId(DEFAULT_USER_ID);

        chatMasterMapper.insertChatMaster(dto);
        return dto;
    }

    /** 세션 목록 조회 (create_date DESC). 페이징 param(startRow/pageSize)은 호출측에서 세팅. */
    public List<ChatMasterDTO> selectSessions(HashMap<String, Object> param)
    {
        return chatMasterMapper.selectChatMasterList(param);
    }

    /** 세션 전체 건수. */
    public int countSessions(HashMap<String, Object> param)
    {
        return chatMasterMapper.countChatMaster(param);
    }

    /** 세션별 대화 조회 (chat_content_id ASC). */
    public List<ChatDetailDTO> selectMessages(String sessionId)
    {
        return chatDetailMapper.selectChatDetailList(sessionId);
    }

    /** 세션 단건 조회 (없으면 null). */
    public ChatMasterDTO selectSession(String sessionId)
    {
        return chatMasterMapper.selectChatMaster(sessionId);
    }

    /**
     * 세션 제목이 아직 기본값({@link #DEFAULT_TITLE})일 때만 새 제목으로 1회 자동 변경한다.
     * <p>사용자가 이미 수동으로 바꾼 제목은 건드리지 않는 안전장치. 독립 트랜잭션.
     *
     * @param sessionId 대상 세션
     * @param newTitle  적용할 제목(공백이면 무시)
     * @return 실제로 변경했으면 true
     */
    @Transactional
    public boolean autoRenameTitleIfDefault(String sessionId, String newTitle)
    {
        if (sessionId == null || sessionId.isBlank() || newTitle == null || newTitle.isBlank())
        {
            return false;
        }

        ChatMasterDTO session = chatMasterMapper.selectChatMaster(sessionId);
        if (session == null || !DEFAULT_TITLE.equals(session.getChatTitleName()))
        {
            // 세션 없음 or 이미 수동 변경됨 → 건드리지 않음
            return false;
        }

        int updated = chatMasterMapper.updateChatMasterTitle(sessionId, newTitle.trim(), DEFAULT_USER_ID);
        return updated > 0;
    }

    /**
     * user 발화 저장 (role=user, model/토큰 null). 스트림 시작 전 동기 커밋.
     * 독립 트랜잭션.
     */
    @Transactional
    public void saveUserMessage(String sessionId, String content)
    {
        ChatDetailDTO dto = new ChatDetailDTO();
        dto.setChatSessionId(sessionId);
        dto.setChatContent(content);
        dto.setRole("user");
        dto.setCreateUserId(DEFAULT_USER_ID);
        dto.setUpdateUserId(DEFAULT_USER_ID);

        chatDetailMapper.insertChatDetail(dto);
    }

    /**
     * assistant 발화 저장 (role=assistant, model/토큰 포함). 스트림 완료 후 커밋.
     * 독립 트랜잭션. usage 미확보 시 promptTokens/completionTokens 는 null 그대로 저장.
     */
    @Transactional
    public void saveAssistantMessage(String sessionId, String content, String model,
                                     Integer promptTokens, Integer completionTokens)
    {
        ChatDetailDTO dto = new ChatDetailDTO();
        dto.setChatSessionId(sessionId);
        dto.setChatContent(content);
        dto.setRole("assistant");
        dto.setModel(model);
        dto.setPromptTokens(promptTokens);
        dto.setCompletionTokens(completionTokens);
        dto.setCreateUserId(DEFAULT_USER_ID);
        dto.setUpdateUserId(DEFAULT_USER_ID);

        chatDetailMapper.insertChatDetail(dto);
    }
}
