// import 'dart:ui';
// import 'package:flutter/material.dart';
// import '../core/app_theme.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;

//   void _handleLogin() async {
//     setState(() => _isLoading = true);
//     // Aquí irá tu lógica de fetch que tienes en React
//     await Future.delayed(const Duration(seconds: 2)); 
//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Decoración de fondo (Círculo azul difuminado)
//           Positioned(
//             top: -100,
//             right: -100,
//             child: Container(
//               width: 250,
//               height: 250,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: AppColors.blue600.withValues(alpha: 0.15),
//               ),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
//                 child: Container(color: Colors.transparent),
//               ),
//             ),
//           ),
          
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(40), // rounded-[2.5rem]
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                   child: Container(
//                     width: double.infinity,
//                     constraints: const BoxConstraints(maxWidth: 400),
//                     padding: const EdgeInsets.all(40),
//                     decoration: BoxDecoration(
//                       color: AppColors.slate900.withValues(alpha: 0.5),
//                       borderRadius: BorderRadius.circular(40),
//                       border: Border.all(color: AppColors.slate800),
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Text(
//                           "Bienvenido",
//                           style: TextStyle(fontSize: 32, fontWeight: FontWeight.black, color: Colors.white),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           "Ingresa tus credenciales para acceder",
//                           style: TextStyle(color: Colors.grey, fontSize: 14),
//                         ),
//                         const SizedBox(height: 32),
                        
//                         // Input Usuario
//                         _buildInput(
//                           label: "USUARIO",
//                           hint: "Ej: admin_01",
//                           icon: Icons.person_outline,
//                           controller: _usernameController,
//                         ),
//                         const SizedBox(height: 20),
                        
//                         // Input Password
//                         _buildInput(
//                           label: "CONTRASEÑA",
//                           hint: "••••••••",
//                           icon: Icons.lock_outline,
//                           isPassword: true,
//                           controller: _passwordController,
//                         ),
//                         const SizedBox(height: 32),
                        
//                         // Botón de Ingreso
//                         SizedBox(
//                           width: double.infinity,
//                           height: 55,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _handleLogin,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.blue600,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                               elevation: 10,
//                               shadowColor: AppColors.blue600.withValues(alpha: 0.3),
//                             ),
//                             child: _isLoading 
//                               ? const CircularProgressIndicator(color: Colors.white)
//                               : const Text("Ingresar al Sistema", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                           ),
//                         ),
                        
//                         const SizedBox(height: 32),
                        
//                         // Nota Informativa
//                         Container(
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.withValues(alpha: 0.05),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
//                           ),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Icon(Icons.info_outline, size: 18, color: Colors.blue),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(
//                                   "Si no posees una cuenta, contacta al Administrador de TI.",
//                                   style: TextStyle(fontSize: 12, color: Color(0xFF0F172A)[400]),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInput({
//     required String label, 
//     required String hint, 
//     required IconData icon, 
//     required TextEditingController controller,
//     bool isPassword = false
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           obscureText: isPassword,
//           decoration: InputDecoration(
//             hintText: hint,
//             prefixIcon: Icon(icon, color: Colors.grey, size: 20),
//           ),
//         ),
//       ],
//     );
//   }
// }