class Proveedor {
  final int id;
  final String nombre;
  final String? contacto;
  final String? email;    // Estaba declarada...
  final String? telefono;
  final String? direccion;

  Proveedor({
    required this.id,
    required this.nombre,
    this.contacto,
    this.email,           // ✅ Agregado al constructor
    this.telefono,
    this.direccion,
  });

  // Convierte el JSON de la API a un objeto de Dart
  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      contacto: json['contacto'],
      email: json['email'],       // ✅ Agregado para recibirlo de la API
      telefono: json['telefono'],
      direccion: json['direccion'],
    );
  }

  // Convierte el objeto a un mapa para enviarlo a la API (POST/PATCH)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'contacto': contacto,
      'email': email,             // ✅ Agregado para enviarlo a la API
      'telefono': telefono,
      'direccion': direccion,
    };
  }
}