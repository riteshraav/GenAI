package com.mega.genai.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;
import io.jsonwebtoken.security.Keys;
import io.jsonwebtoken.Jwts;
import javax.crypto.SecretKey;
import java.io.IOException;
import java.util.Date;
import java.util.List;

public class JwtTokenValidator extends OncePerRequestFilter {


    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        System.out.println("filter called for "+request.getRequestURI());
        String token = request.getHeader(JwtConstant.JWT_HEADER);
        if(token != null)
        {
            token = token.substring(7);

            try{
                SecretKey key = Keys.hmacShaKeyFor(JwtConstant.SECRET_KEY.getBytes());
                        Claims claims = Jwts.parserBuilder()
                                .setSigningKey(key)
                                .build()
                                .parseClaimsJws(token)
                                .getBody();
                if (claims.getExpiration().before(new Date())) {
                    System.out.println("Token has expired");
                }
                String email = String.valueOf(claims.get("email"));
                String authorities = String.valueOf(claims.get("authorities"));
                List<GrantedAuthority> auths = AuthorityUtils.commaSeparatedStringToAuthorityList(authorities);
                Authentication authentication = new UsernamePasswordAuthenticationToken(email,null,auths);
                SecurityContextHolder.getContext().setAuthentication(authentication);


            }
            catch (ExpiredJwtException e)
            {
                System.out.println("Exception is : "+e.getMessage());
              response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);//401
                response.getWriter().write("{ \"error\": \"Token expired\" }");
            }
            catch (Exception e) {
                // Handle other JWT errors
                response.setStatus(HttpServletResponse.SC_FORBIDDEN); // 403
                response.setContentType("application/json");
                response.getWriter().write("{ \"error\": \"" + e.getMessage() + "\" }");
            }
        }
        else{
            System.out.println("token is null");
        }
        filterChain.doFilter(request,response);



    }
}
