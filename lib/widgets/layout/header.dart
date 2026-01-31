import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_theme.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos del proveedor de autenticación
    final authProvider = Provider.of<AuthProvider>(context);
    final String username = authProvider.user?.username ?? "Usuario";

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: AppColors.slate950, // #020617
        border: Border(
          bottom: BorderSide(color: AppColors.slate800, width: 1), // #1e293b
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lado Izquierdo: Título y Badge de Usuario
          Row(
            children: [
              const Text(
                "Dashboard",
                style: TextStyle(
                  color: AppColors.cyan500, // #38bdf8 aprox
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 20),
              // Badge del Usuario
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A), // #0f172a
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155)), // #334155
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(
                      username,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Lado Derecho: Botón de Salida
          OutlinedButton.icon(
            onPressed: () => _handleLogout(context, authProvider),
            icon: const Text("Cerrar Sesión"),
            label: const Icon(Icons.logout, size: 18),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ).copyWith(
              // Efecto hover (cambia color al presionar en móvil)
              backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (states) => states.contains(WidgetState.pressed) ? Colors.redAccent : null,
              ),
              overlayColor: WidgetStateProperty.all(Colors.redAccent.withValues(alpha: 0.1)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider auth) {
    // Usamos el método que ya definimos en el provider
    auth.logout();
    // Como usamos el AuthWrapper en main.dart, la app redirigirá al Login automáticamente
  }
}