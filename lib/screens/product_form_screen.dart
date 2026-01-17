import 'dart:io'; // Necesario para manejar el archivo físico
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Asegúrate de haber hecho 'flutter pub add image_picker'
import 'package:inventario_app/screens/categoria_form_screen.dart';
import '../services/api_service.dart';

class ProductoFormScreen extends StatefulWidget {
  final Map<String, dynamic>? producto; // null si es nuevo

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final api = ApiService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nombreController;
  late TextEditingController _stockController;
  late TextEditingController _precioController;
  List<dynamic> _categorias = [];
  int? _categoriaSeleccionada;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
    _nombreController = TextEditingController(
      text: widget.producto?["nombre"] ?? "",
    );
    _stockController = TextEditingController(
      text: widget.producto?["stock"]?.toString() ?? "",
    );
    _precioController = TextEditingController(
      text: widget.producto?["precio"]?.toString() ?? "",
    );
    _categoriaSeleccionada = widget.producto?["categoria"];
  }

  Future<void> _loadCategorias() async {
    final categorias = await api.getCategorias();
    setState(() => _categorias = categorias);
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1000, 
      maxHeight: 1000,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Cámara'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProducto() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "nombre": _nombreController.text,
        "stock": int.parse(_stockController.text),
        "precio": double.parse(_precioController.text),
        "categoria": _categoriaSeleccionada,
      };

      try {
        if (widget.producto == null) {
          // Enviamos data + el archivo de imagen
          await api.crearProducto(data, _imageFile);
        } else {
          // Enviamos ID + data + el archivo de imagen
          await api.editarProducto(widget.producto!["id"], data, _imageFile);
        }
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } // regresa indicando que se guardó
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.producto == null ? "Nuevo Producto" : "Editar Producto",
        ),
      ),
      body: SingleChildScrollView(
        // Para que no de error al abrir el teclado
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- SECCIÓN DE IMAGEN ---
              GestureDetector(
                onTap: _showImageSourceOptions,
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : (widget.producto?["imagen"] != null
                                  ? Image.network(
                                      widget.producto!["imagen"],
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(
                                      child: Icon(Icons.add_a_photo, size: 50),
                                    )),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Toca para cambiar imagen",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese un nombre" : null,
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: "Stock"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Ingrese stock" : null,
              ),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: "Precio"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Ingrese precio" : null,
              ),
              DropdownButtonFormField<int>(
                initialValue:
                    _categoriaSeleccionada != null &&
                        _categorias.any(
                          (cat) => cat["id"] == _categoriaSeleccionada,
                        )
                    ? _categoriaSeleccionada
                    : null,
                items: [
                  ..._categorias.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat["id"],
                      child: Text(cat["nombre"]),
                    );
                  }),
                  const DropdownMenuItem<int>(
                    value: -1,
                    child: Text("+ Añadir categoría"),
                  ),
                ],
                onChanged: (value) async {
                  if (value == -1) {
                    final nuevaCategoria = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoriaFormScreen(),
                      ),
                    );
                    if (nuevaCategoria != null) {
                      _loadCategorias();
                      setState(
                        () => _categoriaSeleccionada = nuevaCategoria["id"],
                      );
                    }
                  } else {
                    setState(() => _categoriaSeleccionada = value);
                  }
                },
                decoration: const InputDecoration(labelText: "Categoría"),
                validator: (value) =>
                    value == null ? "Seleccione una categoría" : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _saveProducto,
                  child: const Text(
                    "Guardar Producto",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
