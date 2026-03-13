class User {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? avatar;
  final DateTime dateJoined;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.avatar,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      dateJoined: DateTime.parse(json['date_joined'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'avatar': avatar,
      'date_joined': dateJoined.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName'.trim().isEmpty
      ? username
      : '$firstName $lastName'.trim();
}
