package kr.co.jihun.guisample.controller.user;

import kr.co.jihun.guisample.service.ProjectMasterService;
import kr.co.jihun.guisample.vo.ProjectMasterDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/user/project")
@RequiredArgsConstructor
public class ProjectMasterRestController
{
    private final ProjectMasterService projectMasterService;

    @GetMapping("/projects")
    public Map<String, Object> projectList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int rows,
            @RequestParam(required = false) String projectName)
    {
        HashMap<String, Object> param = new HashMap<>();
        if (projectName != null && !projectName.isEmpty())
        {
            param.put("projectName", projectName);
        }

        int totalRecords = projectMasterService.countProjectMaster(param);
        int totalPages   = totalRecords == 0 ? 0 : (int) Math.ceil((double) totalRecords / rows);

        param.put("startRow", (page - 1) * rows);
        param.put("pageSize", rows);

        List<ProjectMasterDTO> list = projectMasterService.selectProjectMasterList(param);

        Map<String, Object> result = new HashMap<>();
        result.put("page",    page);
        result.put("total",   totalPages);
        result.put("records", totalRecords);
        result.put("rows",    list);
        return result;
    }

    @PostMapping("/projects")
    public Map<String, Object> saveProject(@RequestBody ProjectMasterDTO projectMaster)
    {
        Map<String, Object> result = new HashMap<>();
        try
        {
            ProjectMasterDTO saved = projectMasterService.createProjectMaster(projectMaster);
            result.put("success",   true);
            result.put("projectId", saved.getProjectId());
        }
        catch (Exception e)
        {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @PatchMapping("/projects/{projectId}")
    public Map<String, Object> updateProject(
            @PathVariable String projectId,
            @RequestBody ProjectMasterDTO projectMaster)
    {
        Map<String, Object> result = new HashMap<>();
        try
        {
            projectMaster.setProjectId(projectId);
            int updated = projectMasterService.updateProjectMaster(projectMaster);
            result.put("success",   updated > 0);
            result.put("projectId", projectId);
            if (updated == 0)
            {
                result.put("message", "수정 대상 프로젝트를 찾을 수 없습니다.");
            }
        }
        catch (Exception e)
        {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }
}