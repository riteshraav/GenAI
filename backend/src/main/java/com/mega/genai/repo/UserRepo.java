package com.mega.genai.repo;

import com.mega.genai.model.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepo extends MongoRepository<User, String> {
        User findByEmail(String email);
}
