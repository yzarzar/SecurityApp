import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';

class AuthService {
  final String baseUrl = 'https://wise-frogs-dance.loca.lt'; // Replace with your actual API base URL
  final storage = FlutterSecureStorage();

  Future<User> uploadProfileImage(XFile file) async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('Session expired');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/users/profile/image'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return User.fromJson(jsonDecode(responseData));
    } else {
      throw Exception('Failed to upload profile image');
    }
  }

  Future<User> signup(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      await storage.write(key: 'token', value: responseData['token']);
      await storage.write(key: 'refreshToken', value: responseData['refreshToken']);
      await storage.write(key: 'expiresIn', value: responseData['expiresIn'].toString());
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> refreshToken() async {
    final refreshToken = await storage.read(key: 'refreshToken');
    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      await storage.write(key: 'token', value: responseData['token']);
      await storage.write(key: 'expiresIn', value: responseData['expiresIn'].toString());
    } else {
      // Token is no longer valid or refresh failed, so log out the user
      await logout(); // Ensure the user is logged out
      throw Exception('Session expired. Please log in again.');
    }
  }

  Future<User?> getUserDetails() async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('Session expired');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 403) {
      // Handle session expiration
      await logout(); // Ensure the user is logged out
      throw Exception('Session expired');
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> logout() async {
    await storage.deleteAll();
    // Optionally, notify the server to invalidate the session if necessary
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'token');
    return token != null; // This will return false if token is null
  }
}
