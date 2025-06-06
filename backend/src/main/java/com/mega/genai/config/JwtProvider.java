package com.mega.genai.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.security.core.Authentication;

import javax.crypto.SecretKey;
import java.util.Date;

public class JwtProvider {

    static SecretKey key = Keys.hmacShaKeyFor(JwtConstant.SECRET_KEY.getBytes());
    public static String generateJwtToken(Authentication auth){
        String jwt = Jwts.builder().setIssuedAt(new Date())
                .setExpiration(new Date(new Date().getTime() + 1000*60*5))
                .claim("email",auth.getName())
                .signWith(key)
                .compact();
        return jwt;
    }
    public static String generateRefreshToken(Authentication auth){
        String jwt = Jwts.builder().setIssuedAt(new Date())
                .setExpiration(new Date(new Date().getTime() + 1000*60*60*24*7))
                .claim("email",auth.getName())
                .signWith(key)
                .compact();
        return jwt;
    }
    public static String getEmailFromToken(String jwt)
    {
        Claims claims = Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(jwt).getBody();
        return String.valueOf(claims.get("email"));
    }
}
