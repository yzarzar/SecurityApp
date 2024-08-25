import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class UserDetailsScreen extends StatefulWidget {
  final User? user;

  UserDetailsScreen({this.user});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _errorMessage;
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _fetchProfileImage();
  }

  Future<void> _fetchProfileImage() async {
    if (widget.user?.profileImagePath == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final bytes = await _authService.getProfileImageData1(widget.user!.profileImagePath!);
      setState(() {
        _profileImageBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Hero Section
          Container(
            padding: EdgeInsets.only(top: 80, bottom: 40), // Increased top padding
            color: Colors.white, // Neutral background color
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : _errorMessage != null
                  ? Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : null,
                    child: _profileImageBytes == null
                        ? Icon(Icons.person, size: 80, color: Colors.grey[700])
                        : null,
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.user?.fullName ?? 'N/A',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    widget.user?.email ?? 'N/A',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          // Profile details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ListView(
                children: [
                  _buildDetailRow('Phone', widget.user?.phoneNumber ?? 'N/A'),
                  _buildDetailRow('Address', widget.user?.address ?? 'N/A'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
