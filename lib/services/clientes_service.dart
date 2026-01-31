import '../models/cliente.dart';
import 'api_service.dart'; // Tu cliente Dio configurado

class ClientesService {
  
  // getClientes
  static Future<List<Cliente>> getClientes() async {
    final response = await api.get("clientes/");
    
    // Manejamos la paginación de Django (results) o lista directa
    final List<dynamic> data = response.data is Map 
        ? response.data['results'] 
        : response.data;
        
    return data.map((json) => Cliente.fromJson(json)).toList();
  }

  // saveCliente
  static Future<dynamic> saveCliente(int? id, Map<String, dynamic> data) async {
    if (id != null) {
      // ACTUALIZACIÓN (PATCH) - clientes/{id}/
      final response = await api.put(
        "clientes/$id/", 
        data: {
          'nombre': data['nombre'],
          'email': data['email'],
          'telefono': data['telefono'],
        }
      );
      return response.data;
    } else {
      // REGISTRO NUEVO (POST) - auth/registro_cliente/
      // Replicamos exactamente tu "payload" de React
      final payload = {
        'username': data['email'], 
        'email': data['email'],
        'password': data['password'],
        'nombre': data['nombre'],
        'first_name': data['nombre'],
        'telefono': data['telefono'],
      };
      
      final response = await api.post("auth/registro_cliente/", data: payload);
      return response.data;
    }
  }

  // deleteCliente
  static Future<void> deleteCliente(int id) async {
    await api.delete("clientes/$id/");
  }
}