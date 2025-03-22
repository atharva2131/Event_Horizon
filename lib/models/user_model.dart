class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final String profileImage;
  final String bio;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final String adminNotes;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    this.profileImage = '/uploads/default-profile.png',
    this.bio = '',
    this.address = '',
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    this.adminNotes = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      isActive: json['active'] ?? true,
      profileImage: json['profileImage'] ?? '/uploads/default-profile.png',
      bio: json['bio'] ?? '',
      address: json['address'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      adminNotes: json['adminNotes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'active': isActive,
      'profileImage': profileImage,
      'bio': bio,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'adminNotes': adminNotes,
    };
  }
}

