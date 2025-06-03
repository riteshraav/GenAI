package com.mega.genai.service;

import com.mega.genai.model.User;
import com.mega.genai.repo.UserRepo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepo userRepo;
//
//    public boolean registerUser(User user)
//    {
//        try{
//
//        }
//    }
}
