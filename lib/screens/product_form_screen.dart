import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? producto;
  final bool editMode;

  const ProductFormScreen({super.key, this.producto, required this.editMode});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = ApiService();

  late TextEditingController _nombreController;
  late TextEditingController _stockController;
  late TextEditingController _precioController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.producto?["nombre"] ?? "",
    );
    _stockController = TextEditingController(
      text: widget.producto?["stock"]?.toString() ?? "",
    );
    _precioController = TextEditingController(
      text: widget.producto?["precio"]?.toString() ?? "",
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "nombre": _nombreController.text,
        "stock": int.tryParse(_stockController.text) ?? 0,
        "precio": double.tryParse(_precioController.text) ?? 0.0,
      };

      try {
        if (widget.editMode) {
          await api.editarProducto(widget.producto!["id"], data);
        } else {
          await api.crearProducto(data);
        }
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al guardar producto")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editMode ? "Editar Producto" : "Nuevo Producto"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingrese un nombre" : null,
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: "Stock"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingrese stock" : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: "Precio"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? "Ingrese precio" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: Text(widget.editMode ? "Actualizar" : "Crear"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
