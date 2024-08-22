package com.example.auth_api.services;

import com.example.auth_api.dtos.RegisterUserDto;
import com.example.auth_api.entities.Role;
import com.example.auth_api.entities.RoleEnum;
import com.example.auth_api.entities.User;
import com.example.auth_api.repositories.RoleRepository;
import com.example.auth_api.repositories.UserRepository;
import com.example.auth_api.request.UpdateUserProfileRequest;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserProfileService userProfileService;

    public UserService(UserRepository userRepository, RoleRepository roleRepository, PasswordEncoder passwordEncoder, UserProfileService userProfileService) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.userProfileService = userProfileService;
    }

    public User updateUserProfileImage(String email, MultipartFile file) throws IOException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        // Save the image to the server
        String fileName = userProfileService.saveProfileImage(file);

        // Update the user's profile with the image path
        user.setProfileImagePath(fileName);

        return userRepository.save(user);
    }

    public byte[] getUserProfileImage(String email) throws IOException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        return userProfileService.loadProfileImage(user.getProfileImagePath());
    }

    public User updateUserProfile(String email, UpdateUserProfileRequest updateUserProfileRequest) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        user.setFullName(updateUserProfileRequest.getFullName());
        user.setAddress(updateUserProfileRequest.getAddress());
        user.setPhoneNumber(updateUserProfileRequest.getPhoneNumber());

        return userRepository.save(user);
    }

    public List<User> allUsers() {
        List<User> users = new ArrayList<>();

        userRepository.findAll().forEach(users::add);

        return users;
    }

    public User createAdministrator(RegisterUserDto input) {
        Optional<Role> optionalRole = roleRepository.findByName(RoleEnum.ADMIN);

        if (optionalRole.isEmpty()) {
            return null;
        }

        var user = new User();
            user.setFullName(input.getFullName());
            user.setEmail(input.getEmail());
            user.setPassword(passwordEncoder.encode(input.getPassword()));
            user.setRole(optionalRole.get());

        return userRepository.save(user);
    }
}
