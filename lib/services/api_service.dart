import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final _storage = FlutterSecureStorage();
  final String baseUrl =
      "https://paredes-inventario-api.desarrollo-software.xyz/api";

  Future<String?> _getToken() async {
    return await _storage.read(key: "token");
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("authToken", token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("authToken");
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("authToken");
  }

  Future<List<dynamic>> getProductos({String? categoria, String? orden}) async {
    final token = await _getToken();
    final headers = {"Content-Type": "application/json"};

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Token $token";
    }

    // 1. Construimos los parámetros de consulta (Query Parameters)
    Map<String, String> queryParameters = {};

    if (categoria != null && categoria != "Todas las categorías") {
      queryParameters["categoria"] = categoria;
    }

    if (orden != null && orden != "") {
      queryParameters["orden"] = orden;
    }

    // 2. Creamos la URI final inyectando los parámetros
    // Esto convierte "baseUrl/productos/" en "baseUrl/productos/?categoria=Calzado&orden=Precio..."
    final uri = Uri.parse(
      "$baseUrl/productos/",
    ).replace(queryParameters: queryParameters);

    final response = await http.get(
      uri, // Usamos la nueva URI con filtros
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(
        utf8.decode(response.bodyBytes),
      ); // utf8 por si hay acentos
      return data["results"];
    } else if (response.statusCode == 401) {
      await _storage.delete(key: "token");
      throw Exception("Sesión expirada, vuelve a iniciar sesión");
    } else {
      throw Exception("Error al obtener productos: ${response.body}");
    }
  }

  Future<void> crearProducto(Map<String, dynamic> data, File? imagen) async {
    final token = await _getToken();
    final url = Uri.parse("$baseUrl/productos/");

    var request = http.MultipartRequest("POST", url);

    request.headers["Authorization"] = "Token $token";

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (imagen != null) {
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception("Error al crear producto: ${response.body}");
    }
  }

  Future<void> editarProducto(
    int id,
    Map<String, dynamic> data,
    File? imagen,
  ) async {
    final token = await _getToken();
    final url = Uri.parse("$baseUrl/productos/$id/");

    var request = http.MultipartRequest("PATCH", url);
    request.headers["Authorization"] = "Token $token";

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    if (imagen != null) {
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception("Error al editar producto: ${response.body}");
    }
  }

  Future<void> eliminarProducto(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/productos/$id/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode != 204) {
      throw Exception("Error al eliminar producto");
    }
  }

  // ------------------ CLIENTES ------------------
  Future<List<dynamic>> getClientes() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/clientes/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["results"];
    } else if (response.statusCode == 401) {
      await _storage.delete(key: "token");
      throw Exception("Sesión expirada, vuelve a iniciar sesión");
    } else {
      throw Exception("Error al obtener clientes: ${response.body}");
    }
  }

  Future<void> createCliente(Map<String, dynamic> cliente) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/clientes/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(cliente),
    );
    if (response.statusCode != 201) {
      throw Exception("Error al crear cliente: ${response.body}");
    }
  }

  Future<void> updateCliente(int id, Map<String, dynamic> cliente) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/clientes/$id/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(cliente),
    );
    if (response.statusCode != 200) {
      throw Exception("Error al actualizar cliente: ${response.body}");
    }
  }

  Future<void> deleteCliente(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/clientes/$id/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode != 204) {
      throw Exception("Error al eliminar cliente: ${response.body}");
    }
  }

  // ------------------ PEDIDOS ------------------
  Future<List<dynamic>> getPedidos() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/pedidos/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["results"];
    } else if (response.statusCode == 401) {
      await _storage.delete(key: "token");
      throw Exception("Sesión expirada, vuelve a iniciar sesión");
    } else {
      throw Exception("Error al obtener pedidos: ${response.body}");
    }
  }

  Future<void> createPedido(Map<String, dynamic> pedido) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/pedidos/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(pedido),
    );
    if (response.statusCode != 201) {
      throw Exception("Error al crear pedido: ${response.body}");
    }
  }

  Future<void> updatePedido(int id, Map<String, dynamic> pedido) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/pedidos/$id/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(pedido),
    );
    if (response.statusCode != 200) {
      throw Exception("Error al actualizar pedido: ${response.body}");
    }
  }

  Future<void> deletePedido(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/pedidos/$id/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode != 204) {
      throw Exception("Error al eliminar pedido: ${response.body}");
    }
  }

  Future<List<dynamic>> getCategorias() async {
    final response = await http.get(
      Uri.parse("$baseUrl/categorias/"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["results"]; // si usas paginación DRF
    } else {
      throw Exception("Error al obtener categorias: ${response.body}");
    }
  }

  Future<void> createCategoria(Map<String, dynamic> categoria) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/categorias/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(categoria),
    );
    if (response.statusCode != 201) {
      throw Exception("Error al crear categoría: ${response.body}");
    }
  }

  Future<void> updateCategoria(int id, Map<String, dynamic> categoria) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/categorias/$id/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(categoria),
    );
    if (response.statusCode != 200) {
      throw Exception("Error al actualizar categoría: ${response.body}");
    }
  }

  Future<void> deleteCategoria(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/categorias/$id/"),
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 204) {
      throw Exception("Error al eliminar categoría: ${response.body}");
    }
  }
}
