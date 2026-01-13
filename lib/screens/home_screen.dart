import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _productos = [];

  @override
  void initState() {
    super.initState();
    _getProductos();
  }

  Future<void> _getProductos() async {
  final token = await _storage.read(key: "token");

  final response = await http.get(
    Uri.parse("https://paredes-inventario-api.desarrollo-software.xyz/api/productos/"),
    headers: {"Authorization": "Token $token"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      _productos = data["results"];
    });
  } else {
    print("Error: ${response.statusCode} - ${response.body}");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Productos")),
      body: ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          return ListTile(
            title: Text(producto["nombre"]),
            subtitle: Text("Stock: ${producto["stock"]}"),
          );
        },
      ),
    );
  }
}
