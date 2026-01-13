import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventario_app/screens/product_list_screen.dart';
import 'package:inventario_app/screens/product_form_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  // Añadimos 'const' aquí para mejorar el rendimiento inicial
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  // Es mejor práctica usar const para el almacenamiento si no requiere configuración dinámica
  static const _storage = FlutterSecureStorage();

  Future<bool> _isLoggedIn() async {
    final token = await _storage.read(key: "access");
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Opcional: quita la banda roja de "Debug"
      title: 'Inventario',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.red,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      routes: {
        "/login": (_) => LoginScreen(),
        "/home": (_) => HomeScreen(),
        "/productos": (_) => ProductListScreen(),
        "/create": (_) => const ProductFormScreen(editMode: false),
        "/edit": (context) { 
          final producto = 
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProductFormScreen(producto: producto, editMode: true);
        },
      },
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Si hay token va a Home, si no a Login
          return snapshot.data == true
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
