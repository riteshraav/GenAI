package com.mega.genai.model;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Getter
@Document(collection = "chat")
@RequiredArgsConstructor
public class Chat {
    @Id
    private String id;
    private String userId;
    private String title;
    private List<Message> messages = new ArrayList<>();
    private Date lastUpdated = new Date();
    public Chat(String id, String userId,String title)
    {
        this.id = id;
        this.userId = userId;
        this.title = title;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setMessages(List<Message> messages) {
        this.messages = messages;
    }

    public void setLastUpdated(Date lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

   public static class Message {
        private String role; // "user" or "ai"
        private String text;

       public Message(String user, String prompt) {
           this.role = user;
           this.text = prompt;
       }
       public  Message(){}

       public String getText() {
           return text;
       }

       public String getRole() {
           return role;
       }
   }
}



