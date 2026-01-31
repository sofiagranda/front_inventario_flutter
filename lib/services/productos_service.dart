import 'package:dio/dio.dart';
import 'package:inventario_app/models/pagination.dart';
import '../models/producto.dart';
import '../models/categoria.dart';
import 'api_service.dart';

class ProductosService {
  static Future<PaginatedResponse<Producto>> getProductos({
    int page = 1,
    String search = "",
    String categoria = "",
  }) async {
    // Creamos el mapa de parámetros dinámicamente
    final Map<String, dynamic> params = {'page': page, 'search': search};

    // SOLO agregamos la categoría si tiene un valor real (no vacía)
    if (categoria.isNotEmpty) {
      params['categoria'] = categoria;
    }

    final response = await api.get("productos/", queryParameters: params);

    final List<dynamic> resultsJson = response.data['results'];
    return PaginatedResponse<Producto>(
      count: response.data['count'],
      next: response.data['next'],
      previous: response.data['previous'],
      results: resultsJson.map((json) => Producto.fromJson(json)).toList(),
    );
  }

  static Future<Producto> saveProducto(
    int? id,
    Map<String, dynamic> data,
    String? imagePath,
  ) async {
    try {
      // 1. Verificar datos de entrada

      FormData formData = FormData.fromMap({
        "nombre": data['nombre'],
        "precio": data['precio'],
        "stock": data['stock'],
        "cantidad_minima": data['cantidad_minima'],
        "unidad": data['unidad'],
        "categoria": data['categoria'],
      });

      // 2. Verificar procesamiento de imagen
      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            "imagen",
            await MultipartFile.fromFile(imagePath, filename: "producto.jpg"),
          ),
        );
      }

      Response response;

      // 3. El momento crítico: La petición
      if (id != null) {
        response = await api.patch("productos/$id/", data: formData);
      } else {
        response = await api.post("productos/", data: formData);
      }

      return Producto.fromJson(response.data);
    } on DioException catch (e) {
      print("🔑 Header enviado: ${e.requestOptions.headers['Authorization']}");
      rethrow;
    } catch (e) {
      print("🚨 [ERROR GENÉRICO]: $e");
      rethrow;
    }
  }

  static Future<void> deleteProducto(int id) async {
    // El interceptor pondrá el token automáticamente
    await api.delete("productos/$id/");
  }
}
