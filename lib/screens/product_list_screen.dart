import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService api = ApiService();
  List<dynamic> productos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    try {
      final data = await api.getProductos();
      if (!mounted) return; // 👈 seguridad
      setState(() {
        productos = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al cargar productos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Productos")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final p = productos[index];
                return ListTile(
                  title: Text(p["nombre"]),
                  subtitle: Text("Stock: ${p["stock"]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await api.eliminarProducto(p["id"]);
                      _loadProductos();
                    },
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, "/edit", arguments: p);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/create");
        },
      ),
    );
  }
}
