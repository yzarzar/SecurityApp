# SecurityApp

## Overview

This project is a full-stack application integrating a Spring Boot backend with a MySQL database and a Flutter frontend. It provides a complete solution for managing user profiles and securing API endpoints with JWT authentication and role-based access control.

## Features

- **Spring Boot Backend**: Handles business logic, API requests, and security with JWT and role-based access control.
- **MySQL Database**: Stores and manages application data.
- **Flutter Frontend**: Provides a responsive and user-friendly interface for mobile devices.

## Getting Started

### Prerequisites

- **Docker**: For containerizing the application and database.
- **Java Development Kit (JDK) 11 or higher**: Required for running the Spring Boot application.
- **Flutter SDK**: Needed for developing and running the Flutter application.

### Installation

1. **Clone the Repository**

   ```bash
   git clone git@github.com:yzarzar/SecurityApp.git
   cd SecurityApp

### Modification in properties file


spring.application.name=auth-api
server.port=8080

spring.datasource.url=jdbc:mysql://localhost:3306/YOUR_DATABASE_NAME
spring.datasource.username=YOUR_USERNAME
spring.datasource.password=YOUR_PASSWORD

## Hibernate properties
spring.jpa.hibernate.ddl-auto=update
spring.jpa.open-in-view=false

security.jwt.secret-key=c738cec6381016ae7979acd6d1e5f4a69c6f5510619a92556aa7e01f6a02d1fa

# Access token expiration (e.g., 15 minutes)
security.jwt.expiration-time=900000

# Refresh token expiration (e.g., 7 days)
security.jwt.refresh-expiration-time=604800000

# Define the directory for storing profile images
profile.images.directory=USER_YOUR_ABSOLUTE_PATH/SecurityApp/auth_api/uploads/profile-images
default.profile.image.path=USER_YOUR_ABSOLUTE_PATH/SecurityApp/auth_api/uploads/profile-images/profile.jpeg

# Maximum file size
spring.servlet.multipart.max-file-size=100MB
# Maximum request size (file size + other data)
spring.servlet.multipart.max-request-size=100MB
