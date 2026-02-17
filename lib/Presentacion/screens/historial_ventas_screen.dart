import 'package:flutter/material.dart';
import 'package:nova_aden/Dominio/entities/venta.dart';
import 'package:nova_aden/Nucleo/di/injection.dart';

class HistorialVentasScreen extends StatefulWidget {
  const HistorialVentasScreen({super.key});

  @override
  State<HistorialVentasScreen> createState() => _HistorialVentasScreenState();
}

class _HistorialVentasScreenState extends State<HistorialVentasScreen> {
  late final ventaRepo = sl<VentaRepository>();
  List<Venta> _ventas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarVentasDelDia();
  }

  Future<void> _cargarVentasDelDia() async {
    setState(() => _cargando = true);
    try {
      _ventas = await ventaRepo.obtenerVentasDelDia();
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _filtrarPorFechas() async {
    DateTime? inicio = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (inicio == null) return;

    DateTime? fin = await showDatePicker(
      context: context,
      initialDate: inicio,
      firstDate: inicio,
      lastDate: DateTime.now(),
    );

    if (fin == null) return;

    setState(() => _cargando = true);
    try {
      _ventas = await ventaRepo.obtenerVentasPorFechas(inicio, fin);
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _verDetalle(Venta venta) async {
    final ventaConDetalles = await ventaRepo.obtenerVentaConDetalles(venta.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleVentaScreen(ventaConDetalles: ventaConDetalles),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _filtrarPorFechas,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _ventas.isEmpty
              ? const Center(child: Text('No hay ventas registradas'))
              : ListView.builder(
                  itemCount: _ventas.length,
                  itemBuilder: (context, index) {
                    final v = _ventas[index];
                    return ListTile(
                      title: Text('Venta #${v.id}'),
                      subtitle: Text(
                        '${v.fecha.day}/${v.fecha.month}/${v.fecha.year} ${v.fecha.hour}:${v.fecha.minute.toString().padLeft(2, '0')}'
                      ),
                      trailing: Text('${v.total.toStringAsFixed(2)} CUP'),
                      onTap: () => _verDetalle(v),
                    );
                  },
                ),
    );
  }
}

class DetalleVentaScreen extends StatelessWidget {
  final VentaConDetalles ventaConDetalles;

  const DetalleVentaScreen({super.key, required this.ventaConDetalles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Venta #${ventaConDetalles.venta.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${ventaConDetalles.venta.fecha}'),
            const SizedBox(height: 16),
            const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: ventaConDetalles.detalles.length,
                itemBuilder: (context, index) {
                  final d = ventaConDetalles.detalles[index];
                  return ListTile(
                    title: Text(d.producto.nombre),
                    subtitle: Text('Cantidad: ${d.cantidad}'),
                    trailing: Text('${d.subtotal.toStringAsFixed(2)} CUP'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Total: ${ventaConDetalles.venta.total.toStringAsFixed(2)} CUP',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}