import 'package:flutter/material.dart';
import 'package:nova_aden/core/constants/app_constants.dart';
import 'package:nova_aden/presentation/widgets/dashboard_card.dart';
import 'package:nova_aden/presentation/widgets/module_button.dart';
import 'package:nova_aden/presentation/pages/product_list_page.dart';
import 'package:nova_aden/presentation/pages/pos_page.dart';
import 'package:nova_aden/presentation/pages/purchase_page.dart';
import 'package:nova_aden/presentation/pages/reports_page.dart';
import 'package:nova_aden/presentation/pages/sales_list_page.dart';
import 'package:nova_aden/presentation/pages/settings_page.dart';
import 'package:provider/provider.dart';
import '../bloc/producto_bloc.dart';
import '../bloc/venta_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _totalProductos = 0;
  int _ventasHoy = 0;
  int _alertasStock = 0;
  double _ingresosDia = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      _totalProductos = context.read<ProductoBloc>().productos.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          // ✅ Botón de configuración SOLO en AppBar
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard de métricas
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Productos',
                    value: '$_totalProductos',
                    icon: Icons.inventory_2,
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardCard(
                    title: 'Ventas Hoy',
                    value: '$_ventasHoy',
                    icon: Icons.shopping_cart,
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Alertas Stock',
                    value: '$_alertasStock',
                    icon: Icons.warning_amber,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardCard(
                    title: 'Ingresos',
                    value: '\$$_ingresosDia',
                    icon: Icons.attach_money,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Módulo de botones - ✅ SIN botón de configuración aquí
            const Text(
              'Módulos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                ModuleButton(
                  title: 'Productos',
                  icon: Icons.inventory_2,
                  color: const Color(0xFF1E3A5F),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProductListPage()),
                  ),
                ),
                ModuleButton(
                  title: 'Punto de Venta',
                  icon: Icons.point_of_sale,
                  color: const Color(0xFF22C55E),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const POSPage()),
                  ),
                ),
                ModuleButton(
                  title: 'Compras',
                  icon: Icons.shopping_bag,
                  color: const Color(0xFF8B5CF6),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PurchasePage()),
                  ),
                ),
                ModuleButton(
                  title: 'Ventas',
                  icon: Icons.receipt_long,
                  color: const Color(0xFF3B82F6),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SalesListPage()),
                  ),
                ),
                ModuleButton(
                  title: 'Reportes',
                  icon: Icons.bar_chart,
                  color: const Color(0xFFF59E0B),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReportsPage()),
                  ),
                ),
                // ✅ Configuración REMOVIDA de aquí - solo está en AppBar
              ],
            ),
          ],
        ),
      ),
    );
  }
}
