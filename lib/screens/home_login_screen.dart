import 'package:flutter/material.dart';
import 'package:inventario_app/screens/product_form_screen.dart';
import 'package:inventario_app/screens/categoria_form_screen.dart';
import '../services/api_service.dart';

class HomeLoginScreen extends StatefulWidget {
  const HomeLoginScreen({super.key});

  @override
  State<HomeLoginScreen> createState() => _HomeLoginScreenState();
}

class _HomeLoginScreenState extends State<HomeLoginScreen> {
  final api = ApiService();
  List<dynamic> _productos = [];
  List<dynamic> _productosFiltrados = [];
  List<dynamic> _categorias = [];

  // Variables para los filtros
  int? _categoriaFiltroId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    final productos = await api.getProductos();
    final categorias = await api.getCategorias();
    print("Categorías cargadas: ${categorias.length}");
    setState(() {
      _productos = productos;
      _categorias = categorias;
      _aplicarFiltros();
    });
  }

  void _aplicarFiltros() {
    setState(() {
      _productosFiltrados = _productos.where((prod) {
        final coincideNombre = prod["nombre"].toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );

        // Si _categoriaFiltroId es null, muestra todos. Si no, filtra por ID.
        final coincideCategoria =
            _categoriaFiltroId == null ||
            prod["categoria"] == _categoriaFiltroId;

        return coincideNombre && coincideCategoria;
      }).toList();
    });
  }

  // --- FUNCIONES DE ORDENAMIENTO ---
  void _sortAZ() {
    setState(() {
      _productosFiltrados.sort(
        (a, b) => a["nombre"].toString().toLowerCase().compareTo(
          b["nombre"].toString().toLowerCase(),
        ),
      );
    });
  }

  void _sortZA() {
    setState(() {
      _productosFiltrados.sort(
        (a, b) => b["nombre"].toString().toLowerCase().compareTo(
          a["nombre"].toString().toLowerCase(),
        ),
      );
    });
  }

  void _sortByCategoria() {
    setState(() {
      _productosFiltrados.sort(
        (a, b) => (a["categoria_nombre"] ?? "").compareTo(
          b["categoria_nombre"] ?? "",
        ),
      );
    });
  }

  Future<void> _editProducto(Map<String, dynamic> producto) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductoFormScreen(producto: producto)),
    );
    if (result == true) _loadProductos();
  }

  Future<void> _deleteProducto(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: const Text("¿Seguro que deseas eliminar este producto?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await api.eliminarProducto(id);
      _loadProductos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventario"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'az') _sortAZ();
              if (value == 'za') _sortZA();
              if (value == 'cat') _sortByCategoria();
              if (value == 'add_cat') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoriaFormScreen(),
                  ),
                );
                _loadProductos();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'az', child: Text("Ordenar A-Z")),
              const PopupMenuItem(value: 'za', child: Text("Ordenar Z-A")),
              const PopupMenuItem(
                value: 'cat',
                child: Text("Ordenar por Categoría"),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'add_cat',
                child: Text("+ Añadir Categoría"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // --- BUSCADOR Y COMBO DE CATEGORÍAS ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3, // El buscador ocupa más espacio
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _aplicarFiltros(),
                    decoration: InputDecoration(
                      hintText: "Buscar...",
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2, // El combo ocupa el resto
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _categoriaFiltroId,
                        isExpanded: true,
                        hint: const Text("Categoría"),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text("Todas"),
                          ),
                          ..._categorias.map((cat) {
                            return DropdownMenuItem<int?>(
                              // Aseguramos que el ID sea int. Si tu BD usa String, usa int.parse()
                              value: cat["id"] as int,
                              child: Text(cat["nombre"].toString()),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _categoriaFiltroId = value;
                            _aplicarFiltros();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- LISTA DE PRODUCTOS ---
          Expanded(
            child: ListView.builder(
              itemCount: _productosFiltrados.length,
              itemBuilder: (context, index) {
                final producto = _productosFiltrados[index];
                return ListTile(
                  title: Text(producto["nombre"]),
                  subtitle: Text(
                    "Cat: ${producto["categoria_nombre"] ?? 'S/C'} - \$${producto["precio"]}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editProducto(producto),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => _deleteProducto(producto["id"]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductoFormScreen()),
          );
          if (result == true) _loadProductos();
        },
        backgroundColor: Colors.white, // Color de fondo del botón
        child: const Icon(
          Icons.add,
          color: Colors.black, // Color del icono
        ),
      ),
    );
  }
}
