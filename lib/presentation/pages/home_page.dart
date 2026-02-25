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
    // Cargar datos reales cuando estén disponibles
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductoBloc>().cargarProductos();
              _cargarDatos();
            },
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ProductoBloc>().cargarProductos();
          _cargarDatos();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              _buildDashboardSection(),
              const SizedBox(height: 24),
              _buildModulesSection(),
              const SizedBox(height: 24),
              _buildFooter(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const POSPage()),
          );
        },
        icon: const Icon(Icons.point_of_sale),
        label: const Text('Nueva Venta'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Bienvenido!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.appDescription,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del Día',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            DashboardCard(
              title: 'Productos',
              value: '$_totalProductos',
              icon: Icons.inventory_2_outlined,
              color: Colors.blue,
            ),
            DashboardCard(
              title: 'Ventas Hoy',
              value: '$_ventasHoy',
              icon: Icons.point_of_sale_outlined,
              color: Colors.green,
            ),
            DashboardCard(
              title: 'Alertas Stock',
              value: '$_alertasStock',
              icon: Icons.warning_amber_outlined,
              color: Colors.orange,
            ),
            DashboardCard(
              title: 'Ingresos',
              value: '\$${_ingresosDia.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Módulos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            // Módulo Punto de Venta (NUEVO)
            ModuleButton(
              title: 'Punto de Venta',
              icon: Icons.point_of_sale,
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const POSPage()),
                );
              },
            ),
            
            // Módulo Inventario
            ModuleButton(
              title: 'Inventario',
              icon: Icons.inventory_2,
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductListPage()),
                );
              },
            ),
            
            // Módulo Compras
            ModuleButton(
              title: 'Compras',
              icon: Icons.shopping_cart,
              color: Colors.orange,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PurchasePage()),
                );
              },
            ),
            
            // Módulo Ventas (Historial)
            ModuleButton(
              title: 'Historial Ventas',
              icon: Icons.receipt_long,
              color: Colors.teal,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalesListPage()),
                );
              },
            ),
            
            // Módulo Reportes
            ModuleButton(
              title: 'Reportes',
              icon: Icons.bar_chart,
              color: Colors.purple,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsPage()),
                );
              },
            ),
            
            // Módulo Configuración
            ModuleButton(
              title: 'Configuración',
              icon: Icons.settings,
              color: Colors.grey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          const Divider(),
          Text(
            AppConstants.appVersion,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showComingSoon(String modulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$modulo próximamente'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
