import 'package:flutter/material.dart';

class CustomModal {
  // Función estática para mostrar el modal desde cualquier lugar
  static Future<void> show({
    required BuildContext context,
    required String title,
    required Widget content, // Equivalente al children: ReactNode
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6), // background: "rgba(0,0,0,0.6)"
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF0F172A), // background: "#0f172a"
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Altura automática según contenido
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                
                // Aquí se renderiza el contenido (Formularios, Tablas, etc.)
                Flexible(child: SingleChildScrollView(child: content)),
                
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB), // background: "#2563eb"
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cerrar"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}