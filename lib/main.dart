import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventario_app/firebase_options.dart';
import 'package:inventario_app/screens/cliente_form_screen.dart';
import 'package:inventario_app/screens/home_screen.dart';
import 'package:inventario_app/screens/onboarding_screen.dart';
import 'package:inventario_app/screens/splash_screen.dart';
import 'package:inventario_app/screens/product_list_screen.dart';
import 'package:inventario_app/screens/product_form_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InventarioApp());
}


class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventario',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.red,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      routes: {
        "/splash": (context) => const SplashScreen(),
        "/onboarding": (context) => const OnboardingScreen(),
        "/login": (_) => const LoginScreen(),
        '/registro': (context) => ClienteFormScreen(), 
        "/home": (_) => const HomeScreen(),
        "/homel": (_) => const HomeLoginScreen(),
        "/productos": (_) => ProductListScreen(),
        "/create": (_) => const ProductoFormScreen(),
        "/edit": (context) {
          final producto =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ProductoFormScreen(producto: producto);
        },
      },
      initialRoute: "/splash", // 👈 arranca siempre en Splash
    );
  }
}
