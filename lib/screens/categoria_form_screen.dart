// import 'package:flutter/material.dart';
// import '../services/api_service.dart';

// enum OrdenCategoria { nombreAsc, nombreDesc }

// class CategoriaFormScreen extends StatefulWidget {
//   const CategoriaFormScreen({super.key});

//   @override
//   State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
// }

// class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
//   final api = ApiService();
//   List<dynamic> _categorias = [];
//   List<dynamic> _categoriasFiltradas = []; // Lista para el buscador
//   OrdenCategoria _orden = OrdenCategoria.nombreAsc;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadCategorias();
//   }

//   Future<void> _loadCategorias() async {
//     final categorias = await api.getCategorias();
//     setState(() {
//       _categorias = categorias;
//       _aplicarFiltroYOrden(); // Centralizamos lógica
//     });
//   }

//   // --- LÓGICA DE FILTRADO Y ORDEN ---
//   void _aplicarFiltroYOrden() {
//     setState(() {
//       // 1. Filtrar por texto
//       _categoriasFiltradas = _categorias
//           .where(
//             (cat) => cat["nombre"].toString().toLowerCase().contains(
//               _searchController.text.toLowerCase(),
//             ),
//           )
//           .toList();

//       // 2. Ordenar el resultado
//       if (_orden == OrdenCategoria.nombreAsc) {
//         _categoriasFiltradas.sort(
//           (a, b) => a["nombre"].toString().compareTo(b["nombre"].toString()),
//         );
//       } else {
//         _categoriasFiltradas.sort(
//           (a, b) => b["nombre"].toString().compareTo(a["nombre"].toString()),
//         );
//       }
//     });
//   }

//   Future<void> _addCategoria() async {
//     final nombreController = TextEditingController();
//     final result = await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Nueva Categoría"),
//         content: TextField(
//           controller: nombreController,
//           decoration: const InputDecoration(labelText: "Nombre"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancelar"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await api.createCategoria({"nombre": nombreController.text});
//               if (!mounted) return;
//               Navigator.pop(context, true);
//             },
//             child: const Text("Guardar"),
//           ),
//         ],
//       ),
//     );
//     if (result == true) _loadCategorias();
//   }

//   Future<void> _editCategoria(Map<String, dynamic> categoria) async {
//     final nombreController = TextEditingController(text: categoria["nombre"]);
//     final result = await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Editar Categoría"),
//         content: TextField(
//           controller: nombreController,
//           decoration: const InputDecoration(labelText: "Nombre"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancelar"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await api.updateCategoria(categoria["id"], {
//                 "nombre": nombreController.text,
//               });
//               if (!mounted) return;
//               Navigator.pop(context, true);
//             },
//             child: const Text("Guardar"),
//           ),
//         ],
//       ),
//     );
//     if (result == true) _loadCategorias();
//   }

//   Future<void> _deleteCategoria(int id) async {
//     final confirm = await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Eliminar categoría"),
//         content: const Text("¿Seguro que deseas eliminar esta categoría?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Cancelar"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Eliminar"),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       await api.deleteCategoria(id);
//       _loadCategorias();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Administrar Categorías"),
//         actions: [
//           PopupMenuButton<OrdenCategoria>(
//             onSelected: (value) {
//               _orden = value;
//               _aplicarFiltroYOrden();
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: OrdenCategoria.nombreAsc,
//                 child: Text("A-Z"),
//               ),
//               const PopupMenuItem(
//                 value: OrdenCategoria.nombreDesc,
//                 child: Text("Z-A"),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // --- BUSCADOR ---
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: TextField(
//               controller: _searchController,
//               onChanged: (value) => _aplicarFiltroYOrden(),
//               decoration: InputDecoration(
//                 hintText: "Buscar categoría...",
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 isDense: true,
//               ),
//             ),
//           ),

//           // --- LISTA ---
//           Expanded(
//             child: ListView.builder(
//               itemCount: _categoriasFiltradas.length,
//               itemBuilder: (context, index) {
//                 final cat = _categoriasFiltradas[index];
//                 return ListTile(
//                   title: Text(cat["nombre"]),
//                   leading: const CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.category, color: Colors.black),
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.edit),
//                         onPressed: () => _editCategoria(cat),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.white),
//                         onPressed: () => _deleteCategoria(cat["id"]),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addCategoria,
//         backgroundColor: Colors.white, // Color de fondo del botón
//         child: const Icon(
//           Icons.add,
//           color: Colors.black, // Color del icono
//         ),
//       ),
//     );
//   }
// }
