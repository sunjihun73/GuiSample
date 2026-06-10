package kr.co.jihun.guisample.service;

import kr.co.jihun.guisample.mapper.CategoryMasterMapper;
import kr.co.jihun.guisample.vo.CategoryMasterVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CategoryMasterService
{
    private static final String DEFAULT_USER_ID = "sunjeehun";

    private final CategoryMasterMapper categoryMasterMapper;

    public List<CategoryMasterVO> selectCategoryMasterList(HashMap<String, Object> param)
    {
        return categoryMasterMapper.selectCategoryMasterList(param);
    }

    public int countCategoryMaster(HashMap<String, Object> param)
    {
        return categoryMasterMapper.countCategoryMaster(param);
    }

    public CategoryMasterVO createCategoryMaster(CategoryMasterVO categoryMaster)
    {
        // category_id 는 GUID 로 서비스에서 생성
        categoryMaster.setCategoryId(UUID.randomUUID().toString());
        // 생성자/수정자는 일단 고정값으로 입력 (create_date/update_date 는 NOW() 로 매퍼에서 처리)
        categoryMaster.setCreateUserId(DEFAULT_USER_ID);
        categoryMaster.setUpdateUserId(DEFAULT_USER_ID);

        categoryMasterMapper.insertCategoryMaster(categoryMaster);
        return categoryMaster;
    }
}
