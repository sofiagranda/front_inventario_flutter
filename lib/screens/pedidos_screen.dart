import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'pedido_form_screen.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final api = ApiService();
  List<dynamic> _pedidos = [];

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    final pedidos = await api.getPedidos();
    setState(() => _pedidos = pedidos);
  }

  Future<void> _openForm([Map<String, dynamic>? pedido]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PedidoFormScreen(pedido: pedido),
      ),
    );

    if (result == true) {
      _loadPedidos(); // recarga la lista si se guardó algo
    }
  }

  Future<void> _deletePedido(int id) async {
    await api.deletePedido(id);
    _loadPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pedidos")),
      body: ListView.builder(
        itemCount: _pedidos.length,
        itemBuilder: (context, index) {
          final pedido = _pedidos[index];
          return ListTile(
            title: Text("Pedido #${pedido["id"]}"),
            subtitle: Text("Cliente: ${pedido["cliente"]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openForm(pedido),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePedido(pedido["id"]),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

