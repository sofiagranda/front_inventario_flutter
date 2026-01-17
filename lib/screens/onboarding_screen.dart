import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _requestPermissions(BuildContext context) async {
    // 1️⃣ Pedir ubicación
    final locationStatus = await Permission.location.request();

    // 2️⃣ Pedir notificaciones (Firebase Messaging)
    final messaging = FirebaseMessaging.instance;
    final notifSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final bool locationGranted = locationStatus.isGranted;
    final bool notifGranted =
        notifSettings.authorizationStatus == AuthorizationStatus.authorized;

    if (locationGranted && notifGranted) {
      // ✅ Ambos permisos aceptados → ir al Home
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      // ❌ Alguno fue denegado → construir mensaje específico
      String mensaje = "Debes aceptar ";

      if (!locationGranted && !notifGranted) {
        mensaje += "ubicación y notificaciones para continuar";
      } else if (!locationGranted) {
        mensaje += "la ubicación para continuar";
      } else if (!notifGranted) {
        mensaje += "las notificaciones para continuar";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          action: (!notifGranted)
              ? SnackBarAction(
                  label: "Abrir ajustes",
                  onPressed: () {
                    // 🔧 Si negó notificaciones, abrir ajustes de la app
                    openAppSettings();
                  },
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Descubre eventos en tu ciudad activando la ubicación",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "¿Quieres enterarte de todo?\n\n"
              "Activa las notificaciones para recibir información sobre promociones, "
              "lanzamientos exclusivos y el estado de tu pedido.",
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _requestPermissions(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Activar ubicación y notificaciones",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

