package com.example.demo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class UserBean {
    private int id;
    private String userName;
    private String displayName;
    private String email;
    private String passcode;
    private String errorMessage;

    @Autowired
    public UserBean() {
        
    }

    public UserBean dumpUser(UserBean toDump) {
        this.userName = toDump.userName;
        this.displayName = toDump.displayName;
        this.email = toDump.email;
        this.passcode = toDump.passcode;
        this.errorMessage = "";
        return this;
    }

    public String getErrorMessage() {
        return this.errorMessage;
    }

    public void setErrorMessage(String m) {
        this.errorMessage = m;
    }

    public void setId(int n) {
        this.id = n;
    } 

    public void setUserName(String s) {
        this.userName = s;
    }

    public void setDisplayName(String s) {
        this.displayName = s;
    }

    public void setEmail(String e) {
        this.email = e;
    }

    public void setPasscode(String p) {
        this.passcode = p;
    }


    public int getId() {
        return this.id;
    }

    public String getUserName() {
        return this.userName;
    }

    public String getDisplayName() {
        return this.displayName;
    }

    public String getEmail() {
        return this.email;
    }

    public String getPasscode () {
        return this.passcode;
    }
}
