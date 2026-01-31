import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../core/app_theme.dart';

class ClientForm extends StatefulWidget {
  final Cliente? selected;
  final Future<void> Function(Map<String, dynamic> data) onSave; // Agregado Future para manejo de carga
  final VoidCallback onCancel;

  const ClientForm({
    super.key,
    this.selected,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.selected != null) {
      _nombreController.text = widget.selected!.nombre;
      _emailController.text = widget.selected!.email;
      // Solución al error String? -> String
      _telefonoController.text = widget.selected!.telefono ?? "";
    } else {
      _nombreController.clear();
      _emailController.clear();
      _telefonoController.clear();
      _passwordController.clear();
    }
  }

  @override
  void didUpdateWidget(ClientForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final data = {
          "nombre": _nombreController.text.trim(),
          "email": _emailController.text.trim(),
          "telefono": _telefonoController.text.trim(),
        };

        if (widget.selected == null) {
          data["password"] = _passwordController.text;
        }

        await widget.onSave(data);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el espacio es poco, los inputs ocupan todo el ancho
        double inputWidth = constraints.maxWidth > 700 
            ? (constraints.maxWidth / 2) - 16 
            : double.infinity;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildInput("Nombre Completo", _nombreController, width: inputWidth, isRequired: true),
                  _buildInput("Email / Username", _emailController, width: inputWidth, isRequired: true, isEmail: true),
                  _buildInput("Teléfono", _telefonoController, width: inputWidth),
                  
                  if (widget.selected == null)
                    _buildInput(
                      "Contraseña para el nuevo usuario", 
                      _passwordController, 
                      width: inputWidth,
                      isRequired: true, 
                      isPassword: true
                    ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Botones con Wrap para evitar overflow en pantallas pequeñas
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (widget.selected != null)
                    TextButton.icon(
                      onPressed: _isLoading ? null : widget.onCancel,
                      icon: const Icon(Icons.close),
                      label: const Text("Cancelar"),
                      style: TextButton.styleFrom(foregroundColor: Colors.white54),
                    ),
                  
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSubmit,
                    icon: _isLoading 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                    label: Text(widget.selected != null ? "Guardar" : "Registrar Cliente"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInput(String label, TextEditingController controller, 
      {required double width, bool isRequired = false, bool isEmail = false, bool isPassword = false}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            style: const TextStyle(color: Colors.white),
            keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ) 
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1E293B)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1E293B)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cyan500),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.trim().isEmpty)) {
                return "Este campo es obligatorio";
              }
              if (isEmail && value != null && !value.contains('@')) {
                return "Ingrese un email válido";
              }
              if (isPassword && value != null && value.length < 6) {
                return "Mínimo 6 caracteres";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}