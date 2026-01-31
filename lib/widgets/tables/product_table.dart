import 'package:flutter/material.dart';
import '../../models/producto.dart';
import '../../core/app_theme.dart';

class ProductTable extends StatelessWidget {
  final List<Producto> productos;
  final Function(Producto producto) onEdit;
  final Function(int id) onDelete;

  const ProductTable({
    super.key,
    required this.productos,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 64,
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
            DataColumn(label: Text("Imagen")), // Columna extra visual
            DataColumn(label: Text("Nombre")),
            DataColumn(label: Text("Precio")),
            DataColumn(label: Text("Stock")),
            DataColumn(label: Text("Acciones")),
          ],
          rows: productos.map((producto) {
            return DataRow(
              cells: [
                // Miniatura del producto
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: producto.imagen != null
                          ? Image.network(
                              producto.imagen!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image, color: Colors.grey),
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                DataCell(Text(producto.nombre, style: const TextStyle(color: Colors.white))),
                DataCell(Text("\$${producto.precio.toStringAsFixed(2)}", 
                    style: const TextStyle(color: Colors.white70))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: producto.stock < 5 ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${producto.stock} ${producto.unidad}",
                      style: TextStyle(
                        color: producto.stock < 5 ? Colors.redAccent : Colors.white70,
                        fontWeight: producto.stock < 5 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.amber, size: 20),
                        onPressed: () => onEdit(producto),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          if (producto.id != null) onDelete(producto.id!);
                        },
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
}