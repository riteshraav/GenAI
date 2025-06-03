package com.mega.genai.controller;


import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mega.genai.service.TogetherAiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/generate")
public class TextGenerationController {

    @Autowired
    private TogetherAiService aiService;
    @PostMapping
    public Mono<String> generate(@RequestBody String prompt) {
        System.out.println("generate executed");

        return aiService.generateText(prompt)
                .map(json -> {
                    try {
                        ObjectMapper mapper = new ObjectMapper();
                        JsonNode root = mapper.readTree(json);
                        return root.path("choices").get(0).path("message").path("content").asText();
                    } catch (Exception e) {
                        e.printStackTrace();
                        return "Error parsing AI response.";
                    }
                });
    }


}

