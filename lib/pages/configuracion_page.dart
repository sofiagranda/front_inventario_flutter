import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // IMPORTANTE
import '../providers/auth_provider.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage>
    with TickerProviderStateMixin {
  
  late AnimationController _mainController;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  void _handleLogout(BuildContext context) async {
    // Usamos el AuthProvider para cerrar sesión de verdad
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Leemos los datos reales del usuario desde el Provider
    final auth = context.watch<AuthProvider>();
    final String username = auth.user?.username ?? "Usuario";
    final bool isStaff = auth.user?.role == 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: FadeTransition(
        opacity: _mainController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(username),
              const SizedBox(height: 48),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 900) {
                    return Column(
                      children: [
                        _buildLeftColumn(username, isStaff),
                        const SizedBox(height: 32),
                        _buildRightColumn(context),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildLeftColumn(username, isStaff)),
                      const SizedBox(width: 32),
                      Expanded(flex: 1, child: _buildRightColumn(context)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String username) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -40,
          top: 0,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.15), // Ajustado de withValues
              shape: BoxShape.circle,
            ),
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyan.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.cyanAccent,
                size: 32,
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Configuración",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Panel de control > $username",
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeftColumn(String username, bool isStaff) {
    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.person,
          iconColor: Colors.blueAccent,
          title: "Información de la Cuenta",
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField("ID Usuario", username),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildInfoField(
                      "Rango de Acceso",
                      isStaff ? "ADMIN" : "USER",
                      isMono: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ajustes guardados localmente"))
                    );
                  },
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text("Guardar Cambios"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionCard(
          icon: Icons.dark_mode,
          iconColor: Colors.purpleAccent,
          title: "Sistema y Seguridad",
          child: Column(
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: "Alertas de Stock Crítico",
                desc: "Notificar si el inventario es menor a 10 unidades",
                color: Colors.amber,
                value: true,
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                icon: Icons.security,
                title: "Autenticación Reforzada",
                desc: "Solicitar credenciales para cambios sensibles",
                color: const Color(0xFF10B981),
                value: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F172A), Color(0xFF020617)],
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            children: [
              const Icon(Icons.storage, color: Colors.cyanAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                "INFRAESTRUCTURA",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                    SizedBox(width: 8),
                    Text(
                      "OPERACIONAL",
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildStackRow("Core Engine", "Django 4.2"),
              _buildStackRow("Frontend", "Flutter 3.24"),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text("FINALIZAR SESIÓN"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.all(24),
              side: BorderSide(color: Colors.redAccent.withOpacity(0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              backgroundColor: Colors.redAccent.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES (Sin cambios de diseño) ---

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value, {bool isMono = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isMono ? Colors.cyanAccent : Colors.white70,
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required bool value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStackRow(String label, String version) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(version, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}