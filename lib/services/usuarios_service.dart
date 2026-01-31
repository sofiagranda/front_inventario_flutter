import 'package:flutter/material.dart';
import 'package:inventario_app/models/pagination.dart';
import '../models/usuario.dart';
import '../models/categoria.dart'; // Para usar PaginatedResponse
import 'api_service.dart';

class UsuariosService {
  
  // getUsuarios
  static Future<PaginatedResponse<DjangoUser>> getUsuarios() async {
    final response = await api.get("usuarios/");
    
    final List<dynamic> resultsJson = response.data['results'];
    
    return PaginatedResponse<DjangoUser>(
      count: response.data['count'],
      next: response.data['next'],
      previous: response.data['previous'],
      results: resultsJson.map((json) => DjangoUser.fromJson(json)).toList(),
    );
  }

  // saveUsuario (Crear o Editar)
  static Future<DjangoUser> saveUsuario(int? id, Map<String, dynamic> data) async {
    try {
      if (id != null) {
        // PUT usuarios/{id}/
        final response = await api.dio.put("usuarios/$id/", data: data);
        return DjangoUser.fromJson(response.data);
      } else {
        // POST usuarios/
        final response = await api.dio.post("usuarios/", data: data);
        return DjangoUser.fromJson(response.data);
      }
    } catch (e) {
      // Replicamos tu console.error y el manejo de errores del servidor
      debugPrint("Error del servidor: $e");
      rethrow; 
    }
  }

  // deleteUsuario
  static Future<void> deleteUsuario(int id) async {
    await api.delete("usuarios/$id/");
  }
}