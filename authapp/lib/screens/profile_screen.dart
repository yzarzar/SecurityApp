import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  XFile? _selectedImage;
  Uint8List? _profileImageBytes;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchProfileImage();
  }

  Future<void> _fetchUserDetails() async {
    try {
      User? user = await _authService.getUserDetails();
      setState(() {
        _user = user;
        _isLoading = false;
        _fullNameController.text = user?.fullName ?? '';
        _emailController.text = user?.email ?? '';
        _addressController.text = user?.address ?? '';
        _phoneNumberController.text = user?.phoneNumber ?? '';
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
      setState(() {
        _profileImageBytes = bytes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.updateUserDetails(
        _fullNameController.text,
        _emailController.text,
        _addressController.text,
        _phoneNumberController.text,
      );

      if (_selectedImage != null) {
        await _authService.uploadProfileImage(_selectedImage!);
      }

      await _fetchUserDetails();
      await _fetchProfileImage();
      Navigator.of(context).pop();  // Close the popup after updating
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        setState(() {
          _isLoading = true;
          _selectedImage = pickedFile;
        });

        await _authService.uploadProfileImage(pickedFile);
        await _fetchProfileImage();
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUpdateForm() {
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _fullNameController,
                      decoration: InputDecoration(labelText: 'Full Name'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                    ),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Address'),
                    ),
                    if (isUpdating)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Update'),
                  onPressed: isUpdating
                      ? null
                      : () async {
                    setState(() {
                      isUpdating = true;
                    });
                    await _updateUserProfile();
                    setState(() {
                      isUpdating = false;
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
          : RefreshIndicator(
        onRefresh: _fetchUserDetails,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Display profile image and update button
            GestureDetector(
              onTap: _updateProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageBytes != null
                    ? MemoryImage(_profileImageBytes!)
                    : null,
                child: _profileImageBytes == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey[800])
                    : null,
                backgroundColor: Colors.grey[300],
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _updateProfileImage,
              child: Text('Change Profile Image'),
            ),
            SizedBox(height: 16),
            Text('Full Name: ${_user?.fullName ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Email: ${_user?.email ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Phone: ${_user?.phoneNumber ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Address: ${_user?.address ?? 'N/A'}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showUpdateForm,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
