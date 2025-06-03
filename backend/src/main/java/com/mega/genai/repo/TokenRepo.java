package com.mega.genai.repo;

import com.mega.genai.model.Token;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TokenRepo extends MongoRepository<Token,String> {
    String findByToken(String token);
    boolean existsByToken(String token);
    void deleteByToken(String token);
}
