import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Tu color de fondo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o Icono principal con un resplandor
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyan.withOpacity(0.05),
                border: Border.all(color: Colors.cyan.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: Colors.cyan,
                size: 80,
              ),
            ),
            const SizedBox(height: 40),
            // Indicador de carga estilizado
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.cyan,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            // Texto de carga
            Text(
              "STOCKMASTER",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Sincronizando datos...",
              style: TextStyle(
                color: Colors.cyan.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}