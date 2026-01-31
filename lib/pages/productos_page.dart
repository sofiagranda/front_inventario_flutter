import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/producto.dart';
import '../models/categoria.dart';
import '../services/productos_service.dart';
import '../services/categorias_service.dart';
import '../widgets/forms/product_form.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  List<Producto> _productos = [];
  List<Categoria> _categorias = [];
  bool _loading = false;
  int _currentPage = 1;
  int _totalItems = 0;
  String _search = "";
  int? _catFilter;

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
    _fetchProductos();
  }

  Future<void> _fetchCategorias() async {
    try {
      final response = await CategoriasService.getCategorias();
      if (!mounted) return;
      setState(() => _categorias = response.results);
    } catch (e) {
      debugPrint("Error cargando categorías: $e");
    }
  }

  Future<void> _fetchProductos() async {
    setState(() => _loading = true);
    try {
      final response = await ProductosService.getProductos(
        page: _currentPage,
        search: _search,
        categoria: _catFilter?.toString() ?? "", 
      );

      if (!mounted) return;

      setState(() {
        _productos = response.results;
        _totalItems = response.count; // Usamos el conteo real del backend
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnackBar("Error al cargar productos: $e");
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      )
    );
  }

  void _showForm([Producto? producto]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ProductForm(
          producto: producto,
          categorias: _categorias,
          onSave: (data, imagePath) async {
            try {
              await ProductosService.saveProducto(producto?.id, data, imagePath);
              if (!context.mounted) return;
              Navigator.pop(context);
              _fetchProductos();
              _showSnackBar(producto == null ? "🚀 Producto creado" : "✅ Producto actualizado");
            } catch (e) {
              if (!context.mounted) return;
              _showSnackBar("Error al guardar: $e");
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LÓGICA DE PERMISOS ACTUALIZADA
    final auth = context.watch<AuthProvider>();
    final bool isAdmin = (auth.user?.role.toLowerCase() == 'admin') || 
                         (auth.user?.isStaff ?? false);
    
    int totalPages = (_totalItems / 10).ceil().clamp(1, 999);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.cyan,
              elevation: 4,
              onPressed: () => _showForm(),
              child: const Icon(Icons.add, color: Color(0xFF020617), size: 30),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProductos,
          color: Colors.cyan,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFilterBar(),
                const SizedBox(height: 24),
                _loading
                    ? const SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator(color: Colors.cyan)),
                      )
                    : _buildProductGrid(isAdmin),
                const SizedBox(height: 32),
                _buildPaginationControls(totalPages),
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
        const Text(
          "Inventario",
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.cyan.withOpacity(0.2)),
          ),
          child: Text(
            "ITEMS: $_totalItems",
            style: const TextStyle(color: Colors.cyan, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Column(
      children: [
        TextField(
          onChanged: (val) {
            _search = val;
            _currentPage = 1;
            _fetchProductos();
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Buscar por nombre o código...",
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: const Icon(Icons.search, color: Colors.cyan),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _catFilter,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              hint: const Text("Todas las categorías", style: TextStyle(color: Colors.white70)),
              items: [
                const DropdownMenuItem(value: null, child: Text("Todas las categorías", style: TextStyle(color: Colors.white70))),
                ..._categorias.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.nombre, style: const TextStyle(color: Colors.white70)),
                )),
              ],
              onChanged: (val) {
                setState(() => _catFilter = val);
                _currentPage = 1;
                _fetchProductos();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(bool isAdmin) {
    if (_productos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text("No se encontraron productos", style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 400,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _productos.length,
      itemBuilder: (context, index) => _ProductCard(
        producto: _productos[index],
        isAdmin: isAdmin,
        onDelete: () => _confirmDelete(_productos[index]),
        onEdit: () => _showForm(_productos[index]),
      ),
    );
  }

  void _confirmDelete(Producto p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("¿Eliminar producto?", style: TextStyle(color: Colors.white)),
        content: Text("Esta acción no se puede deshacer para: ${p.nombre}", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ProductosService.deleteProducto(p.id!);
                _fetchProductos();
                _showSnackBar("🗑️ Producto eliminado");
              } catch (e) {
                _showSnackBar("Error al eliminar: $e");
              }
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 1 ? () { setState(() => _currentPage--); _fetchProductos(); } : null,
          icon: Icon(Icons.chevron_left, color: _currentPage > 1 ? Colors.cyan : Colors.white10),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: Text("$_currentPage / $totalPages", style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
        ),
        IconButton(
          onPressed: _currentPage < totalPages ? () { setState(() => _currentPage++); _fetchProductos(); } : null,
          icon: Icon(Icons.chevron_right, color: _currentPage < totalPages ? Colors.cyan : Colors.white10),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Producto producto;
  final bool isAdmin;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ProductCard({
    required this.producto,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    bool lowStock = producto.stock <= producto.cantidadMinima;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: producto.imagen != null
                      ? Image.network(
                          producto.imagen!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.white10, size: 40)),
                        )
                      : Container(
                          color: Colors.white.withOpacity(0.02),
                          child: const Icon(Icons.inventory, color: Colors.white10, size: 50)
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                    child: Text("\$${producto.precio}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.categoriaNombre.toUpperCase(), 
                  style: const TextStyle(color: Colors.cyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(producto.nombre, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage, size: 14, color: lowStock ? Colors.redAccent : Colors.greenAccent),
                        const SizedBox(width: 6),
                        Text("${producto.stock} ${producto.unidad}",
                          style: TextStyle(color: lowStock ? Colors.redAccent : Colors.greenAccent, 
                          fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    if (lowStock)
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                  ],
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text("Editar", style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            foregroundColor: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.redAccent,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}