import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://paredes-inventario-api.desarrollo-software.xyz/api/",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        // contentType: 'application/json',
      ),
    );

    // --- INTERCEPTOR DE PETICIONES (Equivalente a api.interceptors.request.use) ---
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Buscamos el token en SharedPreferences (localStorage de Flutter)
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');

          if (token != null) {
            // Replicamos exactamente tu encabezado de Axios
            options.headers["Authorization"] = "Token $token";
          }
          options.headers["Accept"] = "application/json";

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Opcional: Si el servidor responde 401, podrías redirigir al Login aquí
          return handler.next(e);
        },
      ),
    );
  }

  // Métodos de ayuda para que sea más fácil de usar
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  // El POST necesita data para el body
  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  // El PUT necesita data
  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  // El PATCH (Muy usado en tus APIs de Django)
  Future<Response> patch(String path, {dynamic data}) {
    return dio.patch(path, data: data);
  }

  // El DELETE no suele llevar body ni params
  Future<Response> delete(String path) {
    return dio.delete(path);
  }
}

// Instancia global para usar en toda la app
final api = ApiService();
