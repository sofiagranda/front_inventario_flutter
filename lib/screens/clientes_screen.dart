// import 'package:flutter/material.dart';
// import 'package:inventario_app/screens/cliente_form_screen.dart';
// import '../services/api_service.dart';

// class ClientesScreen extends StatefulWidget {
//   const ClientesScreen({super.key});

//   @override
//   State<ClientesScreen> createState() => _ClientesScreenState();
// }

// class _ClientesScreenState extends State<ClientesScreen> {
//   final api = ApiService();
//   List<dynamic> _clientes = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadClientes();
//   }

//   Future<void> _loadClientes() async {
//     final clientes = await api.getClientes();
//     setState(() => _clientes = clientes);
//   }

//   Future<void> _openForm([Map<String, dynamic>? cliente]) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ClienteFormScreen(cliente: cliente),
//       ),
//     );

//     if (result == true) {
//       _loadClientes(); // recarga la lista si se guardó algo
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Clientes")),
//       body: ListView.builder(
//         itemCount: _clientes.length,
//         itemBuilder: (context, index) {
//           final cliente = _clientes[index];
//           return ListTile(
//             title: Text(cliente["nombre"]),
//             subtitle: Text(cliente["email"] ?? ""),
//             trailing: IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () => _openForm(cliente), // editar cliente
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _openForm(), // crear nuevo cliente
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }