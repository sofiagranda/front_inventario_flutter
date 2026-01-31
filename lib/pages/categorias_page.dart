import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // IMPORTANTE: Para acceder al Provider
import '../providers/auth_provider.dart';
import '../models/categoria.dart';
import '../services/categorias_service.dart';
import '../widgets/forms/categoria_form.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  // --- ESTADOS ---
  List<Categoria> _categorias = [];
  bool _loading = false;

  // Estado de Paginación
  String? _nextUrl;
  String? _prevUrl;
  int _totalItems = 0;

  // Estado de Edición
  int? _editingId;
  String _editingNombre = "";
  String _editingDesc = "";

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  // --- LÓGICA DE CARGA ---
  Future<void> _loadCategorias({String? url}) async {
    setState(() => _loading = true);
    try {
      final response = await CategoriasService.getCategorias(url: url);
      setState(() {
        _categorias = response.results;
        _nextUrl = response.next;
        _prevUrl = response.previous;
        _totalItems = response.count;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar("Error: $e", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // --- ACCIONES CRUD ---
  void _handleEdit(Categoria cat) {
    setState(() {
      _editingId = cat.id;
      _editingNombre = cat.nombre;
      _editingDesc = cat.descripcion ?? "";
    });
    // Opcional: Scroll al inicio para ver el formulario de edición
  }

  void _cancelEdit() {
    setState(() {
      _editingId = null;
      _editingNombre = "";
      _editingDesc = "";
    });
  }

  Future<void> _handleDelete(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("¿Eliminar?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "¿Estás seguro de eliminar esta categoría?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await CategoriasService.deleteCategoria(id);
        _loadCategorias();
        _showSnackBar("Eliminado correctamente", Colors.green);
      } catch (e) {
        _showSnackBar("Error al eliminar: $e", Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // LEEMOS EL ROL DESDE EL PROVIDER
    final auth = context.watch<AuthProvider>();
    debugPrint("--- DATOS DEL USUARIO ---");
    debugPrint("Username: ${auth.user?.username}");
    debugPrint(
      "¿Es Staff?: ${auth.user?.isStaff}",
    ); // Si ya tienes este campo en el modelo
    debugPrint("Rol: ${auth.user?.role}");
    // Si tu modelo User tiene un método para ver el JSON original, úsalo:
    // debugPrint("Raw User: ${auth.user?.toString()}");
    debugPrint("-------------------------");
    final bool isAdmin =
        (auth.user?.role.toLowerCase() == 'admin') ||
        (auth.user?.isStaff ?? false);

    debugPrint("Acceso total concedido: $isAdmin");
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),

              // FORMULARIO: Solo visible para Administradores
              if (isAdmin) ...[
                CategoriaForm(
                  editingId: _editingId,
                  initialNombre: _editingNombre,
                  initialDesc: _editingDesc,
                  onCancel: _cancelEdit,
                  onSuccess: () {
                    _loadCategorias();
                    _cancelEdit();
                  },
                ),
                const SizedBox(height: 32),
              ],

              const Text(
                "Listado de Categorías",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
                  : Column(
                      children: [
                        _buildGrid(isAdmin), // PASAMOS isAdmin AL GRID
                        const SizedBox(height: 24),
                        _buildPaginationControls(),
                      ],
                    ),
            ],
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
            Icon(Icons.category, color: Colors.cyan, size: 28),
            SizedBox(width: 12),
            Text(
              "Categorías",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
          ),
          child: Text(
            "TOTAL: $_totalItems",
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

  Widget _buildGrid(bool isAdmin) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = constraints.maxWidth > 800
            ? 3
            : (constraints.maxWidth > 500 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 110,
          ),
          itemCount: _categorias.length,
          itemBuilder: (context, index) {
            final cat = _categorias[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cat.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.descripcion ?? "Sin descripción",
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // BOTONES DE ACCIÓN: Solo visibles si isAdmin es true
                  if (isAdmin) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () => _handleEdit(cat),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: () => _handleDelete(cat.id),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _prevUrl == null
              ? null
              : () => _loadCategorias(url: _prevUrl),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
          ),
          child: const Icon(Icons.arrow_back_ios, size: 14),
        ),
        const SizedBox(width: 20),
        const Text("Páginas", style: TextStyle(color: Colors.white54)),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _nextUrl == null
              ? null
              : () => _loadCategorias(url: _nextUrl),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
          ),
          child: const Icon(Icons.arrow_forward_ios, size: 14),
        ),
      ],
    );
  }
}
