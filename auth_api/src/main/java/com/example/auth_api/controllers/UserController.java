package com.example.auth_api.controllers;

import com.example.auth_api.entities.User;
import com.example.auth_api.request.UpdateUserProfileRequest;
import com.example.auth_api.services.UserService;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@RequestMapping("/users")
@RestController
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/profile/image/{filename:.+}")
    public ResponseEntity<Resource> getUserProfileImage(@PathVariable String filename) {
        try {
            // Assuming the profile images are stored in the path defined in application.properties
            String imageDirectory = "uploads/profile-images/";
            Path filePath = Paths.get(imageDirectory).resolve(filename).normalize();
            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists()) {
                return ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping("/profile/image")
    public ResponseEntity<User> uploadProfileImage(@AuthenticationPrincipal UserDetails userDetails,
                                                   @RequestParam("file") MultipartFile file) throws IOException {
        String email = userDetails.getUsername();
        User updatedUser = userService.updateUserProfileImage(email, file);
        return ResponseEntity.ok(updatedUser);
    }

    @GetMapping("/profile/image")
    public ResponseEntity<byte[]> getUserProfileImage(@AuthenticationPrincipal UserDetails userDetails) throws IOException {
        String email = userDetails.getUsername();
        byte[] image = userService.getUserProfileImage(email);
        return ResponseEntity.ok().contentType(MediaType.IMAGE_JPEG).body(image);
    }

    @GetMapping("/me")
    //@PreAuthorize("isAuthenticated()")
    public ResponseEntity<User> authenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        User currentUser = (User) authentication.getPrincipal();

        return ResponseEntity.ok(currentUser);
    }

    @PutMapping("/profile")
    //@PreAuthorize("isAuthenticated()")
    public ResponseEntity<User> updateUserProfile(@AuthenticationPrincipal UserDetails userDetails,
                                                  @RequestBody UpdateUserProfileRequest updateUserProfileRequest) {
        String email = userDetails.getUsername();
        User updatedUser = userService.updateUserProfile(email, updateUserProfileRequest);
        return ResponseEntity.ok(updatedUser);
    }

    @GetMapping("/")
    @PreAuthorize("hasAnyRole('ADMIN', 'SUPER_ADMIN')")
    public ResponseEntity<List<User>> allUsers() {
        List <User> users = userService.allUsers();

        return ResponseEntity.ok(users);
    }
}
