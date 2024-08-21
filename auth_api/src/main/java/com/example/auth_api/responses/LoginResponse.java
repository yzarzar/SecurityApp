package com.example.auth_api.responses;

import lombok.Getter;
import lombok.Setter;

@Getter
public class LoginResponse {
    private String token;
    private String refreshToken;
    private long expiresIn;

    public LoginResponse setToken(String token) {
        this.token = token;
        return this;
    }

    public LoginResponse setExpiresIn(long expiresIn) {
        this.expiresIn = expiresIn;
        return this;
    }

    public LoginResponse setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
        return this;
    }
}

