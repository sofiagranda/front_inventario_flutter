import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PedidoFormScreen extends StatefulWidget {
  final Map<String, dynamic>? pedido;

  const PedidoFormScreen({super.key, this.pedido});

  @override
  State<PedidoFormScreen> createState() => _PedidoFormScreenState();
}

class _PedidoFormScreenState extends State<PedidoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final api = ApiService();

  late TextEditingController _descripcionController;
  late TextEditingController _clienteController;

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController(text: widget.pedido?["descripcion"] ?? "");
    _clienteController = TextEditingController(text: widget.pedido?["cliente"]?.toString() ?? "");
  }

  Future<void> _savePedido() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "descripcion": _descripcionController.text,
        "cliente": int.parse(_clienteController.text), // ID del cliente
      };

      if (widget.pedido == null) {
        await api.createPedido(data);
      } else {
        await api.updatePedido(widget.pedido!["id"], data);
      }

      Navigator.pop(context, true);
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pedido == null ? "Nuevo Pedido" : "Editar Pedido")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: "Descripción"),
                validator: (value) => value!.isEmpty ? "Ingrese una descripción" : null,
              ),
              TextFormField(
                controller: _clienteController,
                decoration: const InputDecoration(labelText: "ID Cliente"),
                validator: (value) => value!.isEmpty ? "Ingrese el ID del cliente" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePedido,
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}