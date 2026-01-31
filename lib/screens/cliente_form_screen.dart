// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ClienteFormScreen extends StatefulWidget {
//   @override
//   _ClienteFormScreenState createState() => _ClienteFormScreenState();
// }

// class _ClienteFormScreenState extends State<ClienteFormScreen> {
//   final _formKey = GlobalKey<FormState>();

//   // Controladores para los campos
//   final nombreController = TextEditingController();
//   final emailController = TextEditingController();
//   final telefonoController = TextEditingController();
//   final passwordController = TextEditingController();

//   Future<void> registrarCliente() async {
//     if (!_formKey.currentState!.validate()) return;

//     final url = Uri.parse(
//       "https://paredes-inventario-api.desarrollo-software.xyz/api/auth/registro_cliente/",
//     );

//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "username": nombreController.text.trim(),
//         "email": emailController.text.trim(),
//         "telefono": telefonoController.text.trim(),
//         "password": passwordController.text.trim(),
//       }),
//     );

//     if (response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Usuario y cliente creados correctamente")),
//       );
//       Navigator.pushReplacementNamed(context, '/login');
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Registro de Cliente")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: nombreController,
//                 decoration: InputDecoration(labelText: "Username"),
//                 validator: (val) =>
//                     val == null || val.isEmpty ? "Campo obligatorio" : null,
//               ),
//               TextFormField(
//                 controller: emailController,
//                 decoration: InputDecoration(labelText: "Email"),
//                 validator: (val) =>
//                     val == null || val.isEmpty ? "Campo obligatorio" : null,
//               ),
//               TextFormField(
//                 controller: telefonoController,
//                 decoration: InputDecoration(labelText: "Teléfono"),
//                 keyboardType: TextInputType.phone,
//                 validator: (val) =>
//                     val == null || val.isEmpty ? "Campo obligatorio" : null,
//               ),
//               TextFormField(
//                 controller: passwordController,
//                 decoration: InputDecoration(labelText: "Contraseña"),
//                 obscureText: true,
//                 validator: (val) =>
//                     val == null || val.isEmpty ? "Campo obligatorio" : null,
//               ),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: registrarCliente,
//                     child: Text("Registrarse"),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushReplacementNamed(context, '/login');
//                     },
//                     child: Text("Iniciar sesión"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
