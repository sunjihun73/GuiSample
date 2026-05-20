package kr.co.jihun.guisample.service;

import kr.co.jihun.guisample.mapper.ProjectMasterMapper;
import kr.co.jihun.guisample.vo.ProjectMasterDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProjectMasterService
{
    private final ProjectMasterMapper projectMasterMapper;

    public List<ProjectMasterDTO> selectProjectMasterList(HashMap<String, Object> param)
    {
        return projectMasterMapper.selectProjectMasterList(param);
    }

    public int countProjectMaster(HashMap<String, Object> param)
    {
        return projectMasterMapper.countProjectMaster(param);
    }
}