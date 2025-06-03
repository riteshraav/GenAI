package com.mega.genai.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.StringEntity;
import org.apache.hc.core5.http.ContentType;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
public class TogetherAIService {

    @Value("${together.ai.api.key}")
    private String apiKey;

    @Value("${together.ai.api.url}")
    private String apiUrl;

    private final ObjectMapper objectMapper = new ObjectMapper();

    public String generateImage(String prompt) throws IOException {
        try (CloseableHttpClient httpClient = HttpClients.createDefault()) {
            HttpPost request = new HttpPost(apiUrl);

            // Set headers
            request.setHeader("Authorization", "Bearer " + apiKey);
            request.setHeader("Content-Type", "application/json");

            // Create JSON payload
            String jsonPayload = objectMapper.writeValueAsString(new ImageRequest(prompt));
            request.setEntity(new StringEntity(jsonPayload, ContentType.APPLICATION_JSON));

            // Execute request
            try (CloseableHttpResponse response = httpClient.execute(request)) {
                int statusCode = response.getCode();
                if (statusCode == 200) {
                    JsonNode responseJson = objectMapper.readTree(response.getEntity().getContent());
                    return responseJson.get("data").get(0).get("url").asText();
                } else {
                    throw new IOException("Failed to generate image. Status code: " + statusCode);
                }
            }
        }
    }

    // Inner class to represent the request payload
    private static class ImageRequest {
        public String prompt;
        public String model = "black-forest-labs/FLUX.1-schnell";
        public int steps = 4;

        public ImageRequest(String prompt) {
            this.prompt = prompt;
        }
    }
}
