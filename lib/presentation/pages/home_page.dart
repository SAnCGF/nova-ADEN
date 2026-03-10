import 'package:flutter/material.dart';
import 'package:nova_aden/core/constants/app_constants.dart';
import './product_list_page.dart';
import './pos_page.dart';
import './purchase_page.dart';
import './sales_list_page.dart';
import './reports_page.dart';
import './settings_page.dart';
import './supplier_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.2, children: [
            _btn('Productos', Icons.inventory_2, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListPage()))),
            _btn('Punto de Venta', Icons.shopping_cart, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const POSPage()))),
            _btn('Compras', Icons.shopping_bag, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasePage()))),
            _btn('Ventas', Icons.receipt_long, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesListPage()))),
            _btn('Proveedores', Icons.business, Colors.brown, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierPage()))),
            _btn('Reportes', Icons.dashboard, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage()))),
          ]),
        ]),
      ),
    );
  }
  Widget _btn(String t, IconData i, Color c, VoidCallback f) {
    return InkWell(onTap: f, child: Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 48, color: c), const SizedBox(height: 8), Text(t)])));
  }
}
