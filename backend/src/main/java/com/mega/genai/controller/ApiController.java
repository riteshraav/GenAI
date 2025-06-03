package com.mega.genai.controller;

import com.mega.genai.model.Chat;
import com.mega.genai.repo.ChatRepository;
import com.mega.genai.service.GeminiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;

// api key from gemini AIzaSyBwqrAUxf0eiaeAL5gvp_uU_OifUyllLig
//api key from credentials AIzaSyBzP9I2QsUCAQA55asCj4Sdpn9YoCBEduw
@RestController
@RequestMapping("/api")
@CrossOrigin("*")
public class ApiController {

    @Autowired
    GeminiService geminiService;
    @Autowired
    private ChatRepository chatRepository;


    @PostMapping("/ask-gemini")
    public ResponseEntity<String> chatWithGemini(@RequestBody String prompt)
    {
        System.out.println("ask gemini invoked with prompt " + prompt);
        try{
            String result =  geminiService.askGemini(prompt).block();
            return ResponseEntity.ok(result);
        }catch (Exception e)
        {
            System.out.println(e.getMessage());
            return  ResponseEntity.status(HttpStatus.MULTI_STATUS).body("nothing found");
        }

    }
    @PostMapping("/ask-gemini/context/{userId}/{id}")
    public ResponseEntity<Map<String, Object>> askGemini(@PathVariable String userId,@PathVariable String id, @RequestBody String prompt) throws IOException {
        Chat chat = chatRepository.findById(id).orElse(new Chat(id,userId,prompt));
        // Build full context prompt
        StringBuilder fullPrompt = new StringBuilder();
        for (Chat.Message msg : chat.getMessages()) {
            fullPrompt.append(msg.getText()).append("\n");
        }
        fullPrompt.append(prompt);

        // Get Gemini response
        String response = geminiService.askGeminiWithContext(fullPrompt.toString());

        // Append new messages to chat
        chat.getMessages().add(new Chat.Message("user", prompt));
        chat.getMessages().add(new Chat.Message("ai", response));
        chat.setLastUpdated(new Date());

        chatRepository.save(chat); // This overrides the existing document
        for (Chat.Message m : chat.getMessages())
        {
            System.out.println(m.getRole());
            System.out.println(m.getText());
        }
        Map<String, Object> result = Map.of(
                "candidates", List.of(
                        Map.of("content", Map.of("parts", List.of(Map.of("text", response))))
                )
        );

        return ResponseEntity.ok(result);
    }

    @PostMapping(value = "/ask-gemini/context/{userId}/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, Object>> askGemini(
            @PathVariable String userId,
            @PathVariable String id,
            @RequestPart("prompt") String prompt,
            @RequestPart(value = "file", required = false) MultipartFile file) throws IOException {

        System.out.println("ask gemini for pdf");
        // Extract PDF content if provided
        String pdfText = "";
        if (file != null && !file.isEmpty()) {
            System.out.println("pdfText is given");
            pdfText = geminiService.extractTextFromPdf(file);
        }

        // Load or create new chat
        Chat chat = chatRepository.findById(id).orElse(new Chat(id, userId, prompt));

        // Build full context (chat + pdf + prompt)
        StringBuilder fullPrompt = new StringBuilder();
        for (Chat.Message msg : chat.getMessages()) {
            fullPrompt.append(msg.getText()).append("\n");
        }
        if (!pdfText.isBlank()) {
            System.out.println("pdf text is not blank");
            fullPrompt.append("Context from uploaded document:\n").append(pdfText).append("\n");
        }
        fullPrompt.append("User: ").append(prompt);

        // Get response
        String response = geminiService.askGeminiWithContextForPdf(fullPrompt.toString());

        // Save interaction to chat
        chat.getMessages().add(new Chat.Message("user", prompt));
        chat.getMessages().add(new Chat.Message("ai", response));
        chat.setLastUpdated(new Date());
        chatRepository.save(chat);

        Map<String, Object> result = Map.of(
                "candidates", List.of(
                        Map.of("content", Map.of("parts", List.of(Map.of("text", response))))
                )
        );

        return ResponseEntity.ok(result);
    }
    @PostMapping(value = "/ask-gemini/image/{userId}/{chatId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, Object>> askGeminiWithImage(
            @PathVariable String userId,

            @PathVariable String chatId,
            @RequestPart("prompt") String prompt,
            @RequestPart(value = "file" , required = false) MultipartFile image) throws IOException {
        System.out.println("image gemini called");
        String base64Image ="";
        // Convert image to base64
        if( image != null && !image.isEmpty())
            base64Image = Base64.getEncoder().encodeToString(image.getBytes());

        // Build full prompt context (can add chat history if needed)
        String fullPrompt = "User: " + prompt;

        // Ask Gemini with image
        String response;
        if(!Objects.equals(base64Image, ""))
            response = geminiService.askGeminiWithImage(fullPrompt, base64Image, image.getContentType());
        else {
            response = geminiService.askGeminiWithContext(fullPrompt);
        }
        // Store message (optional)
        Chat chat = chatRepository.findById(chatId).orElse(new Chat(chatId, userId, prompt));
        chat.getMessages().add(new Chat.Message("user", prompt));
        chat.getMessages().add(new Chat.Message("ai", response));
        chat.setLastUpdated(new Date());
        chatRepository.save(chat);

        // Return Gemini response
        Map<String, Object> result = Map.of(
                "candidates", List.of(
                        Map.of("content", Map.of("parts", List.of(Map.of("text", response))))
                )
        );
        return ResponseEntity.ok(result);
    }


    @GetMapping("/chat-history")
    public List<Chat> getAllChats() {
        return List.of();
    }
    @GetMapping("/get/ask-gemini")
    public ResponseEntity<String> getChat()
    {
        System.out.println("ask gemini invoked with prompt " + "who is prime minister of india");
        try{
            String result =  geminiService.askGemini( "who is prime minister of india").block();
            return ResponseEntity.ok(result);
        }catch (Exception e)
        {
            System.out.println(e.getMessage());
            return  ResponseEntity.status(HttpStatus.MULTI_STATUS).body("nothing found");
        }

    }

}


