import 'package:flutter/material.dart';
import 'package:inventario_app/models/usuario.dart';

class UserForm extends StatefulWidget {
  // Ajustamos nombres para que coincidan con la llamada en UsuariosPage
  final DjangoUser? selected; 
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;

  const UserForm({
    super.key,
    required this.onSave,
    this.selected,
    this.onCancel,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _passController;
  late TextEditingController _confirmPassController;
  bool _isStaff = false;

  bool _showPass = false;
  bool _showConfirmPass = false;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  // Sincroniza los campos cuando el widget se actualiza (clic en editar otro usuario)
  @override
  void didUpdateWidget(UserForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _initFields();
    }
  }

  void _initFields() {
    _nombreController = TextEditingController(text: widget.selected?.username ?? "");
    _emailController = TextEditingController(text: widget.selected?.email ?? "");
    _passController = TextEditingController();
    _confirmPassController = TextEditingController();
    _isStaff = widget.selected?.isStaff ?? false;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Validar coincidencia de password
      if (_passController.text != _confirmPassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Las contraseñas no coinciden")),
        );
        return;
      }

      // Preparamos el mapa para el UsuariosService
      final Map<String, dynamic> data = {
        'username': _nombreController.text.trim(),
        'email': _emailController.text.trim(),
        'is_staff': _isStaff,
      };

      if (_passController.text.isNotEmpty) {
        data['password'] = _passController.text;
      }

      widget.onSave(data);
    }
  }

  InputDecoration _inputStyle(String label, {Widget? suffixIcon, String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Responsive Grid usando Wrap o LayoutBuilder
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                _buildFieldWrapper("Username", _nombreController),
                _buildFieldWrapper("Email", _emailController, isEmail: true),
                _buildRolDropdown(),
                _buildFieldWrapper(
                  "Contraseña ${widget.selected != null ? '(Opcional)' : ''}", 
                  _passController, 
                  isPass: true,
                  showPass: _showPass,
                  togglePass: () => setState(() => _showPass = !_showPass)
                ),
                _buildFieldWrapper(
                  "Confirmar", 
                  _confirmPassController, 
                  isPass: true,
                  showPass: _showConfirmPass,
                  togglePass: () => setState(() => _showConfirmPass = !_showConfirmPass)
                ),
              ],
            ),
            const SizedBox(height: 25),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldWrapper(String label, TextEditingController controller, {bool isEmail = false, bool isPass = false, bool? showPass, VoidCallback? togglePass}) {
    return SizedBox(
      width: 250, // Ancho fijo para el efecto Grid en el Wrap
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        obscureText: isPass ? !(showPass ?? false) : false,
        decoration: _inputStyle(
          label,
          suffixIcon: isPass ? IconButton(
            icon: Icon(showPass! ? Icons.visibility_off : Icons.visibility, size: 18, color: const Color(0xFF94A3B8)),
            onPressed: togglePass,
          ) : null,
        ),
        validator: (val) {
          if (val == null || val.isEmpty) {
            if (isPass && widget.selected != null) return null; // Pass opcional en edición
            return "Requerido";
          }
          if (isEmail && !val.contains("@")) return "Email inválido";
          return null;
        },
      ),
    );
  }

  Widget _buildRolDropdown() {
    return SizedBox(
      width: 250,
      child: DropdownButtonFormField<bool>(
        value: _isStaff,
        dropdownColor: const Color(0xFF1E293B),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: _inputStyle("Rol / Permisos"),
        items: const [
          DropdownMenuItem(value: false, child: Text("Usuario Estándar")),
          DropdownMenuItem(value: true, child: Text("Administrador (Staff)")),
        ],
        onChanged: (val) => setState(() => _isStaff = val!),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onCancel != null)
          TextButton(
            onPressed: widget.onCancel,
            child: const Text("Cancelar", style: TextStyle(color: Color(0xFF94A3B8))),
          ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _handleSubmit,
          icon: const Icon(Icons.save, size: 18),
          label: Text(widget.selected != null ? "Actualizar" : "Registrar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF38BDF8),
            foregroundColor: const Color(0xFF020617),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}