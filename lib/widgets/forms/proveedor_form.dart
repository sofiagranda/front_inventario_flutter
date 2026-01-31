import 'package:flutter/material.dart';
import '../../models/proveedor.dart';
import '../../core/app_theme.dart';

class ProveedorForm extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> data) onSave;
  final Proveedor? selected;
  final VoidCallback onCancel;

  const ProveedorForm({
    super.key,
    required this.onSave,
    this.selected,
    required this.onCancel,
  });

  @override
  State<ProveedorForm> createState() => _ProveedorFormState();
}

class _ProveedorFormState extends State<ProveedorForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  @override
  void didUpdateWidget(ProveedorForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _initFields();
    }
  }

  void _initFields() {
    if (widget.selected != null) {
      _nombreController.text = widget.selected!.nombre;
      _emailController.text = widget.selected!.email ?? "";
      _telefonoController.text = widget.selected!.telefono ?? "";
    } else {
      _nombreController.clear();
      _emailController.clear();
      _telefonoController.clear();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await widget.onSave({
          "nombre": _nombreController.text.trim(),
          "email": _emailController.text.trim(),
          "telefono": _telefonoController.text.trim(),
        });
      } catch (e) {
        // Manejado por la página principal
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cálculo de ancho responsivo para los inputs
        double fieldWidth = constraints.maxWidth > 700 
            ? (constraints.maxWidth / 3) - 16 
            : double.infinity;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selected != null ? "✏️ Editando Proveedor" : "➕ Registrar Nuevo Proveedor",
                  style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildField(
                      label: "Nombre de la Empresa",
                      placeholder: "Ej: Tech Solutions",
                      controller: _nombreController,
                      validator: (v) => v!.isEmpty ? "Obligatorio" : null,
                      width: fieldWidth,
                    ),
                    _buildField(
                      label: "Correo Electrónico",
                      placeholder: "ventas@empresa.com",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      width: fieldWidth,
                    ),
                    _buildField(
                      label: "Teléfono de Contacto",
                      placeholder: "+593 99...",
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      width: fieldWidth,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // BOTONES RESPONSIVOS (WRAP evita el error de RenderFlex)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (widget.selected != null)
                      TextButton(
                        onPressed: _isLoading ? null : widget.onCancel,
                        child: const Text("Cancelar", 
                          style: TextStyle(color: Colors.white60)),
                      ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading 
                        ? const SizedBox(
                            width: 18, 
                            height: 18, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          )
                        : const Icon(Icons.save, size: 18),
                      label: Text(widget.selected != null ? "Actualizar" : "Guardar Proveedor"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required double width,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF020617),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          ),
        ],
      ),
    );
  }
}