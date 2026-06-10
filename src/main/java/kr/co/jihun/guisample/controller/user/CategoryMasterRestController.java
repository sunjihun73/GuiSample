package kr.co.jihun.guisample.controller.user;

import kr.co.jihun.guisample.service.CategoryMasterService;
import kr.co.jihun.guisample.vo.CategoryMasterVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/user/category")
@RequiredArgsConstructor
public class CategoryMasterRestController
{
    private final CategoryMasterService categoryMasterService;

    @GetMapping("/categories")
    public Map<String, Object> categoryList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int rows)
    {
        HashMap<String, Object> param = new HashMap<>();

        int totalRecords = categoryMasterService.countCategoryMaster(param);
        int totalPages   = totalRecords == 0 ? 0 : (int) Math.ceil((double) totalRecords / rows);

        param.put("startRow", (page - 1) * rows);
        param.put("pageSize", rows);

        List<CategoryMasterVO> list = categoryMasterService.selectCategoryMasterList(param);

        Map<String, Object> result = new HashMap<>();
        result.put("page",    page);
        result.put("total",   totalPages);
        result.put("records", totalRecords);
        result.put("rows",    list);
        return result;
    }

    @PostMapping("/categories")
    public Map<String, Object> saveCategory(@RequestBody CategoryMasterVO categoryMaster)
    {
        Map<String, Object> result = new HashMap<>();
        try
        {
            CategoryMasterVO saved = categoryMasterService.createCategoryMaster(categoryMaster);
            result.put("success",    true);
            result.put("categoryId", saved.getCategoryId());
        }
        catch (Exception e)
        {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }
}
