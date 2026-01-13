import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final _storage = FlutterSecureStorage();
  final String baseUrl = "https://paredes-inventario-api.desarrollo-software.xyz/api";

  Future<String?> _getToken() async {
    return await _storage.read(key: "access");
  }

  Future<List<dynamic>> getProductos() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/productos/"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al cargar productos");
    }
  }

  Future<void> crearProducto(Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/productos/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      throw Exception("Error al crear producto");
    }
  }

  Future<void> editarProducto(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/productos/$id/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception("Error al editar producto");
    }
  }

  Future<void> eliminarProducto(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/productos/$id/"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode != 204) {
      throw Exception("Error al eliminar producto");
    }
  }
}
