import 'package:flutter/material.dart';
import 'package:inventario_app/services/categorias_service.dart';

class CategoriaForm extends StatefulWidget {
  final int? editingId;
  final String? initialNombre;
  final String? initialDesc;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const CategoriaForm({
    super.key,
    this.editingId,
    this.initialNombre,
    this.initialDesc,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<CategoriaForm> createState() => _CategoriaFormState();
}

class _CategoriaFormState extends State<CategoriaForm> {
  late TextEditingController _nombreController;
  late TextEditingController _descController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.initialNombre);
    _descController = TextEditingController(text: widget.initialDesc);
  }

  @override
  void didUpdateWidget(CategoriaForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el ID cambia (estamos editando otra), actualizamos los campos
    if (widget.editingId != oldWidget.editingId) {
      _nombreController.text = widget.initialNombre ?? "";
      _descController.text = widget.initialDesc ?? "";
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("El nombre es obligatorio")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Llamada al servicio
      await CategoriasService.saveCategoria(
        widget.editingId,
        _nombreController.text.trim(),
        _descController.text.trim(),
      );

      // 2. Definir el mensaje según la acción
      final mensaje = widget.editingId != null
          ? "✅ Categoría actualizada correctamente"
          : "✨ Categoría creada con éxito";

      // 3. Mostrar el SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 4. Limpiar y refrescar
      _nombreController.clear();
      _descController.clear();
      widget.onSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🚨 Error: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 500;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.editingId != null
                    ? "✏️ Editando Categoría"
                    : "➕ Nueva Categoría",
                style: const TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isMobile
                        ? double.infinity
                        : (constraints.maxWidth / 2) - 28,
                    child: _buildInput(
                      "Nombre",
                      _nombreController,
                      "Ej: Ferretería",
                    ),
                  ),
                  SizedBox(
                    width: isMobile
                        ? double.infinity
                        : (constraints.maxWidth / 2) - 28,
                    child: _buildInput(
                      "Descripción",
                      _descController,
                      "Opcional",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.editingId != null)
                    TextButton(
                      onPressed: widget.onCancel,
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[700],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.editingId != null ? "Actualizar" : "Guardar",
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
            filled: true,
            fillColor: const Color(0xFF020617),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E293B)),
            ),
          ),
        ),
      ],
    );
  }
}
