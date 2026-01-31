import 'package:flutter/material.dart';
import 'package:inventario_app/pages/categorias_page.dart';
import 'package:inventario_app/pages/clientes_page.dart';
import 'package:inventario_app/pages/configuracion_page.dart';
import 'package:inventario_app/pages/public/loading_page.dart';
import 'package:provider/provider.dart';
import 'package:inventario_app/providers/auth_provider.dart';
import 'package:inventario_app/widgets/layout/sidebar.dart';

// Importa tus páginas
import 'pages/public/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/productos_page.dart';
import 'pages/usuarios_page.dart';
import 'pages/proveedores_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const InventoryApp(),
    ),
  );
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Control de Inventario',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'Inter',
      ),
      // 1. Quitamos initialRoute y usamos 'home'
      // Esto decide qué ver PRIMERO sin errores de rutas nulas
      home: _getHome(authProvider),
      
      // 2. Usamos rutas normales para la navegación interna
      routes: {
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const MainLayout(child: DashboardPage()),
        '/admin/productos': (context) => const MainLayout(child: ProductosPage()),
        '/admin/categorias': (context) => const MainLayout(child: CategoriasPage()),
        '/admin/usuarios': (context) => const MainLayout(child: UsuariosPage()),
        '/admin/proveedores': (context) => const MainLayout(child: ProveedoresPage()),
        '/admin/clientes': (context) => const MainLayout(child: ClientesPage()),
        '/admin/configuracion': (context) => const MainLayout(child: ConfiguracionPage()),
      },
    );
  }

  // Lógica para decidir la pantalla principal
  // En tu main.dart, importa la nueva página:

// ... dentro de class InventoryApp ...

  Widget _getHome(AuthProvider auth) {
    // 1. Mientras lee SharedPreferences
    if (auth.isLoading) {
      return const LoadingPage(); 
    }
    
    // 2. Si ya terminó de cargar y hay token
    if (auth.isAuthenticated) {
      return const MainLayout(child: DashboardPage());
    }
    
    // 3. Si terminó de cargar pero NO hay token
    return const WelcomePage();
  }
}

// 5. LAYOUT CON MENÚ HAMBURGUESA (DRAWER)
class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer es el que hace que el menú salga desde la izquierda (hamburguesa)
      drawer: const Sidebar(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("STOCKMASTER"),
        elevation: 0,
      ),
      body: child,
    );
  }
}