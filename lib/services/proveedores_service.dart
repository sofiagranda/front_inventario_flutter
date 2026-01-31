import '../models/proveedor.dart';
import '../models/pagination.dart'; // Asegúrate de tener aquí el modelo de PaginatedResponse
import 'api_service.dart';

class ProveedoresService {
  
  // getProveedores
  static Future<PaginatedResponse<Proveedor>> getProveedores() async {
    final response = await api.get("proveedores/");
    
    final List<dynamic> resultsJson = response.data['results'];
    
    return PaginatedResponse<Proveedor>(
      count: response.data['count'],
      next: response.data['next'],
      previous: response.data['previous'],
      results: resultsJson.map((json) => Proveedor.fromJson(json)).toList(),
    );
  }

  // saveProveedor (id: number | null, data: Omit<Proveedor, 'id'>)
  static Future<Proveedor> saveProveedor(int? id, Map<String, dynamic> data) async {
    if (id != null) {
      // Si hay ID, usamos PATCH
      final response = await api.dio.patch("proveedores/$id/", data: data);
      return Proveedor.fromJson(response.data);
    } else {
      // Si no hay ID, usamos POST
      final response = await api.dio.post("proveedores/", data: data);
      return Proveedor.fromJson(response.data);
    }
  }

  // deleteProveedor
  static Future<void> deleteProveedor(int id) async {
    await api.delete("proveedores/$id/");
  }
}