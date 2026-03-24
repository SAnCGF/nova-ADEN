import 'package:flutter/material.dart';

class SalesListPage extends StatelessWidget {
  const SalesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas'), centerTitle: true),
      body: const Center(child: Text('Historial de Ventas\n\nListado, Filtros por Fecha/Cliente')),
    );
  }
}
