import 'package:flutter/material.dart';
import 'package:inventario_app/widgets/layout/sidebar.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Row(
        children: [
          // 1. Tu Sidebar (Equivale al componente de navegación lateral)
          const Sidebar(), 

          // 2. El contenido principal (Equivale al <main> + <Outlet />)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              // Usamos PageTransitionSwitcher o un simple AnimatedSwitcher 
              // para replicar las transiciones suaves de React al cambiar de ruta
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  // La Key es vital para que AnimatedSwitcher sepa que el contenido cambió
                  key: ValueKey(child.runtimeType),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}