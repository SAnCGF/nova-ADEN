import 'package:flutter/foundation.dart';
import 'package:nova_aden/core/repositories/sale_repository.dart';

class VentaBloc extends ChangeNotifier {
  final SaleRepository repository;
  List<Map<String, dynamic>> _ventas = [];
  List<Map<String, dynamic>> get ventas => _ventas;

  VentaBloc({required this.repository});

  Future<void> cargarVentas() async {
    try {
      _ventas = await repository.getAllSales();
      notifyListeners();
    } catch (e) {
      _ventas = [];
      notifyListeners();
    }
  }

  Future<void> cargarVentasPorRango(DateTime start, DateTime end) async {
    try {
      _ventas = await repository.getSalesByDateRange(start, end);
      notifyListeners();
    } catch (e) {
      _ventas = [];
      notifyListeners();
    }
  }

  Future<bool> registrarVenta(Map<String, dynamic> sale, List<Map<String, dynamic>> items, bool allowNegative) async {
    try {
      await repository.registerSale(sale, items, allowNegative);
      await cargarVentas();
      return true;
    } catch (e) {
      return false;
    }
  }
}
