class Cliente {
  final int id;
  final String nombre;
  final String email;
  final String telefono;
  final int? user; // ID de la tabla de Usuarios (User)

  Cliente({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    this.user,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      user: json['user'], // Mapeo del ID de usuario
    );
  }
}