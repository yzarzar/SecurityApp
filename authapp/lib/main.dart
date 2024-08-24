import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import '../services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();

  // Check if user is already logged in
  bool isLoggedIn = await authService.isLoggedIn() ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth App',
      theme: ThemeData(
        primaryColor: Colors.blueAccent, colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(error: Colors.redAccent),    // Color used for error messages
      ),
      home: isLoggedIn ? HomeScreen() : LoginScreen(), // Use isLoggedIn to decide the home screen
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

