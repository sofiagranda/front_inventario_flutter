import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import '../../core/app_theme.dart';

class InventoryTable extends StatelessWidget {
  final List<InventoryItem> items;

  const InventoryTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.slate800), // #1e293b
        borderRadius: BorderRadius.circular(12),
        color: AppColors.slate950,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF0F172A)), // #0f172a
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text("ID", style: TextStyle(color: Colors.white))),
              DataColumn(label: Text("Nombre", style: TextStyle(color: Colors.white))),
              DataColumn(label: Text("Categoría", style: TextStyle(color: Colors.white))),
              DataColumn(label: Text("Stock", style: TextStyle(color: Colors.white))),
              DataColumn(label: Text("Proveedor", style: TextStyle(color: Colors.white))),
              DataColumn(label: Text("Fecha", style: TextStyle(color: Colors.white))),
            ],
            rows: items.map((item) {
              return DataRow(
                cells: [
                  DataCell(Center(child: Text(item.id.toString(), style: const TextStyle(color: Colors.white70)))),
                  DataCell(Text(item.nombre, style: const TextStyle(color: Colors.white))),
                  DataCell(Text(item.categoria, style: const TextStyle(color: Colors.white70))),
                  DataCell(Text(item.stock.toString(), 
                    style: TextStyle(
                      color: item.stock < 10 ? Colors.redAccent : Colors.white70,
                      fontWeight: item.stock < 10 ? FontWeight.bold : FontWeight.normal
                    )
                  )),
                  DataCell(Text(item.proveedor, style: const TextStyle(color: Colors.white70))),
                  DataCell(Text(item.fecha, style: const TextStyle(color: Colors.white70))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}