package com.mega.genai.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.MediaType;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Service
public class GeminiService {

    private final WebClient webClient;
    @Value("${gemini.api.key}")
    String apikey;
    public GeminiService(@Value("${gemini.api.key}") String apiKey) {
        this.webClient = WebClient.builder()
                .baseUrl("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent")
                .defaultHeader(HttpHeaders.CONTENT_TYPE, org.springframework.http.MediaType.APPLICATION_JSON_VALUE)
                .defaultHeader("x-goog-api-key", apiKey)
                .build();
    }

    public Mono<String> askGemini(String prompt) {
        Map<String, Object> requestBody = Map.of(
                "contents", List.of(Map.of(
                        "parts", List.of(Map.of("text", prompt))
                ))
        );

        return webClient.post()
                .bodyValue(requestBody)
                .retrieve()
                .bodyToMono(String.class);
    }
    public String askGeminiWithContext(String prompt) throws IOException {
        OkHttpClient client = new OkHttpClient();

        // Safely construct JSON using Jackson
        ObjectMapper mapper = new ObjectMapper();

        ObjectNode part = mapper.createObjectNode();
        part.put("text", prompt);

        ArrayNode parts = mapper.createArrayNode();
        parts.add(part);

        ObjectNode content = mapper.createObjectNode();
        content.set("parts", parts);

        ArrayNode contents = mapper.createArrayNode();
        contents.add(content);

        ObjectNode body = mapper.createObjectNode();
        body.set("contents", contents);

        String json = mapper.writeValueAsString(body);

        // Use the allowed Gemini model version
        String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=" + apikey;

        Request request = new Request.Builder()
                .url(url)
                .post(RequestBody.create(json, MediaType.parse("application/json")))
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                String errorBody = response.body() != null ? response.body().string() : "No body";
                throw new IOException("Unexpected code: " + response.code() + ", body: " + errorBody);
            }

            JsonNode root = mapper.readTree(response.body().string());
            return root.get("candidates").get(0).get("content").get("parts").get(0).get("text").asText();
        }
    }

    public String askGeminiWithContextForPdf(String prompt) throws IOException {
        OkHttpClient client = new OkHttpClient();
        ObjectMapper mapper = new ObjectMapper();

        ObjectNode part = mapper.createObjectNode();
        part.put("text", prompt);

        ArrayNode parts = mapper.createArrayNode();
        parts.add(part);

        ObjectNode content = mapper.createObjectNode();
        content.set("parts", parts);

        ArrayNode contents = mapper.createArrayNode();
        contents.add(content);

        ObjectNode body = mapper.createObjectNode();
        body.set("contents", contents);

        String json = mapper.writeValueAsString(body);

        String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=" + apikey;

        Request request = new Request.Builder()
                .url(url)
                .post(RequestBody.create(json, MediaType.parse("application/json")))
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                String errorBody = response.body() != null ? response.body().string() : "No body";
                throw new IOException("Unexpected code: " + response.code() + ", body: " + errorBody);
            }

            JsonNode root = mapper.readTree(response.body().string());
            return root.get("candidates").get(0).get("content").get("parts").get(0).get("text").asText();
        }
    }

    public String extractTextFromPdf(MultipartFile file) throws IOException {
        try (PDDocument document = PDDocument.load(file.getInputStream())) {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document);
        }
    }
//    public String askGeminiWithContextForPdfAndImage(String prompt, String imageBase64) throws IOException {
//        OkHttpClient client = new OkHttpClient();
//        ObjectMapper mapper = new ObjectMapper();
//
//        // Create the parts array for multimodal
//        ArrayNode parts = mapper.createArrayNode();
//
//        // Include image if available
//        if (!imageBase64.isBlank()) {
//            ObjectNode imageNode = mapper.createObjectNode();
//            ObjectNode inlineData = mapper.createObjectNode();
//            inlineData.put("mimeType", "image/jpeg"); // or "image/png"
//            inlineData.put("data", imageBase64);
//            imageNode.set("inlineData", inlineData);
//            parts.add(imageNode);
//        }
//
//        // Add the prompt as a text part
//        ObjectNode textNode = mapper.createObjectNode();
//        textNode.put("text", prompt);
//        parts.add(textNode);
//
//        // Build content object
//        ObjectNode content = mapper.createObjectNode();
//        content.set("parts", parts);
//
//        // Final JSON body
//        ArrayNode contents = mapper.createArrayNode();
//        contents.add(content);
//
//        ObjectNode body = mapper.createObjectNode();
//        body.set("contents", contents);
//
//        String json = mapper.writeValueAsString(body);
//
//        // Send to Gemini endpoint
//        String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=" + apikey;
//
//        Request request = new Request.Builder()
//                .url(url)
//                .post(RequestBody.create(json, MediaType.parse("application/json")))
//                .build();
//
//        try (Response response = client.newCall(request).execute()) {
//            if (!response.isSuccessful()) {
//                String errorBody = response.body() != null ? response.body().string() : "No body";
//                throw new IOException("Unexpected code: " + response.code() + ", body: " + errorBody);
//            }
//
//            JsonNode root = mapper.readTree(response.body().string());
//            return root.get("candidates").get(0).get("content").get("parts").get(0).get("text").asText();
//        }
//    }
public String askGeminiWithImage(String prompt, String base64Image, String mimeType) throws IOException {
    OkHttpClient client = new OkHttpClient();
    ObjectMapper mapper = new ObjectMapper();

    // Create parts array
    ArrayNode parts = mapper.createArrayNode();

    // Add image
    ObjectNode imageNode = mapper.createObjectNode();
    ObjectNode inlineData = mapper.createObjectNode();
    inlineData.put("mimeType", mimeType); // example: image/png or image/jpeg
    inlineData.put("data", base64Image);
    imageNode.set("inlineData", inlineData);
    parts.add(imageNode);

    // Add prompt
    ObjectNode textNode = mapper.createObjectNode();
    textNode.put("text", prompt);
    parts.add(textNode);

    // Wrap into content and contents
    ObjectNode content = mapper.createObjectNode();
    content.set("parts", parts);

    ArrayNode contents = mapper.createArrayNode();
    contents.add(content);

    ObjectNode body = mapper.createObjectNode();
    body.set("contents", contents);

    String json = mapper.writeValueAsString(body);

    // Gemini API call
    Request request = new Request.Builder()
            .url("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=" + apikey)
            .post(RequestBody.create(json, MediaType.parse("application/json")))
            .build();

    try (Response response = client.newCall(request).execute()) {
        if (!response.isSuccessful()) {
            throw new IOException("Error: " + response.code() + ", " + response.body().string());
        }
        JsonNode root = mapper.readTree(response.body().string());
        return root.get("candidates").get(0).get("content").get("parts").get(0).get("text").asText();
    }
}

}


