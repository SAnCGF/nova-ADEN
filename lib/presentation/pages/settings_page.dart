import 'package:flutter/material.dart';
import 'package:nova_aden/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import '../bloc/auth_bloc.dart';
import 'feedback_page.dart';
import 'help_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _currentTheme = ThemeMode.system;
  
  // Configuración de moneda
  String _selectedCurrency = 'CUP';
  
  // Configuración de impuesto
  double _taxRate = 0.0;

  @override
  void initState() {
    super.initState();
    _currentTheme = ThemeMode.system;
  }

  void _changeTheme(ThemeMode theme) {
    setState(() {
      _currentTheme = theme;
    });
    _showSnackBar('✅ Tema cambiado a ${theme.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección: Apariencia
          _buildSectionTitle('Apariencia'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_auto),
                  title: const Text('Tema del sistema'),
                  subtitle: const Text('Usar tema claro u oscuro'),
                  trailing: DropdownButton<ThemeMode>(
                    value: _currentTheme,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: const Text('Sistema'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: const Text('Claro'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: const Text('Oscuro'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _changeTheme(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Sección: Moneda
          _buildSectionTitle('Moneda'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text('Moneda Principal'),
                  subtitle: const Text('Selecciona la moneda de operación'),
                  trailing: DropdownButton<String>(
                    value: _selectedCurrency,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'CUP', child: Text('Peso Cubano')),
                      DropdownMenuItem(value: 'USD', child: Text('Dólar Estadounidense')),
                      DropdownMenuItem(value: 'EUR', child: Text('Euro')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCurrency = value);
                        _showSnackBar('✅ Moneda cambiada a $value');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Sección: Impuestos
          _buildSectionTitle('Impuestos'),
          Card(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Tasa de Impuesto (%)',
                    prefixIcon: Icon(Icons.tune),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final rate = double.tryParse(value) ?? 0.0;
                    setState(() => _taxRate = rate);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Márgenes de ganancia sugeridos se calculan con este impuesto.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSectionTitle('Licencia'),
          Card(
            child: Consumer<AuthBloc>(
              builder: (context, authBloc, child) {
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        authBloc.isLicenseActive 
                          ? Icons.check_circle 
                          : Icons.error,
                        color: authBloc.isLicenseActive ? Colors.green : Colors.red,
                      ),
                      title: const Text('Estado de licencia'),
                      subtitle: Text(
                        authBloc.isLicenseActive 
                          ? 'Licencia activa' 
                          : 'Licencia inactiva',
                      ),
                      trailing: authBloc.isLicenseActive
                          ? null
                          : ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Activar'),
                            ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Versión'),
                      trailing: Text(AppConstants.appVersion),
                    ),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('Aplicación'),
                      trailing: Text(AppConstants.appName),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Sección: Ayuda y Soporte
          _buildSectionTitle('Ayuda y Soporte'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.feedback),
                  title: const Text('Enviar Feedback'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FeedbackPage()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Ayuda'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HelpPage()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Respaldar Datos'),
                  subtitle: const Text('Exportar base de datos actual'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSnackBar('⚠️ Funcionalidad en desarrollo');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Botón de cerrar sesión
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cerrar Sesión'),
                    content: const Text('¿Está seguro de que desea cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.read<AuthBloc>().deactivateLicense();
                          Navigator.of(context).pop();
                          _showSnackBar('👋 Sesión cerrada');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('CERRAR SESIÓN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showSnackBar(String message, [Color color = Colors.blue]) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }
}
