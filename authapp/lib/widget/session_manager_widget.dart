import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer
import '../services/auth_service.dart';

class SessionManagerWidget extends StatefulWidget {
  final Widget child;

  SessionManagerWidget({required this.child});

  @override
  _SessionManagerWidgetState createState() => _SessionManagerWidgetState();
}

class _SessionManagerWidgetState extends State<SessionManagerWidget> {
  final _authService = AuthService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSessionCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSessionCheck() {
    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    try {
      await _authService.getUserDetails();
      await _authService.getProfileImageData();
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        _showSessionExpiredDialog();
      }
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Session Expired'),
          content: Text('Your session has expired. Please log in again.'),
          actions: [
            TextButton(
              child: Text('Reload'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _checkSession(); // Recheck the session
              },
            ),
            TextButton(
              child: Text('Login'),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child; // Return the wrapped child widget
  }
}
