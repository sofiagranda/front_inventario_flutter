// import 'package:flutter/material.dart';
// import '../core/app_theme.dart';
// import '../widgets/button.dart';

// class ProductFormScreen extends StatefulWidget {
//   final Map<String, dynamic>? selected;
//   const ProductFormScreen({super.key, this.selected});

//   @override
//   State<ProductFormScreen> createState() => _ProductFormScreenState();
// }

// class _ProductFormScreenState extends State<ProductFormScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   // Controladores (Como tu useState)
//   final _nameController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _stockController = TextEditingController();
//   String _selectedUnidad = 'unidades';
//   int _selectedCategoria = 0;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.selected != null) {
//       _nameController.text = widget.selected!['nombre'];
//       _priceController.text = widget.selected!['precio'].toString();
//       _stockController.text = widget.selected!['stock'].toString();
//       _selectedUnidad = widget.selected!['unidad'];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: AppColors.slate950,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.slate800),
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             // Simulación de la sección de Imagen de React
//             _buildImagePicker(),
//             const SizedBox(height: 24),
            
//             // Grid de campos (Nombre, Precio, etc.)
//             _buildTextField("Nombre del Producto", _nameController),
//             const SizedBox(height: 16),
            
//             Row(
//               children: [
//                 Expanded(child: _buildTextField("Precio Venta (\$)", _priceController, isNumber: true)),
//                 const SizedBox(width: 16),
//                 Expanded(child: _buildTextField("Stock Inicial", _stockController, isNumber: true)),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             _buildDropdown("Unidad", ['unidades', 'kg', 'litros'], _selectedUnidad, (val) {
//               setState(() => _selectedUnidad = val!);
//             }),
            
//             const SizedBox(height: 32),
            
//             // Botones de Acción
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
//                 ),
//                 const SizedBox(width: 12),
//                 CustomButton(
//                   label: widget.selected != null ? "💾 Actualizar" : "➕ Guardar",
//                   color: AppColors.cyan600,
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       // Lógica de onSave(formData)
//                     }
//                   },
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImagePicker() {
//     return Container(
//       height: 150,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: AppColors.slate900,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.slate800, style: BorderStyle.solid),
//       ),
//       child: const Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.image_outlined, color: Colors.grey, size: 40),
//           Text("Subir Imagen", style: TextStyle(color: Colors.grey, fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: controller,
//           keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//           decoration: const InputDecoration(), // Usa el estilo global del Theme
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//         const SizedBox(height: 6),
//         DropdownButtonFormField<String>(
//           value: value,
//           items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//           onChanged: onChanged,
//           decoration: const InputDecoration(),
//         ),
//       ],
//     );
//   }
// }