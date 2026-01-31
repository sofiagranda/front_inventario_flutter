import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ConfirmModal {
  // En Flutter, en lugar de una prop 'open', usamos un método estático
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required VoidCallback onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Equivalente a que no se cierre al hacer clic fuera si no queremos
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.slate950, // Tu color #020617
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.slate800), // Borde #1e293b
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onClose();
                Navigator.of(context).pop(); // Cerramos el modal
              },
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop(); // Cerramos el modal
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan600,
                foregroundColor: Colors.white,
              ),
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }
}