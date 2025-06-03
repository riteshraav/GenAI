package com.mega.genai.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.fasterxml.jackson.databind.node.ObjectNode;
import okhttp3.*;

import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Base64;

@Service
public class TogetherImageService {
    private static final String API_URL = "https://api.together.xyz/v1/images/generations";
    private static final String API_KEY = "e9fa85e37ae3b15c79194cbb6ff2acc17ed59555dbe7ecddda3b70005fa92ab6"; // Load securely from properties or env

    private final OkHttpClient client = new OkHttpClient();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public byte[] generateImage(String prompt) throws IOException {
        // Build JSON body
        ObjectNode body = objectMapper.createObjectNode();
        body.put("model", "black-forest-labs/FLUX.1-dev");
        body.put("prompt", prompt);
        body.put("steps", 28);
        body.put("n", 1);
        body.put("response_format", "b64_json");
        body.putArray("stop");

        String json = body.toString();

        // Build request body
        RequestBody requestBody = RequestBody.create(
                json,
                MediaType.get("application/json; charset=utf-8")
        );

        // Build the request
        Request request = new Request.Builder()
                .url(API_URL)
                .addHeader("Authorization", "Bearer " + API_KEY)
                .post(requestBody)
                .build();

        // Execute request
        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                throw new IOException("Unexpected API error: " + response.body().string());
            }

            String responseBody = response.body().string();
            String base64 = objectMapper.readTree(responseBody)
                    .path("data").get(0)
                    .path("b64_json").asText();

            return Base64.getDecoder().decode(base64);
        }
    }
}