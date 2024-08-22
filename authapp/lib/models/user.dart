class User {
  final int id;
  final String fullName;
  final String email;
  final String? address;
  final String? phoneNumber;
  final String? profileImagePath;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.address,
    this.phoneNumber,
    this.profileImagePath,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      profileImagePath: json['profileImagePath'],
      role: json['role']['name'],
    );
  }
}
