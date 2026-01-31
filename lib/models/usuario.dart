class DjangoUser {
  final int? id;
  final String username;
  final String email;
  final bool isStaff;
  final String? password;

  DjangoUser({
    this.id,
    required this.username,
    required this.email,
    required this.isStaff,
    this.password,
  });

  // Convierte JSON a Objeto Dart
  factory DjangoUser.fromJson(Map<String, dynamic> json) {
    return DjangoUser(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      isStaff: json['is_staff'] ?? false,
    );
  }

  // Convierte Objeto a Mapa para enviar al servidor
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'is_staff': isStaff,
    };
    if (password != null) data['password'] = password;
    return data;
  }
}