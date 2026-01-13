import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _storage = FlutterSecureStorage();

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse(
        "https://paredes-inventario-api.desarrollo-software.xyz/api/auth/login/",
      ),
      body: {
        "username": _userController.text,
        "password": _passController.text,
      },
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["token"];
      await _storage.write(key: "token", value: token);
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Credenciales inválidas")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido',
              style: TextStyle(fontSize: 28, color: Colors.redAccent),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _userController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
