// import 'package:flutter/material.dart';
// // Asegúrate de importar el modelo UserFormData que creamos en el archivo anterior
// import '../forms/user_form.dart'; 

// // Extendemos el modelo para incluir el ID, igual que en tu interfaz de React
// class User extends UserFormData {
//   final int id;

//   User({
//     required this.id,
//     required super.nombre,
//     required super.email,
//     required super.rol,
//   });
// }

// class UserTable extends StatelessWidget {
//   final List<User> users;
//   final Function(User) onEdit;
//   final Function(int) onDelete;

//   const UserTable({
//     super.key,
//     required this.users,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF0F172A),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF1E293B)),
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal, // Equivale al overflowX: "auto"
//         child: DataTable(
//           headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
//           dataRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)),
//           dividerThickness: 1.0,
//           columns: const [
//             DataColumn(label: Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('Nombre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('Rol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
//             DataColumn(label: Text('Acciones', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
//           ],
//           rows: users.map((user) {
//             return DataRow(
//               cells: [
//                 DataCell(Text(user.id.toString(), style: const TextStyle(color: Colors.white70))),
//                 DataCell(Text(user.nombre, style: const TextStyle(color: Colors.white))),
//                 DataCell(Text(user.email, style: const TextStyle(color: Colors.white))),
//                 DataCell(Text(user.rol, style: const TextStyle(color: Colors.white))),
//                 DataCell(
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
//                         onPressed: () => onEdit(user),
//                         tooltip: 'Editar',
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
//                         onPressed: () => onDelete(user.id),
//                         tooltip: 'Eliminar',
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }