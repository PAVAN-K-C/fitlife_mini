class User {
  final String id;
  final String email;
  final String? password;
  final bool isGuest;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.password,
    this.isGuest = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'isGuest': isGuest ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      password: map['password'] as String?,
      isGuest: (map['isGuest'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
