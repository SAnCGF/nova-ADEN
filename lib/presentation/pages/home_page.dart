import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import './product_list_page.dart';
import './pos_page.dart';
import './purchase_page.dart';
import './sales_list_page.dart';
import './reports_page.dart';
import './settings_page.dart';
import './supplier_page.dart';
import './customer_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nova ADEN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _btn(context, 'Productos', Icons.inventory_2, Colors.blue, const ProductListPage()),
                _btn(context, 'Punto de Venta', Icons.shopping_cart, Colors.green, const PosPage()),
                _btn(context, 'Compras', Icons.shopping_bag, Colors.orange, const PurchasePage()),
                _btn(context, 'Ventas', Icons.receipt_long, Colors.teal, const SalesListPage()),
                _btn(context, 'Proveedores', Icons.business, Colors.brown, const SupplierPage()),
                _btn(context, 'Clientes', Icons.people, Colors.pink, const CustomerPage()),
                _btn(context, 'Reportes', Icons.dashboard, Colors.purple, const ReportsPage()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext ctx, String t, IconData i, Color c, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, size: 48, color: c),
            const SizedBox(height: 8),
            Text(t, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
