package com.mega.genai.repo;

import com.mega.genai.model.Chat;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatRepository extends MongoRepository<Chat, String> {
    Chat findFirstByOrderByLastUpdatedDesc();
}
