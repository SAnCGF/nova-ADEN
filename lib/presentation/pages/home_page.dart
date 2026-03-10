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
            InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListPage())), child: Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.inventory_2, size: 48, color: Colors.blue), const SizedBox(height: 8), const Text('Productos')]))),
            InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const POSPage())), child: Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.shopping_cart, size: 48, color: Colors.green), const SizedBox(height: 8), const Text('Punto de Venta')]))),
            InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasePage())), child: Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.shopping_bag, size: 48, color: Colors.orange), const SizedBox(height: 8), const Text('Compras')]))),
            InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesListPage())), child: Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.receipt_long, size: 48, color: Colors.teal), const SizedBox(height: 8), const Text('Ventas')]))),
            InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierPage())), child: Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.business, size: 48, color: Colors.brown), const SizedBox(height: 8), const Text('Proveedores')]))),
            InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsPage())), child: Card(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.dashboard, size: 48, color: Colors.purple), const SizedBox(height: 8), const Text('Reportes')]))),
          ]),
        ]),
      ),
    );
  }
}
