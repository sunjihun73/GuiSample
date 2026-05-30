package kr.co.jihun.guisample.controller.user;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/user")
public class MainController
{
    @GetMapping({ "/", "/dashboard" })
    public String dashboard()
    {
        return "user/dashboard";
    }

    @GetMapping({ "/projects" })
    public String projects()
    {
        return "user/projects";
    }

    @GetMapping({ "/rag" })
    public String rag()
    {
        return "user/rag";
    }
}
