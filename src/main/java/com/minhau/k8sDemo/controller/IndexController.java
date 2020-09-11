package com.minhau.k8sDemo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.text.SimpleDateFormat;
import java.util.Date;

@RestController
public class IndexController {

    private static final SimpleDateFormat YYYY_MM_DD_HH_MM_SS = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    @GetMapping("/index")
    public String helloWorldK8s(){
        return "Hello World k8s 当前时间为： " + YYYY_MM_DD_HH_MM_SS.format(new Date());
    }
}
