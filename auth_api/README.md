# Spring Boot Security with JWT


## Overview

This project is a Spring Boot application that demonstrates how to implement security using JSON Web Tokens (JWT). It includes user authentication and authorization functionalities, providing a robust security framework for your application.

## Features

- **User Authentication**: Secure user login using JWT.
- **Role-Based Authorization**: Restrict access to endpoints based on user roles.
- **Spring Security**: Comprehensive security configuration with JWT.
- **H2 Database**: In-memory database for easy testing and development.

## Technologies Used

- **Spring Boot**: For building the backend application.
- **Spring Security**: For handling authentication and authorization.
- **JWT (JSON Web Token)**: For stateless authentication.
- **MySql Database**: Lightweight database for development.

## Getting Started

### Prerequisites

- Java 11 or later
- Maven 3.6 or later
- An IDE like IntelliJ IDEA or Eclipse (optional but recommended)

### Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/yzarzar/auth_api.git
    ```

2. Navigate to the project directory:

    ```bash
    cd auth_api
    ```

3. Build the project using Maven:

    ```bash
    ./mvnw clean install
    ```

4. Run the application:

    ```bash
    ./mvnw spring-boot:run
    ```

5. The application should be running on [http://localhost:8005](http://localhost:8005).

## Configuration

- **Application Properties**: You can configure JWT settings in `src/main/resources/application.properties`.

```properties
# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/spring_boot_jwt
spring.datasource.username=your_mysql_username
spring.datasource.password=your_mysql_password
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
# JWT Configuration
jwt.secret=your_secret_key
jwt.expiration=3600
