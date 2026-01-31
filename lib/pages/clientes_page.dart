import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/cliente.dart';
import '../services/clientes_service.dart';
import '../widgets/forms/cliente_form.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  List<Cliente> _clientes = [];
  Cliente? _selected;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() => _loading = true);
    try {
      final response = await ClientesService.getClientes();
      setState(() {
        _clientes = response;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar("Error al cargar clientes: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleDelete(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("¿Eliminar cliente?", style: TextStyle(color: Colors.white)),
        content: const Text("Esto podría afectar su acceso al sistema.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await ClientesService.deleteCliente(id);
        _loadClientes();
        _showSnackBar("🗑️ Cliente eliminado correctamente", Colors.redAccent);
      } catch (e) {
        _showSnackBar("Error al eliminar: $e", Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. OBTENER ROL CON LÓGICA ROBUSTA
    final auth = context.watch<AuthProvider>();
    final bool isAdmin = (auth.user?.role.toLowerCase() == 'admin') || 
                         (auth.user?.isStaff ?? false);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),

              // 2. MOSTRAR FORMULARIO SOLO SI ES ADMIN
              if (isAdmin) ...[
                _buildFormSection(),
                const SizedBox(height: 40),
              ],

              const Text(
                "Listado de Clientes",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Colors.cyan),
                      ),
                    )
                  : _buildClientGrid(isAdmin), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.person_pin, color: Colors.cyan, size: 32),
        const SizedBox(width: 12),
        const Text(
          "Clientes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.cyan.withOpacity(0.2)),
          ),
          child: Text(
            "TOTAL: ${_clientes.length}",
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selected != null ? "✏️ Modificar Cliente" : "➕ Registrar Nuevo Cliente",
                style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
              ),
              if (_selected != null)
                IconButton(
                  onPressed: () => setState(() => _selected = null),
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClientForm(
            selected: _selected,
            onCancel: () => setState(() => _selected = null),
            onSave: (data) async {
              await ClientesService.saveCliente(_selected?.id, data);
              _loadClientes();
              _showSnackBar(
                _selected != null ? "Actualizado" : "Cliente y Usuario creados",
                _selected != null ? Colors.blue : Colors.green,
              );
              setState(() => _selected = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClientGrid(bool isAdmin) {
    if (_clientes.isEmpty) {
      return const Center(
        child: Text("No hay clientes registrados", style: TextStyle(color: Colors.white24)),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = constraints.maxWidth > 800 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 220,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: _clientes.length,
          itemBuilder: (context, index) {
            final c = _clientes[index];
            return _ClientCard(
              cliente: c,
              isAdmin: isAdmin,
              onEdit: () => setState(() {
                _selected = c;
                // Scroll suave al inicio para editar
                Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500));
              }),
              onDelete: () => _handleDelete(c.id),
            );
          },
        );
      },
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Cliente cliente;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientCard({
    required this.cliente,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.person_outline, color: Colors.cyan, size: 28),
              if (isAdmin)
                Row(
                  children: [
                    IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_note, color: Colors.blue)),
                    IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            cliente.nombre,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.mail_outline, cliente.email),
          const SizedBox(height: 4),
          _infoRow(Icons.phone_android, cliente.telefono),
          const Spacer(),
          const Divider(color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("USER ID: ${cliente.user ?? 'N/A'}", style: const TextStyle(color: Colors.white24, fontSize: 10)),
              Text("ID: ${cliente.id}", 
                style: const TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.cyan.withOpacity(0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}