package com.mega.genai.controller;

import com.mega.genai.config.JwtProvider;
import com.mega.genai.dto.UserRequestDto;
import com.mega.genai.model.Token;
import com.mega.genai.model.User;
import com.mega.genai.repo.TokenRepo;
import com.mega.genai.repo.UserRepo;
import com.mega.genai.service.UserDetailsImpl;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
@CrossOrigin("*")
public class UserController {
    @Autowired
    private UserRepo userRepo;

    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private UserDetailsImpl userDetailsImpl;
    @Autowired
    TokenRepo tokenRepo;
    @GetMapping("/test")
    public String test(){
        return "working";
    }
    @PostMapping("/signup")
    public ResponseEntity<?> createUser(@RequestBody UserRequestDto userRequestDto, HttpServletResponse response)
    {
        System.out.println("method called");
        User user = userRepo.findByEmail(userRequestDto.getEmail());
        if(user  != null )
        {
            return  ResponseEntity.status(HttpStatus.BAD_REQUEST).body("email is already registered");
        }

            User newUser = User.builder().email(userRequestDto.getEmail())
                    .password(passwordEncoder.encode(userRequestDto.getPassword()))
                    .name(userRequestDto.getName()).build();
            userRepo.save(newUser);
            System.out.println("user saved");
        Authentication authentication = authenticate(userRequestDto.getEmail(), userRequestDto.getPassword());
        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = JwtProvider.generateJwtToken(authentication);
        String refreshToken = JwtProvider.generateRefreshToken(authentication);
        response.setHeader("accessToken", jwt);
        response.setHeader("refreshToken",refreshToken);
        tokenRepo.save(Token.builder().token(refreshToken).build());
            return ResponseEntity.ok("user registered");

    }
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody UserRequestDto userRequestDto, HttpServletResponse response)
    {
        String email = userRequestDto.getEmail();
        String password = userRequestDto.getPassword();

        try {
            Authentication authentication = authenticate(email, password);
            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = JwtProvider.generateJwtToken(authentication);
            String refreshToken = JwtProvider.generateRefreshToken(authentication);
            response.setHeader("accessToken", jwt);
            response.setHeader("refreshToken",refreshToken);
            tokenRepo.save(Token.builder().token(refreshToken).build());
            return ResponseEntity.ok("user logged in");
        }
        catch (BadCredentialsException e)
        {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(e.getMessage());
        }
        catch(Exception e)
        {
            System.out.println("Exception in login "+e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("unknown error");
        }
    }
    @PostMapping("/logout")
    public ResponseEntity logout(HttpServletRequest request){
        String token = request.getHeader("Authorization").substring(7);
            tokenRepo.deleteByToken(token);
            return ResponseEntity.ok().body("Successfully logged out");

    }
    private Authentication authenticate(String email,String password)
    {
        UserDetails userDetails = userDetailsImpl.loadUserByUsername(email);
        if(userDetails == null)
        {
            System.out.println("email does not exist");
            throw new BadCredentialsException("email does not exist");
        }
        if(!passwordEncoder.matches(password,userDetails.getPassword()))
        {
            System.out.println("password do not match");
            throw  new BadCredentialsException("wrong password");
        }
        System.out.println("validated from database");
        return new UsernamePasswordAuthenticationToken(userDetails,null,userDetails.getAuthorities());
    }

    @PostMapping("/validate/refresh-token")
    public ResponseEntity validateRefreshToken(HttpServletRequest request,HttpServletResponse response){
        String token = request.getHeader("Authorization").substring(7);
            if(tokenRepo.existsByToken(token))
            {

                String email = JwtProvider.getEmailFromToken(token);
                UserDetails userDetails = new UserDetailsImpl().loadUserByUsername(email);
                Authentication authentication = new UsernamePasswordAuthenticationToken(userDetails,null,userDetails.getAuthorities());
                SecurityContextHolder.getContext().setAuthentication(authentication);
                String accessToken = JwtProvider.generateJwtToken(authentication);
                String refreshToken = JwtProvider.generateRefreshToken(authentication);

                response.setHeader("accessToken",accessToken);
                response.setHeader("refreshToken",refreshToken);
                tokenRepo.deleteByToken(token);
                return ResponseEntity.ok().body("log in");
            }
            else{
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("token not found");
            }
    }

}
