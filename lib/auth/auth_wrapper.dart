import 'package:flutter/material.dart';
import 'package:inventario_app/pages/dashboard_page.dart';
import 'package:inventario_app/pages/login_page.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../layouts/admin_layout.dart'; // Crearemos este después

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado de autenticación
    final authProvider = Provider.of<AuthProvider>(context);

    // Lógica idéntica a tu ProtectedRoute:
    // Si no hay token, devuelve el Login. Si lo hay, devuelve el Layout Admin.
    if (!authProvider.isAuthenticated) {
      return const LoginPage();
    }

    return const AdminLayout(child: DashboardPage());
  }
}
