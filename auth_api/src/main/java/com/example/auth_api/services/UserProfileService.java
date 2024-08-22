package com.example.auth_api.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
public class UserProfileService {

    @Value("${profile.images.directory}")
    private String profileImagesDirectory;

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

    public byte[] loadProfileImage(String fileName) throws IOException {
        Path filePath = Paths.get(profileImagesDirectory, fileName);
        return Files.readAllBytes(filePath);
    }
}
