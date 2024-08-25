import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {

  final User? user;

  ProfileScreen({this.user});

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
      Navigator.of(context).pop(); // Close the dialog after updating
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
              title: Text(
                'Update Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Full Name TextField with minimal design
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100], // Subtle background color
                        borderRadius: BorderRadius.circular(6.0), // Smaller rounded corners
                      ),
                      child: TextField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(fontSize: 14, color: Colors.grey[700]), // Smaller font size and subtle color
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // Remove default border
                            borderRadius: BorderRadius.circular(6.0), // Match container's rounded corners
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Compact padding
                        ),
                        style: TextStyle(fontSize: 14), // Smaller input text size
                      ),
                    ),
                    SizedBox(height: 10), // Smaller space between fields

                    // Email TextField
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Phone Number TextField
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: TextField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Address TextField
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
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
                    Navigator.of(context).pop(); // Close the dialog on cancel
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
                    Navigator.of(context).pop(); // Close the dialog after update
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
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchUserDetails,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Profile image section
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _updateProfileImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundImage: _profileImageBytes != null
                              ? MemoryImage(_profileImageBytes!)
                              : null,
                          child: _profileImageBytes == null
                              ? Icon(Icons.person, size: 80, color: Colors.grey[800])
                              : null,
                          backgroundColor: Colors.grey[300],
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _user?.fullName ?? 'N/A',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _user?.email ?? 'N/A',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Profile details
            _buildDetailRow('Phone', _user?.phoneNumber ?? 'N/A'),
            _buildDetailRow('Address', _user?.address ?? 'N/A'),
            SizedBox(height: 20),
            // Update profile button
            ElevatedButton(
              onPressed: _showUpdateForm,
              child: Text('Update Profile'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
        ),
        Divider(thickness: 1.0, color: Colors.grey[300]),
      ],
    );
  }
}
