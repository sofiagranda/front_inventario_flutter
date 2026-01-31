import 'package:flutter/material.dart';
// Importa tus carpetas (las crearemos en los siguientes pasos)
// import '../auth/login_screen.dart';
// import '../pages/admin/dashboard_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String dashboard = '/admin/dashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Por ahora comentados hasta que creemos los archivos
      // login: (context) => const LoginScreen(),
      // dashboard: (context) => const DashboardScreen(),
    };
  }
}