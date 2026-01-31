// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:async';

// import 'package:permission_handler/permission_handler.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 3), () async {
//       final storage = const FlutterSecureStorage();
//       final token = await storage.read(key: "access");
//       final status = await Permission.location.status;
//       if (!mounted) return;
//       if (status.isGranted) {
//         // ✅ Ubicación permitida (aunque sea "solo esta vez")
//         if (token != null) {
//           Navigator.pushReplacementNamed(context, "/home");
//         } else {
//           Navigator.pushReplacementNamed(context, "/onboarding");
//         }
//       } else {
//         // ❌ Ubicación denegada → siempre Onboarding
//         Navigator.pushReplacementNamed(context, "/onboarding");
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // color de fondo
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Logo de la aplicación
//             Image.asset(
//               "assets/Escudo_del_Deportivo_Quito.png", // coloca tu logo en assets/logo.png
//               width: 150,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "Inventario App",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.orangeAccent,
//               ),
//             ),
//             const SizedBox(height: 30),
//             const CircularProgressIndicator(color: Colors.orangeAccent),
//           ],
//         ),
//       ),
//     );
//   }
// }
