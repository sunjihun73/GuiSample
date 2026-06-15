package kr.co.jihun.guisample.mapper;

import kr.co.jihun.guisample.dto.ProjectMasterDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.HashMap;
import java.util.List;

@Mapper
public interface ProjectMasterMapper
{
    List<ProjectMasterDTO> selectProjectMasterList(HashMap<String, Object> param);

    ProjectMasterDTO selectProjectMaster(HashMap<String, Object> param);

    int countProjectMaster(HashMap<String, Object> param);

    int insertProjectMaster(ProjectMasterDTO projectMaster);

    int updateProjectMaster(ProjectMasterDTO projectMaster);
}