package com.example.demo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;


@Service
public class UserService {

    Random rand = new Random();
    HashMap<Integer, UserBean> userMap = new HashMap<>();
    public int currId;
    private JavaMailSender mailSender;
    public String errorMessage;

    public UserService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }
    
    public int getCurrId() {
        return currId;
    }

    public void setCurrId(int n) {
        this.currId = n;
    } 

  
    public void sendMail(String to, String subject, String body) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("tusansan333@gmail.com");
        message.setTo(to);
        message.setSubject(subject);
        message.setText(body);

        mailSender.send(message);
    }

    public int genId(UserBean bean, ArrayList<UserBean> userList) {
        int newInt = rand.nextInt(0, 1000000000);
        boolean unused = false;
        while (!unused) {
            unused = true;
            for (UserBean user : userList) {
                if (user.getId() == newInt) {
                    unused = false;
                } 
            }
            if (!unused) {
                newInt = rand.nextInt();
            }
        }
        bean.setId(newInt);
        userMap.put(newInt, bean);
        return newInt;
    }

    public UserBean findUser(UserBean u, ArrayList<UserBean> list) {
        Boolean match = false;
        UserBean finalUser = null;
        for (UserBean user : list) {
            if (user.getUserName().equals(u.getUserName())) {
                if (user.getPasscode().equals(u.getPasscode())) {
                    match = true;
                    finalUser = user;
                }
            }
        }

        if (match) {
            return finalUser;
        } else {
            return null;
        }
    }
}
