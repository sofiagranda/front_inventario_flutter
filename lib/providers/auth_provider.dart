import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final int id;
  final String username;
  final String role;
  final bool isStaff; // No es opcional, por eso el error de Null

  AuthUser({
    required this.id,
    required this.username,
    required this.role,
    this.isStaff = false,
  });

  // IMPORTANTE: Agregamos isStaff al JSON para que se guarde en SharedPreferences
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'role': role,
    'is_staff': isStaff,
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Sin nombre',
      role: json['role'] ?? 'User',
      // Esta es la línea clave: maneja si el backend manda null o no manda nada
      isStaff: json['is_staff'] ?? json['isStaff'] ?? false,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  AuthUser? _user;
  String? _token;
  bool _isLoading = true;

  AuthUser? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    try {
      // Agregamos un delay artificial de 2 segundos para que el Splash
      // sea visible mientras el sistema se estabiliza.
      await Future.wait([
        Future.delayed(const Duration(seconds: 2)),
        _actualLoadingLogic(), // Mueve tu lógica actual aquí
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _actualLoadingLogic() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final String? userJson = prefs.getString('user');
    if (_token != null && userJson != null) {
      _user = AuthUser.fromJson(jsonDecode(userJson));
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> login(String token, AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    // Ahora el toJson incluye isStaff, así que se guardará correctamente
    await prefs.setString('user', jsonEncode(user.toJson()));

    _token = token;
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _token = null;
    _user = null;
    notifyListeners();
  }
}
