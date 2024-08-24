import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../widget/session_manager_widget.dart';
import 'profile_screen.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchProfileImage(); // Fetch the profile image as well
  }

  Future<void> _fetchUserDetails() async {
    try {
      User? user = await _authService.getUserDetails();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProfileImage() async {
    try {
      final bytes = await _authService.getProfileImageData();
      print('Profile image data length: ${bytes.length}'); // Debug statement
      setState(() {
        _profileImageBytes = bytes;
      });
    } catch (e) {
      print('Error fetching profile image: $e'); // Debug statement
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchUserDetails(); // Refresh user details
    await _fetchProfileImage(); // Refresh profile image
  }

  Future<void> _logout() async {
    await _authService.storage.deleteAll();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return SessionManagerWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // Handle search action
              },
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                // Navigate to settings screen
              },
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                } else if (value == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ];
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: _profileImageBytes != null
                    ? CircleAvatar(
                  backgroundImage: MemoryImage(_profileImageBytes!),
                  radius: 20,
                )
                    : CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.grey[800]),
                  radius: 20,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset(
                    'assets/images/logo.png', // Add logo image to your assets
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(height: 20),

                  // Welcome Message with Gradient and Shadow
                  Text(
                    'Welcome, ${_user?.fullName ?? 'User'}!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),

                  // Hero Section - Powered by Spring Security & JWT
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Powered by',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Spring Security & JWT',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(3, 3),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Experience the pinnacle of security with Spring Security and JWT. Our system ensures your sessions are safeguarded with cutting-edge authentication and token management, empowering your journey with robust protection and seamless access.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Image.asset(
                          'assets/images/security.png', // Make sure to add this image to your assets
                          height: 150,
                          width: 150,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Explanation of JWT Tokens
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About JWT Authentication',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Our application uses JWT (JSON Web Tokens) for secure authentication. Here’s how it works:',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. **Access Token**: This token is used for accessing protected resources. It has a short lifespan (e.g., 2 minutes) and needs to be refreshed frequently.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '2. **Refresh Token**: This token is used to obtain a new access token once it expires. It has a longer lifespan (e.g., 5 minutes) and helps in maintaining user sessions.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'If your session expires, you will be prompted to log in again to continue using the app.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  _isLoading
                      ? CircularProgressIndicator()
                      : _errorMessage != null
                      ? Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  )
                      : _user != null
                      ? Text(
                    'Email: ${_user!.email}',
                    style: TextStyle(fontSize: 18),
                  )
                      : Text(
                    'User data not available.',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
