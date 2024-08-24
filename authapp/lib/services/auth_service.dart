import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import 'dart:typed_data';
import 'dart:io';

class AuthService {
  final String baseUrl = 'https://forty-chicken-hug.loca.lt'; // Replace with your actual API base URL
  final storage = FlutterSecureStorage();

  Future<Uint8List> getProfileImageData() async {
    final token = await _getValidToken();
    if (token == null) {
      throw Exception('Session expired');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/profile/image'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes; // Return the image bytes directly
    } else if (response.statusCode == 403) {
      await logout(); // Ensure the user is logged out
      throw Exception('Session expired');
    } else {
      throw Exception('Failed to load profile image: ${response.statusCode}');
    }
  }


  Future<User> uploadProfileImage(XFile file) async {
    final token = await _getValidToken();
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

  Future<void> refreshTokenFun() async {
    final refreshToken = await storage.read(key: 'refreshToken');
    if (refreshToken == null) {
      print('No refresh token found in storage');
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
      await storage.write(key: 'expiresIn', value: (DateTime.now().millisecondsSinceEpoch + 120000).toString());
    } else {
      await logout(); // Ensure the user is logged out
      throw Exception('Session expired. Please log in again.');
    }
  }

  // This method checks if the token is still valid, otherwise it refreshes it
  Future<String?> _getValidToken() async {
    final token = await storage.read(key: 'token');
    final expiresInString = await storage.read(key: 'expiresIn');
    final refreshToken = await storage.read(key: 'refreshToken');

    if (token == null || expiresInString == null || refreshToken == null) {
      return null;
    }

    final expiresIn = int.parse(expiresInString);
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Check if the token is close to expiration (less than 1 minute remaining)
    if (expiresIn - currentTime < 30000) {
      try {
        await refreshTokenFun(); // Correctly invoking the refreshToken function
        final newToken = await storage.read(key: 'token');
        return newToken;
      } catch (e) {
        print('Error during token refresh: $e');
        return null;
      }
    }

    return token;
  }

  Future<User?> getUserDetails() async {
    final token = await _getValidToken();
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
      await logout(); // Ensure the user is logged out
      throw Exception('Session expired');
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> updateUserDetails(String? fullName, String? email, String? address, String? phoneNumber) async {
    final token = await _getValidToken();
    if (token == null) {
      throw Exception('Session expired');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'address': address,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      // Successfully updated
    } else if (response.statusCode == 403) {
      await logout(); // Ensure the user is logged out
      throw Exception('Session expired');
    } else {
      throw Exception('Failed to update user details');
    }
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'token');
    return token != null;
  }

  Future<void> _debugTokenStorage() async {
    final token = await storage.read(key: 'token');
    final refreshToken = await storage.read(key: 'refreshToken');
    final expiresIn = await storage.read(key: 'expiresIn');

    print('Token: $token');
    print('Refresh Token: $refreshToken');
    print('Expires In: $expiresIn');
  }
}
