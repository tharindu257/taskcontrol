class User {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? avatar;
  final String role;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.avatar,
    this.role = 'MEMBER',
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'MEMBER',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'fullName': fullName,
        'avatar': avatar,
        'role': role,
      };

  String get displayName => fullName ?? username;
}
