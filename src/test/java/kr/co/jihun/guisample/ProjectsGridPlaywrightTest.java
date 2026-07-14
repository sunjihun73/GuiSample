package kr.co.jihun.guisample;

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserType;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Playwright;
import com.microsoft.playwright.options.LoadState;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Playwright UI 테스트: 프로젝트 목록 화면 조회 시나리오.
 *
 * 외부에서 이미 기동 중인 애플리케이션(기본 http://localhost:8080)을 대상으로 한다.
 * 베이스 URL 은 시스템 프로퍼티 -Dapp.baseUrl 로 변경 가능.
 *
 * 시나리오:
 *   1. /user/projects 접속
 *   2. "조회" 버튼(#btnSearch) 클릭
 *   3. 프로젝트 그리드(#projectGrid)에 데이터 행(tr.jqgrow)이 조회되는지 확인
 */
class ProjectsGridPlaywrightTest
{
  private static final String BASE_URL =
      System.getProperty("app.baseUrl", "http://localhost:8080");

  private static Playwright playwright;
  private static Browser browser;

  @BeforeAll
  static void launchBrowser()
  {
    playwright = Playwright.create();
    browser = playwright.chromium()
        .launch(new BrowserType.LaunchOptions().setHeadless(false));
  }

  @AfterAll
  static void closeBrowser()
  {
    if (browser != null) browser.close();
    if (playwright != null) playwright.close();
  }

  @Test
  void 조회버튼_클릭시_프로젝트_그리드에_데이터가_조회된다()
  {
    Page page = browser.newPage();
    try
    {
      // 1. 프로젝트 목록 화면 접속
      page.navigate(BASE_URL + "/user/projects");
      page.waitForLoadState(LoadState.NETWORKIDLE);

      // 2. "조회" 버튼 클릭
      page.click("#btnSearch");

      // 3. 그리드에 데이터 행이 렌더링될 때까지 대기 (jqGrid 데이터 행 = tr.jqgrow)
      page.waitForSelector("#projectGrid tr.jqgrow",
          new Page.WaitForSelectorOptions().setTimeout(10_000));

      int rowCount = page.locator("#projectGrid tr.jqgrow").count();
      System.out.println("[Playwright] 조회된 프로젝트 행 수 = " + rowCount);

      assertTrue(rowCount > 0,
          "조회 버튼 클릭 후 프로젝트 그리드에 데이터가 1건 이상 조회되어야 한다");
    }
    finally
    {
      page.close();
    }
  }
}
