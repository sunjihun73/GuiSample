package kr.co.jihun.guisample.mapper;

import kr.co.jihun.guisample.vo.CategoryMasterVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.HashMap;
import java.util.List;

@Mapper
public interface CategoryMasterMapper
{
    List<CategoryMasterVO> selectCategoryMasterList(HashMap<String, Object> param);

    int countCategoryMaster(HashMap<String, Object> param);

    int insertCategoryMaster(CategoryMasterVO categoryMaster);
}
