import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/proveedor.dart';
import '../services/proveedores_service.dart';
import '../widgets/forms/proveedor_form.dart';

class ProveedoresPage extends StatefulWidget {
  const ProveedoresPage({super.key});

  @override
  State<ProveedoresPage> createState() => _ProveedoresPageState();
}

class _ProveedoresPageState extends State<ProveedoresPage> {
  List<Proveedor> _proveedores = [];
  bool _loading = false;
  int? _editingId; 
  Proveedor? _proveedorSeleccionado;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final response = await ProveedoresService.getProveedores();
      if (!mounted) return;
      setState(() {
        _proveedores = response.results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnackBar("Error al cargar: $e", Colors.red);
    }
  }

  void _handleEdit(Proveedor p) {
    setState(() {
      _editingId = p.id;
      _proveedorSeleccionado = p;
    });
    // Scroll opcional hacia arriba si el formulario está arriba
  }

  Future<void> _handleDelete(int id) async {
    final confirmar = await _mostrarDialogoConfirmacion();
    if (confirmar != true) return;

    try {
      await ProveedoresService.deleteProveedor(id);
      _loadData();
      _showSnackBar("🗑️ Proveedor eliminado correctamente", Colors.orangeAccent);
    } catch (e) {
      _showSnackBar("Error al eliminar: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  Future<bool?> _mostrarDialogoConfirmacion() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("¿Eliminar?", style: TextStyle(color: Colors.white)),
        content: const Text("Esta acción borrará al proveedor permanentemente del sistema.", 
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LÓGICA DE PERMISOS UNIFICADA
    final auth = context.watch<AuthProvider>();
    final bool isAdmin = (auth.user?.role.toLowerCase() == 'admin') || 
                         (auth.user?.isStaff ?? false);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: Colors.cyan,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResponsiveHeader(),
                const SizedBox(height: 32),

                if (isAdmin) ...[
                  ProveedorForm(
                    selected: _proveedorSeleccionado,
                    onCancel: () => setState(() {
                      _editingId = null;
                      _proveedorSeleccionado = null;
                    }),
                    onSave: (data) async {
                      try {
                        final esActualizacion = _editingId != null;
                        await ProveedoresService.saveProveedor(_editingId, data);
                        setState(() {
                          _editingId = null;
                          _proveedorSeleccionado = null;
                        });
                        _loadData();
                        _showSnackBar(
                          esActualizacion ? "✅ Actualizado correctamente" : "🚀 Creado con éxito",
                          esActualizacion ? Colors.blue : Colors.green,
                        );
                      } catch (e) {
                        _showSnackBar("Error al procesar: $e", Colors.red);
                        rethrow;
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                const Text(
                  "Listado de Proveedores",
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _loading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: Colors.cyan),
                        ),
                      )
                    : _buildProveedoresGrid(isAdmin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping, color: Colors.cyan, size: 32),
            SizedBox(width: 12),
            Text("Proveedores", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
          ),
          child: Text("TOTAL: ${_proveedores.length}", 
            style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildProveedoresGrid(bool isAdmin) {
    if (_proveedores.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text("Sin registros encontrados", style: TextStyle(color: Colors.white24)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 750 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 180,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: _proveedores.length,
          itemBuilder: (context, index) {
            final p = _proveedores[index];
            return _ProveedorCard(
              proveedor: p,
              isAdmin: isAdmin,
              onEdit: () => _handleEdit(p),
              onDelete: () => _handleDelete(p.id),
            );
          },
        );
      },
    );
  }
}

class _ProveedorCard extends StatelessWidget {
  final Proveedor proveedor;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProveedorCard({
    required this.proveedor,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    proveedor.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isAdmin)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue, size: 24),
                        onPressed: onEdit,
                        tooltip: 'Editar proveedor',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                        onPressed: onDelete,
                        tooltip: 'Eliminar proveedor',
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.email_outlined, proveedor.email ?? "Sin email"),
            const SizedBox(height: 8),
            _infoRow(Icons.phone_android_outlined, proveedor.telefono ?? "Sin teléfono"),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.cyan.withOpacity(0.7), size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text, 
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14), 
            overflow: TextOverflow.ellipsis
          ),
        ),
      ],
    );
  }
}