import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/producto.dart';
import '../../models/categoria.dart';

class ProductForm extends StatefulWidget {
  final Producto? producto;
  final List<Categoria> categorias;
  final Function(Map<String, dynamic> data, String? imagePath) onSave;

  const ProductForm({
    super.key,
    this.producto,
    required this.categorias,
    required this.onSave,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _stockCtrl;
  int? _selectedCat;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? "");
    _precioCtrl = TextEditingController(text: p?.precio.toString() ?? "");
    _stockCtrl = TextEditingController(text: p?.stock.toString() ?? "");
    _selectedCat =
        p?.categoria ??
        (widget.categorias.isNotEmpty ? widget.categorias[0].id : null);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.producto == null ? "Nuevo Producto" : "Editar Producto",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Selector de Imagen
              GestureDetector(
                onTap: () => _showSourceOptions(),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : (widget.producto?.imagen != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  widget.producto!.imagen!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.add_a_photo,
                                color: Colors.cyan,
                                size: 40,
                              )),
                ),
              ),

              const SizedBox(height: 15),
              _buildInput("Nombre", _nombreCtrl),
              _buildInput("Precio", _precioCtrl, isNumber: true),
              _buildInput("Stock", _stockCtrl, isNumber: true),

              DropdownButtonFormField<int>(
                value: _selectedCat,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: widget.categorias
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCat = val),
                decoration: const InputDecoration(
                  labelText: "Categoría",
                  labelStyle: TextStyle(color: Colors.cyan),
                ),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      "nombre": _nombreCtrl.text,
                      "precio": double.parse(_precioCtrl.text),
                      "stock": int.parse(_stockCtrl.text),
                      "categoria": _selectedCat.toString(),
                      "cantidad_minima": 5,
                      "unidad": "unidades",
                    };
                    widget.onSave(data, _imageFile?.path);
                  }
                },
                child: const Text(
                  "GUARDAR",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galería'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
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

  Widget _buildInput(
    String label,
    TextEditingController ctrl, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      validator: (v) => v == null || v.isEmpty ? "Campo obligatorio" : null,
    );
  }
}
