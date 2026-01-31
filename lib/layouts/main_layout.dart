import 'package:flutter/material.dart';
// Importa tus widgets (debes crearlos siguiendo el patrón anterior)
// import '../widgets/sidebar.dart';
// import '../widgets/header.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // Equivale al <Outlet />

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. SIDEBAR (Equivale a <Sidebar />)
          // Si ya tienes un widget Sidebar.dart, úsalo aquí.
          Container(
            width: 260,
            color: const Color(0xFF0F172A),
            child: const Center(
              child: Text("Sidebar", style: TextStyle(color: Colors.white)),
            ),
          ),

          // 2. CONTENIDO DERECHO (flex: 1)
          Expanded(
            child: Container(
              color: const Color(0xFF020617), // background: "#020617"
              child: Column(
                children: [
                  // 3. HEADER (Equivale a <Header />)
                  // Aquí iría tu widget Header personalizado
                  Container(
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF1E293B)),
                      ),
                    ),
                    child: const Center(
                      child: Text("Header Content", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  // 4. ÁREA DE CONTENIDO (Padding: 20px + Outlet)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: child, // Aquí se renderiza la página actual
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}