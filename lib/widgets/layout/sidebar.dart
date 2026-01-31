import 'package:flutter/material.dart';
import 'package:inventario_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: AppColors.slate950,
      // Quitamos bordes redondeados para que parezca un panel lateral puro
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Padding(
          // Añadimos el padding aquí para que afecte a todo el contenido interno
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogo(),
              const SizedBox(height: 32),

              // DASHBOARD (Item principal)
              _buildNavLink(
                context,
                "Dashboard",
                Icons.home_outlined,
                "/admin",
                currentRoute == "/admin",
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: Colors.white10),
              ),

              // SECCIÓN DE SCROLL (Para los items intermedios)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildNavLink(
                        context,
                        "Productos",
                        Icons.inventory_2_outlined,
                        "/admin/productos",
                        currentRoute == "/admin/productos",
                      ),
                      _buildNavLink(
                        context,
                        "Categorías",
                        Icons.layers_outlined,
                        "/admin/categorias",
                        currentRoute == "/admin/categorias",
                      ),
                      _buildNavLink(
                        context,
                        "Proveedores",
                        Icons.local_shipping_outlined,
                        "/admin/proveedores",
                        currentRoute == "/admin/proveedores",
                      ),
                      _buildNavLink(
                        context,
                        "Clientes",
                        Icons.account_circle_outlined,
                        "/admin/clientes",
                        currentRoute == "/admin/clientes",
                      ),
                      _buildNavLink(
                        context,
                        "Usuarios",
                        Icons.group_outlined,
                        "/admin/usuarios",
                        currentRoute == "/admin/usuarios",
                      ),
                    ],
                  ),
                ),
              ),

              // SECCIÓN INFERIOR
              const Divider(color: Colors.white10),
              _buildNavLink(
                context,
                "Configuración",
                Icons.settings_outlined,
                "/admin/configuracion",
                currentRoute == "/admin/configuracion",
              ),
              const SizedBox(height: 8),
              _buildLogoutLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutLink(BuildContext context) {
    return InkWell(
      onTap: () {
        // Importante: Cerrar drawer antes de cerrar sesión
        Navigator.pop(context);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.logout();
        Navigator.pushReplacementNamed(context, '/login');
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: const [
            Icon(Icons.logout, color: Colors.redAccent, size: 20),
            SizedBox(width: 12),
            Text(
              "Cerrar Sesión",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cyan500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.cyan500.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: AppColors.cyan500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "STOCKMASTER",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    bool isActive,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Cerrar drawer
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.cyan500.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.cyan500.withValues(
                      alpha: 0.15,
                    ), // Color del resplandor
                    blurRadius: 12, // Qué tanto se dispersa
                    spreadRadius: 1, // Qué tanto crece
                    offset: const Offset(0, 0), // Centrado
                  ),
                ]
              : [],
          border: isActive
              ? const Border(
                  left: BorderSide(color: AppColors.cyan500, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.cyan500 : AppColors.slate400,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
