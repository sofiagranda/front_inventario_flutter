import 'package:flutter/material.dart';
// Importa tus servicios reales aquí
import '../services/productos_service.dart';
import '../services/clientes_service.dart';
import '../services/proveedores_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _productos = 0;
  int _clientes = 0;
  int _proveedores = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  // Sincronización real con el Backend
  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ProductosService.getProductos(),
        ClientesService.getClientes(),
        ProveedoresService.getProveedores(),
      ]);

      if (mounted) {
        setState(() {
          // 1. Productos usa PaginatedResponse -> accedemos a .count (o .results.length)
          final prodRes = results[0] as dynamic;
          _productos = prodRes.count ?? 0; 

          // 2. Clientes es una Lista directa -> usamos .length
          final clieRes = results[1] as List;
          _clientes = clieRes.length;

          // 3. Proveedores usa PaginatedResponse -> accedemos a .count
          final provRes = results[2] as dynamic;
          _proveedores = provRes.count ?? 0;

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error crítico en Dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF020617), Color(0xFF0F172A), Colors.black],
          ),
        ),
        child: SizedBox.expand(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
            : RefreshIndicator(
                onRefresh: _fetchStats, // Permite recargar deslizando hacia abajo
                color: Colors.cyan,
                backgroundColor: const Color(0xFF0F172A),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(),
                      const SizedBox(height: 32),
                      _buildStatsGrid(),
                      const SizedBox(height: 32),
                      _buildTeamSection(),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  // --- 1. SECCIÓN HERO ---
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.network(
                "https://images.unsplash.com/photo-1550751827-4bd374c3f58b",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Inventario Inteligente",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Gestión moderna de productos y operaciones con control total.",
                  style: TextStyle(fontSize: 14, color: Color(0xFFCBD5E1)),
                ),
                const SizedBox(height: 20),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.sync, color: Colors.cyan[400], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "SISTEMA EN LÍNEA",
                      style: TextStyle(
                        color: Colors.cyan[400],
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. GRID DE ESTADÍSTICAS ---
  Widget _buildStatsGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final double cardWidth = (constraints.maxWidth - 32) / 3;

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.start, 
        children: [
          _buildStatCard('Productos', _productos, Icons.inventory_2, Colors.cyan, cardWidth),
          _buildStatCard('Clientes', _clientes, Icons.people, const Color(0xFF10B981), cardWidth),
          _buildStatCard('Proveedores', _proveedores, Icons.local_shipping, Colors.orange, cardWidth),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.blueGrey, 
              letterSpacing: 1, 
              fontSize: 9, 
              fontWeight: FontWeight.bold
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value < 10 ? "0$value" : "$value",
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 32, 
              fontWeight: FontWeight.w900
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. SECCIÓN DE EQUIPO ---
  Widget _buildTeamSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: Colors.yellow, size: 24),
              SizedBox(width: 12),
              Text("Equipo", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildTeamMember("Erick P.", "LEAD DEV"),
              _buildTeamMember("Fernando L.", "DEVELOPER"),
              _buildTeamMember("Francisco S.", "UI ENGINEER"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String role) {
    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth > 400 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
      
      return Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: Colors.cyan, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, 
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(role, 
                    style: const TextStyle(color: Colors.cyan, fontSize: 9, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}