import 'package:flutter/material.dart';
import 'package:inventario_app/screens/auth/login_screen.dart';
// Importa el formulario que crearemos a continuación
// import 'package:tu_proyecto/widgets/login_form.dart'; 

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Mantenemos el color de fondo #020617
      backgroundColor: Color(0xFF020617),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          // Aquí invocas a tu componente LoginForm
          child: LoginForm(), 
        ),
      ),
    );
  }
}

