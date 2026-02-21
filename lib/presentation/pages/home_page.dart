import 'package:flutter/material.dart';
import 'package:nova_aden/core/constants/app_constants.dart';
import 'package:nova_aden/presentation/widgets/dashboard_card.dart';
import 'package:nova_aden/presentation/widgets/module_button.dart';
import 'package:nova_aden/presentation/pages/product_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _totalProductos = 0;
  final int _ventasHoy = 0;
  final int _alertasStock = 0;
  final double _ingresosDia = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showComingSoon('Configuración'),
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
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
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¡Bienvenido!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(AppConstants.appDescription, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDashboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen del Día', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
          children: [
            DashboardCard(title: 'Productos', value: '$_totalProductos', icon: Icons.inventory_2_outlined, color: Colors.blue),
            DashboardCard(title: 'Ventas Hoy', value: '$_ventasHoy', icon: Icons.point_of_sale_outlined, color: Colors.green),
            DashboardCard(title: 'Alertas Stock', value: '$_alertasStock', icon: Icons.warning_amber_outlined, color: Colors.orange),
            DashboardCard(title: 'Ingresos', value: '\$${_ingresosDia.toStringAsFixed(2)}', icon: Icons.attach_money, color: Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildModulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Módulos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1,
          children: [
            ModuleButton(
              title: 'Inventario',
              icon: Icons.inventory_2,
              color: Colors.blue,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProductListPage()),
              ),
            ),
            ModuleButton(title: 'Ventas', icon: Icons.point_of_sale, color: Colors.green, onPressed: () => _showComingSoon('Ventas')),
            ModuleButton(title: 'Compras', icon: Icons.shopping_cart, color: Colors.orange, onPressed: () => _showComingSoon('Compras')),
            ModuleButton(title: 'Mermas', icon: Icons.warning_amber, color: Colors.red, onPressed: () => _showComingSoon('Mermas')),
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
          const SizedBox(height: 8),
          Text('nova-ADEN v${AppConstants.appVersion}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          Text(AppConstants.appLicense, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showComingSoon(String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Módulo $moduleName en desarrollo'), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating),
    );
  }
}
