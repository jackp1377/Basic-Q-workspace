package com.example.demo;

import java.io.FileReader;
import java.io.FileWriter;
import java.lang.reflect.Type;
import java.util.ArrayList;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

@Service
public class DataService {
    ArrayList<UserBean> userList = new ArrayList<>();
    ArrayList<BlogBean> blogService = new ArrayList<>();
    
    @Autowired
    public DataService() {
        
    }

    public void writeUser(UserBean user) throws Exception {
        this.getUserList();
        userList.add(user);
        System.out.println("UserList (at write): " + userList);
        this.writeUserArray();
        System.out.println("UserList (post write): " + userList);
    }

    public void getUserList() throws Exception {
        Gson gson = new Gson();
        Type listType = new TypeToken<ArrayList<UserBean>>(){}.getType();
        userList = gson.fromJson(new FileReader("sample-1\\demo\\src\\main\\resources\\storage\\users.json"), listType);
        if (userList == null) {
            userList = new ArrayList<UserBean>();
        }
        // System.out.println("UserList: " + userList);
    }

    public void writeUserArray() throws Exception{
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        FileWriter userWriter = new FileWriter("sample-1\\demo\\src\\main\\resources\\storage\\users.json");
        userWriter.append("[\n");
        for (int i = 0; i < userList.size(); i++) {
            gson.toJson(userList.get(i), userWriter);
            if (i == userList.size() - 1) {
                userWriter.append("\n");
            } else {
                userWriter.append(",\n");
            }
        }
        userWriter.append("]");
        userWriter.close();
    }
}
