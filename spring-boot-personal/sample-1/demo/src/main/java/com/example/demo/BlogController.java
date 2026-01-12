package com.example.demo;

import java.io.FileReader;
import java.io.FileWriter;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

@Service
public class BlogController {
    public ArrayList<BlogBean> blogList = new ArrayList<>();
    public BlogBean currBlog;
    Random rand = new Random();

    @Autowired
    public BlogController() {

    }

    public void getBlogList() throws Exception{
        Gson gson = new Gson();
        Type listType = new TypeToken<ArrayList<BlogBean>>(){}.getType();
        FileReader blogFile = new FileReader("sample-1\\demo\\src\\main\\resources\\storage\\blogposts.json");
        blogList = gson.fromJson(blogFile, listType);
        if (blogList == null) {
            blogList = new ArrayList<>();
        }
        
    }

    public void writeUserList() throws Exception {
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        FileWriter blogWriter = new FileWriter("sample-1\\demo\\src\\main\\resources\\storage\\blogposts.json");
        blogWriter.append("[\n");
        for (int i = 0; i < blogList.size(); i++) {
            gson.toJson(blogList.get(i), blogWriter);
            if (i == blogList.size() - 1) {
                blogWriter.append("\n");
            } else {
                blogWriter.append(",\n");
            }
        }
        blogWriter.append("]");
        blogWriter.close();
    }

    public void genId() throws Exception {
        this.getBlogList();
        int newId = rand.nextInt(100000000);
        Boolean used = false;
        for (BlogBean b : blogList) {
            if (newId == b.getId()) {
                used = true;
            }
        }

        if (used) {
            genId();
        } else {
            currBlog.setId(newId);
        }
    }


}
