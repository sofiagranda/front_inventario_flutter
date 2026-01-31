import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_theme.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _handleSubmit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor rellena todos los campos")),
      );
      return;
    }

    // 1. Referencia al provider antes del async
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() => _loading = true);

    try {
      final dio = Dio();
      final response = await dio.post(
        "https://paredes-inventario-api.desarrollo-software.xyz/api/auth/login/",
        data: {"username": username, "password": password},
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        
        final data = response.data;

        // 2. Guardamos sesión en disco y estado
        await authProvider.login(
          data['token'],
          AuthUser(
            id: data['user_id'] ?? 0,
            username: username,
            role: data['is_staff'] == true ? 'admin' : 'user',
          ),
        );

        // 3. Redirección manual al Dashboard
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/admin');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      // Captura el error específico del backend si existe
      String errorMsg = e.response?.data['detail'] ?? 
                        e.response?.data['error'] ?? 
                        "Credenciales incorrectas";
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con el servidor")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mantenemos tu diseño visual que está excelente
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 450),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.slate900.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.slate800),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text(
                  "Bienvenido",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ingresa tus credenciales para acceder",
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildLabel("USUARIO"),
          _buildTextField(
            controller: _usernameController,
            hint: "Ej: admin_01",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          _buildLabel("CONTRASEÑA"),
          _buildTextField(
            controller: _passwordController,
            hint: "••••••••",
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan500, // Usando tus colores
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Ingresar al Sistema",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoNote(),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES (Los mantenemos igual) ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.2),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cyan500, width: 1.5)),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cyan500.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan500.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.cyan500, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Si no posees una cuenta, por favor contacta al Administrador de TI.",
              style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}