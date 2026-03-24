import 'package:flutter/material.dart';

class SupplierPage extends StatelessWidget {
  const SupplierPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores'), centerTitle: true),
      body: const Center(child: Text('Módulo de Proveedores - RF 7\n\nRegistrar, Editar, Eliminar')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🏢 Nuevo Proveedor'))),
        child: const Icon(Icons.add),
      ),
    );
  }
}
