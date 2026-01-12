package com.example.demo;

import java.util.ArrayList;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;



@Controller
// @RequestMapping("/api")
public class HomeController {
    private final UserService service;
    private final DataService dataService;
    private final BlogController blogService;
    public UserBean currActiveUser = null;

    @Autowired
    public HomeController(UserService service, DataService dataService, BlogController blogService) {
        this.service = service;
        this.dataService = dataService;
        this.blogService = blogService;
    }

    @GetMapping("/")
    public String Hello(@RequestParam(name="name", defaultValue="hello") String name, Model model) {
        model.addAttribute("name", name);
        return "index";
    }

    @GetMapping("/user-entry")
    public String UserForm(Model model) throws Exception {
        UserBean currUser = new UserBean();
        service.setCurrId(service.genId(currUser, dataService.userList));
        System.out.println("CurrID: " + service.getCurrId());
        currUser.setErrorMessage(service.errorMessage);
        
        dataService.getUserList();
        model.addAttribute("user", currUser);
        // 
        // 
        return "userform";
    }

    @GetMapping("/email-sent")
    public String EmailSend(Model model) {
        UserBean user = service.userMap.get(service.currId);
        service.sendMail(user.getEmail(), "Hi test!", "Hi test!");
        return "emailsend";
    }

    @PostMapping("/user-entry")
    public String postUserForm(@ModelAttribute UserBean submittedUser, Model model) throws Exception {
        // ok: this will get the current user, dump the submitted info into it, and then wrap it up as 
        //   a new userbean object for use
        service.errorMessage = "";
        
        UserBean user = service.userMap.get(service.currId).dumpUser(submittedUser);
        user.setErrorMessage("");
        
        ArrayList<UserBean> userList = dataService.userList;
        user.setDisplayName(submittedUser.getDisplayName());
        for (UserBean u : userList) {
            if (u.getId() == user.getId()) {
                System.out.println("Reloaded page: user already in use");
                service.errorMessage = "Reloaded page - user id already in use!";
                return "redirect:/user-entry";
            } 
        }
        
        model.addAttribute("user", user);
        dataService.writeUser(user);
        
        return "confirmuser";
    }

    @GetMapping("/post-entry")
    public String getMethodName(Model model) throws Exception{
        if (currActiveUser == null) {
            return "oops";
        }
        BlogBean blog = new BlogBean();
        blog.setUser(currActiveUser);
        blogService.currBlog = blog;
        blogService.genId();

        
        model.addAttribute("user", currActiveUser);
        model.addAttribute("post", blogService.currBlog);
        return "postform";
    }
    
    @PostMapping("/post-entry")
    public String postMethodName(@ModelAttribute BlogBean submittedPost, Model model) throws Exception {
    
        blogService.blogList.add(submittedPost);
        blogService.writeUserList();
        model.addAttribute("post", submittedPost);
        return "postdisplay";
    }

    @GetMapping("/sign-in")
    public String signIn(Model model) {
        UserBean user = new UserBean();
        model.addAttribute("user", user);
        return "signin";
    }

    @PostMapping("/sign-in")
    public String postSignIn(@ModelAttribute UserBean submittedUser, Model model) throws Exception {
        dataService.getUserList();
        UserBean u = service.findUser(submittedUser, dataService.userList);
        if (u == null) {
            return "oops";
        }
        currActiveUser = u;
        
        model.addAttribute("user", currActiveUser);
        return "index";
    }
    

    // how to handle this?
    //   1. make a method for handling signing in in userService - it should return null on incorrect id and the correct user on valid id
    //      - method will simply search the userlist for userName and make sure passwords match
    //      - if this is null, make some error page
    //   2. pass 2 model
    //   3. catch on post, and make submittedUser the currActiveUser
    //   4. then it's active!
    
    
    
}
