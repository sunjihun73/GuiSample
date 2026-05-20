package kr.co.jihun.guisample.controller.user;

import kr.co.jihun.guisample.service.ProjectMasterService;
import kr.co.jihun.guisample.vo.ProjectMasterDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/user/projects")
@RequiredArgsConstructor
public class ProjectMasterRestController
{
    private final ProjectMasterService projectMasterService;

    @GetMapping("/list.json")
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
}