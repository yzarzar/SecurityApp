package com.example.auth_api.repositories;

import com.example.auth_api.entities.Role;
import com.example.auth_api.entities.RoleEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RoleRepository extends JpaRepository<Role, Integer> {

    Optional<Role> findByName(RoleEnum name);
}
