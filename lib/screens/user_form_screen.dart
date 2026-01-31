// // Dentro de tu State de UserForm
// bool _showPass = false;

// Widget _buildPasswordField() {
//   return TextFormField(
//     obscureText: !_showPass,
//     decoration: InputDecoration(
//       labelText: "Contraseña",
//       suffixIcon: IconButton(
//         icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
//         onPressed: () => setState(() => _showPass = !_showPass),
//       ),
//     ),
//   );
// }