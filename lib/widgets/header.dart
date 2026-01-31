import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  const Header({super.key, required this.username});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.slate950,
      elevation: 0,
      shape: const Border(bottom: BorderSide(color: AppColors.slate800)),
      title: Row(
        children: [
          const Text("Dashboard", 
            style: TextStyle(color: AppColors.cyan500, fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.slate900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.slate700),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(username, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () {}, // Lógica de logout
          icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
          label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent)),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}