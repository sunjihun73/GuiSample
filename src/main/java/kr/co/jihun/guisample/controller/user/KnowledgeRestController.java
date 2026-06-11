package kr.co.jihun.guisample.controller.user;

import kr.co.jihun.guisample.service.KnowledgeFileService;
import kr.co.jihun.guisample.vo.KnowledgeFileVO;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 지식파일 목록 REST 엔드포인트.
 */
@RestController
@RequestMapping("/user/knowledge")
@RequiredArgsConstructor
public class KnowledgeRestController
{
    private final KnowledgeFileService knowledgeFileService;

    /**
     * 지식파일 목록 조회. 전체 경로: GET /user/knowledge/knowledges
     * jqGrid 표준 응답 shape(page/total/records/rows)으로 반환한다.
     * categoryId 가 주어지면 해당 카테고리의 지식파일만 조회한다(왼쪽 카테고리 선택 연동).
     *
     * @param page       1-base 페이지 번호
     * @param rows       페이지당 행 수
     * @param categoryId (선택) 필터링할 카테고리 ID
     */
    @GetMapping("/knowledges")
    public Map<String, Object> knowledgeList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int rows,
            @RequestParam(required = false) String categoryId)
    {
        HashMap<String, Object> param = new HashMap<>();
        if (categoryId != null && !categoryId.isBlank())
        {
            param.put("categoryId", categoryId);
        }

        int totalRecords = knowledgeFileService.countKnowledgeFile(param);
        int totalPages   = totalRecords == 0 ? 0 : (int) Math.ceil((double) totalRecords / rows);

        param.put("startRow", (page - 1) * rows);
        param.put("pageSize", rows);

        List<KnowledgeFileVO> list = knowledgeFileService.selectKnowledgeFileList(param);

        Map<String, Object> result = new HashMap<>();
        result.put("page",    page);
        result.put("total",   totalPages);
        result.put("records", totalRecords);
        result.put("rows",    list);
        return result;
    }
}
