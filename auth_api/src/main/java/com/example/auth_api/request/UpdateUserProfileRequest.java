package com.example.auth_api.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateUserProfileRequest {
    private String fullName;
    private String address;
    private String phoneNumber;
}
