package com.example.demo;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;;;


@Controller
@RequestMapping("/api")
public class HomeController {
    @GetMapping("/")
    public String Hello(Model model) {
        model.addAttribute("name", "Hello");
        return "index";
    }

}
