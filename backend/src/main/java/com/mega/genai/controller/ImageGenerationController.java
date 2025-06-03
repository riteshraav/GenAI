package com.mega.genai.controller;

import com.mega.genai.service.TogetherImageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/images")
@CrossOrigin("*")

public class ImageGenerationController {
    @Autowired
    private TogetherImageService imageService;


    @PostMapping("/generate/{prompt}")
    public ResponseEntity<?> generateImage(@PathVariable String prompt) {
        System.out.println("generate image called");
        try {
            byte[] imageBytes = imageService.generateImage(prompt);
            if(imageBytes.length == 0)
            {
                return ResponseEntity.status(HttpStatus.CONFLICT).body("internal server error");
            }
            return ResponseEntity.ok()
                    .contentType(MediaType.IMAGE_PNG)
                    .body(imageBytes);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
