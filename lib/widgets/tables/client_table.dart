import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../core/app_theme.dart';

class ClientTable extends StatelessWidget {
  final List<Cliente> clientes;
  final Function(Cliente cliente) onEdit;
  final Function(int id) onDelete;

  const ClientTable({
    super.key,
    required this.clientes,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay datos, mostramos un mensaje amigable
    if (clientes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("No hay clientes registrados", 
            style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Permite scroll lateral en pantallas pequeñas
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 48,
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.slate900),
          dataRowColor: WidgetStateProperty.all(AppColors.slate950),
          columnSpacing: 24,
          headingTextStyle: const TextStyle(
            color: AppColors.cyan500,
            fontWeight: FontWeight.bold,
          ),
          columns: const [
            DataColumn(label: Text("Nombre")),
            DataColumn(label: Text("Email")),
            DataColumn(label: Text("Teléfono")),
            DataColumn(label: Text("Acciones")),
          ],
          rows: clientes.map((cliente) {
            return DataRow(
              cells: [
                DataCell(Text(cliente.nombre, style: const TextStyle(color: Colors.white))),
                DataCell(Text(cliente.email, style: const TextStyle(color: Colors.white70))),
                DataCell(Text(cliente.telefono ?? "-", style: const TextStyle(color: Colors.white70))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.amber, size: 20),
                        onPressed: () => onEdit(cliente),
                        tooltip: "Editar",
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _confirmDelete(context, cliente),
                        tooltip: "Eliminar",
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Función auxiliar para confirmar eliminación (Buena práctica en Flutter)
  void _confirmDelete(BuildContext context, Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate900,
        title: const Text("Confirmar eliminación", style: TextStyle(color: Colors.white)),
        content: Text("¿Estás seguro de eliminar a ${cliente.nombre}?", 
          style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(cliente.id!);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}