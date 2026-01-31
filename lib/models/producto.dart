class Producto {
  final int? id;
  final String nombre;
  final double precio;
  final int stock;
  final int cantidadMinima;
  final String unidad;
  final int? categoria;
  final String categoriaNombre; // Coincide con tu JSON
  final String? imagen;

  Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.cantidadMinima,
    required this.unidad,
    this.categoria,
    required this.categoriaNombre,
    this.imagen,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      // Convertimos el String "1.99" a double
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      stock: json['stock'] ?? 0,
      cantidadMinima: json['cantidad_minima'] ?? 0,
      unidad: json['unidad'] ?? 'unidades',
      categoria: json['categoria'],
      categoriaNombre: json['categoria_nombre'] ?? 'Sin categoría',
      imagen: json['imagen'],
    );
  }
}