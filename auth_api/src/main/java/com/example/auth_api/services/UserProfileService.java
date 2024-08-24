package com.example.auth_api.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
public class UserProfileService {

    @Value("${profile.images.directory}")
    private String profileImagesDirectory;

    @Value("${default.profile.image.path}")
    private String defaultProfileImagePath;

    // Save the uploaded profile image and return the file name
    public String saveProfileImage(MultipartFile file) throws IOException {
        // Generate a unique file name
        String fileName = UUID.randomUUID().toString() + "-" + file.getOriginalFilename();

        // Create the directory if it doesn't exist
        Path uploadPath = Paths.get(profileImagesDirectory);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Save the file
        Path filePath = uploadPath.resolve(fileName);
        file.transferTo(filePath.toFile());

        return fileName;
    }

    // Load the profile image or return a default image if the file name is null or empty
    public byte[] loadProfileImage(String fileName) throws IOException {
        // Check if the file name is null or empty
        if (fileName == null || fileName.isEmpty()) {
            // Use the default profile image if no file name is provided
            Path filePath = Paths.get(defaultProfileImagePath);
            return Files.readAllBytes(filePath);
        }

        // Load the specified profile image
        Path filePath = Paths.get(profileImagesDirectory, fileName);
        return Files.readAllBytes(filePath);
    }
}
