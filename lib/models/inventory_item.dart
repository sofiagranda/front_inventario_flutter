class InventoryItem {
  final int id;
  final String nombre;
  final String categoria;
  final int stock;
  final String proveedor;
  final String fecha;

  InventoryItem({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.stock,
    required this.proveedor,
    required this.fecha,
  });
}