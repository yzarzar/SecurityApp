import 'dart:typed_data';
import 'package:authapp/screens/user_details_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../screens/profile_screen.dart'; // Import the UserProfileScreen

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final AuthService _authService = AuthService();
  List<User>? _users;
  List<User>? _filteredUsers;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _fetchUsers() async {
    try {
      List<User> users = await _authService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _fetchUsers(); // Refresh the data
  }

  Future<Uint8List?> _fetchProfileImage(String imagePath) async {
    try {
      if (imagePath.isEmpty) {
        return null; // Handle missing image path
      }

      final profileImageBytes = await _authService.getProfileImageData1(imagePath);
      return profileImageBytes;
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      return null;
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = _users;
      });
    } else {
      setState(() {
        _filteredUsers = _users?.where((user) {
          final usernameMatch = user.fullName.toLowerCase().contains(query);
          final emailMatch = user.email.toLowerCase().contains(query);
          return usernameMatch || emailMatch;
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userCount = _filteredUsers?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('All Users (${userCount})'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (query) => _filterUsers(),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search by username or email',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: _filteredUsers?.length ?? 0,
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
          itemBuilder: (context, index) {
            final user = _filteredUsers![index];
            final imagePath = user.profileImagePath ?? '';

            return FutureBuilder<Uint8List?>(
              future: _fetchProfileImage(imagePath),
              builder: (context, snapshot) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: snapshot.hasData
                        ? MemoryImage(snapshot.data!)
                        : null,
                    child: snapshot.hasData
                        ? null
                        : Icon(Icons.person, color: Colors.grey[800]),
                    backgroundColor: Colors.grey[300],
                  ),
                  title: Text(
                    user.fullName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    user.email,
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 14),
                  ),
                  onTap: () {
                    print('Navigating to profile for user: ${user.fullName}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(user: user),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
