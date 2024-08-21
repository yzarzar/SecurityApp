package com.example.auth_api.services;

import com.example.auth_api.dtos.RegisterUserDto;
import com.example.auth_api.entities.Role;
import com.example.auth_api.entities.RoleEnum;
import com.example.auth_api.entities.User;
import com.example.auth_api.repositories.RoleRepository;
import com.example.auth_api.repositories.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, RoleRepository roleRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
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
