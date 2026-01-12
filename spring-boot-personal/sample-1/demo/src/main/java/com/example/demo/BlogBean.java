package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;

public class BlogBean {
    private String text;
    private String title;
    private UserBean user;
    private int id;
    private String errorMessage;
    
    @Autowired
    public BlogBean() {}

    public String getText() {
        return this.text;
    }
    
    public void setId(int n) {
        this.id = n;
    }

    public void setUser(UserBean u) {
        this.user = u;
    }

    public UserBean getUser() {
        return this.user;
    }
    public int getId() {
        return this.id;
    }

    public void setText(String t) {
        this.text = t;
    }

    public String getTitle() {
        return this.title;
    }

    public void setTitle(String t) {
        this.title = t;
    }

    public void setErrorMessage(String s) {
        this.errorMessage = s;
    }

    public String getErrorMessage() {
        return this.errorMessage;
    }
}
