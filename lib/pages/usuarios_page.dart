import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/usuario.dart';
import '../services/usuarios_service.dart';
import '../widgets/forms/user_form.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<DjangoUser> _usuarios = [];
  bool _loading = false;
  DjangoUser? _editingUser;

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    setState(() => _loading = true);
    try {
      final response = await UsuariosService.getUsuarios();
      if (!mounted) return;
      setState(() {
        _usuarios = response.results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnackBar("Error al cargar usuarios: $e", Colors.red);
    }
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("¿Eliminar usuario?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Esta acción revocará permanentemente el acceso de este usuario al sistema.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await UsuariosService.deleteUsuario(id);
        _loadUsuarios();
        _showSnackBar("🗑️ Usuario eliminado", Colors.redAccent);
      } catch (e) {
        _showSnackBar("Error: $e", Colors.red);
      }
    }
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    // Usamos la lógica híbrida: Rol Admin o Flag isStaff
    final bool isAdmin = (auth.user?.role.toLowerCase() == 'admin') || 
                         (auth.user?.isStaff ?? false);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUsuarios,
          color: Colors.cyan,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),

                if (isAdmin) ...[
                  _buildUserFormSection(),
                  const SizedBox(height: 40),
                ],

                _buildListTitle(isAdmin),
                const SizedBox(height: 20),

                _loading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(60.0),
                          child: CircularProgressIndicator(color: Colors.cyan),
                        ),
                      )
                    : _buildUserGrid(isAdmin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.people_alt_rounded, color: Colors.cyan, size: 32),
            SizedBox(width: 12),
            Text(
              "Usuarios",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyan.withOpacity(0.2)),
          ),
          child: Text(
            "ACTIVOS: ${_usuarios.length}",
            style: const TextStyle(color: Colors.cyan, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildUserFormSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _editingUser != null
                    ? "✏️ Editando Usuario"
                    : "➕ Registrar Usuario",
                style: const TextStyle(color: Colors.cyan, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_editingUser != null)
                TextButton.icon(
                  onPressed: () => setState(() => _editingUser = null),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text("CANCELAR"),
                  style: TextButton.styleFrom(foregroundColor: Colors.white38),
                ),
            ],
          ),
          const SizedBox(height: 20),
          UserForm(
            selected: _editingUser,
            onSave: (data) async {
              final isEdit = _editingUser != null;
              await UsuariosService.saveUsuario(_editingUser?.id, data);
              setState(() => _editingUser = null);
              _loadUsuarios();
              _showSnackBar(
                isEdit ? "Usuario actualizado" : "Usuario creado con éxito",
                isEdit ? Colors.blueAccent : Colors.green,
              );
            },
            onCancel: () => setState(() => _editingUser = null),
          ),
        ],
      ),
    );
  }

  Widget _buildListTitle(bool isAdmin) {
    return Row(
      children: [
        const Text(
          "Personal Registrado",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        if (!isAdmin)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.amber.withOpacity(0.2)),
            ),
            child: const Text(
              "SÓLO LECTURA",
              style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.w900),
            ),
          ),
      ],
    );
  }

  Widget _buildUserGrid(bool isAdmin) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        double height = isAdmin ? 210 : 150;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: height,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _usuarios.length,
          itemBuilder: (context, index) {
            return _UserCard(
              user: _usuarios[index],
              isAdmin: isAdmin,
              onEdit: (user) {
                setState(() => _editingUser = user);
                Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 600));
              },
              onDelete: (id) => _handleDelete(id),
            );
          },
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final DjangoUser user;
  final bool isAdmin;
  final Function(DjangoUser) onEdit;
  final Function(int) onDelete;

  const _UserCard({
    required this.user,
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
            children: [
              CircleAvatar(
                backgroundColor: Colors.cyan.withOpacity(0.1),
                child: Text(user.username[0].toUpperCase(), 
                  style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.username,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(user.email,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBadge(),
          const Spacer(),
          if (isAdmin)
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => onEdit(user),
                    icon: const Icon(Icons.edit_rounded, size: 14),
                    label: const Text("Editar", style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.cyan.withOpacity(0.05),
                      foregroundColor: Colors.cyan,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => onDelete(user.id!),
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  style: IconButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    final isStaff = user.isStaff;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isStaff ? Colors.purple.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isStaff ? Colors.purple.withOpacity(0.2) : Colors.teal.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isStaff ? Icons.admin_panel_settings : Icons.badge, 
            size: 12, color: isStaff ? Colors.purpleAccent : Colors.tealAccent),
          const SizedBox(width: 6),
          Text(
            isStaff ? "ADMINISTRADOR" : "USUARIO",
            style: TextStyle(
              color: isStaff ? Colors.purpleAccent : Colors.tealAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}