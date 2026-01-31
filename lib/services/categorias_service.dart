import 'package:dio/dio.dart';
import 'package:inventario_app/models/pagination.dart';

import '../models/categoria.dart';
import 'api_service.dart'; // Donde configuraste la instancia de Dio llamada 'api'

class CategoriasService {
  
  // 1. Obtener categorías (Soporta paginación por URL o parámetros)
  static Future<PaginatedResponse<Categoria>> getCategorias({String? url}) async {
    try {
      // Si recibimos una URL (de 'next' o 'previous'), la usamos, si no, la base
      final String path = url ?? "categorias/";
      
      final response = await api.get(path);
      final List<dynamic> resultsJson = response.data['results'];

      return PaginatedResponse<Categoria>(
        count: response.data['count'],
        next: response.data['next'],
        previous: response.data['previous'],
        results: resultsJson.map((json) => Categoria.fromJson(json)).toList(),
      );
    } catch (e) {
      throw Exception("Error al obtener categorías: $e");
    }
  }

  // 2. Guardar o Editar
  // Usamos Map<String, dynamic> para enviar solo lo necesario
  static Future<void> saveCategoria(int? id, String nombre, String descripcion) async {
    try {
      final data = {"nombre": nombre, "descripcion": descripcion};
      print("🚀 [SAVE] Intentando guardar. ID: $id | Data: $data");

      Response response;
      if (id != null) {
        print("📝 [PATCH] Editando categoría $id...");
        response = await api.patch("categorias/$id/", data: data);
      } else {
        print("➕ [POST] Creando nueva categoría...");
        response = await api.post("categorias/", data: data);
      }
      print("✅ [SUCCESS] Respuesta del servidor: ${response.statusCode}");
    } on DioException catch (e) {
      print("❌ [DIO ERROR] Status: ${e.response?.statusCode}");
      print("❌ [DETALLE] Body: ${e.response?.data}");
      print("❌ [URL] Path: ${e.requestOptions.path}");
      rethrow;
    } catch (e) {
      print("🚨 [ERROR GENÉRICO]: $e");
      rethrow;
    }
  }

  static Future<void> deleteCategoria(int id) async {
    try {
      print("🗑️ [DELETE] Intentando eliminar ID: $id");
      final response = await api.delete("categorias/$id/");
      print("✅ [SUCCESS] Eliminado. Status: ${response.statusCode}");
    } on DioException catch (e) {
      print("❌ [DIO ERROR] Status: ${e.response?.statusCode}");
      print("❌ [DETALLE] Body: ${e.response?.data}");
      rethrow;
    }
  }
}