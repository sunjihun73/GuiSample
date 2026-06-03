package kr.co.jihun.guisample.service;

import kr.co.jihun.guisample.mapper.ProjectMasterMapper;
import kr.co.jihun.guisample.vo.ProjectMasterDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProjectMasterService
{
    private static final String DEFAULT_USER_ID = "sunjeehun";

    private final ProjectMasterMapper projectMasterMapper;

    public List<ProjectMasterDTO> selectProjectMasterList(HashMap<String, Object> param)
    {
        return projectMasterMapper.selectProjectMasterList(param);
    }

    public int countProjectMaster(HashMap<String, Object> param)
    {
        return projectMasterMapper.countProjectMaster(param);
    }

    public ProjectMasterDTO createProjectMaster(ProjectMasterDTO projectMaster)
    {
        // project_id 는 GUID 로 서비스에서 생성
        projectMaster.setProjectId(UUID.randomUUID().toString());
        // 생성자/수정자는 일단 고정값으로 입력 (create_date/update_date 는 NOW() 로 매퍼에서 처리)
        projectMaster.setCreateUserId(DEFAULT_USER_ID);
        projectMaster.setUpdateUserId(DEFAULT_USER_ID);

        projectMasterMapper.insertProjectMaster(projectMaster);
        return projectMaster;
    }
}