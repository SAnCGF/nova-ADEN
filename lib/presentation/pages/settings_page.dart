import 'package:flutter/material.dart';
import 'package:nova_aden/presentation/pages/feedback_page.dart';
import 'package:nova_aden/presentation/pages/help_page.dart';
import 'package:nova_aden/core/constants/app_constants.dart';
import 'package:nova_aden/presentation/pages/feedback_page.dart';
import 'package:nova_aden/presentation/pages/help_page.dart';
import 'package:provider/provider.dart';
import 'package:nova_aden/presentation/pages/feedback_page.dart';
import 'package:nova_aden/presentation/pages/help_page.dart';
import '../bloc/auth_bloc.dart';
import 'package:nova_aden/presentation/pages/feedback_page.dart';
import 'package:nova_aden/presentation/pages/help_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _currentTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _currentTheme = ThemeMode.system;
  }

  void _changeTheme(ThemeMode theme) {
    setState(() {
      _currentTheme = theme;
    });
    // Actualizar el tema en toda la app
    (context as Element).rebuild();
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
                        child: Text('Sistema'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Claro'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Oscuro'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _changeTheme(value);
                        _showSnackBar('✅ Tema actualizado', Colors.green);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Sección: Información de la App
          _buildSectionTitle('Información'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Versión'),
                  trailing: Text(AppConstants.appVersion),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Aplicación'),
                  trailing: Text(AppConstants.appName),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Sección: Licencia
          _buildSectionTitle('Licencia'),
          Card(
            child: Column(
              children: [
                Consumer<AuthBloc>(
                  builder: (context, authBloc, child) {
                    return ListTile(
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
                                // Navegar a activación de licencia
                              },
                              child: const Text('Activar'),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Sección: Datos
          _buildSectionTitle('Datos'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Respaldar datos'),
                  subtitle: const Text('Exportar base de datos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSnackBar('⚠️ Función en desarrollo', Colors.orange);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restaurar datos'),
                  subtitle: const Text('Importar base de datos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSnackBar('⚠️ Función en desarrollo', Colors.orange);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Sección: Acerca de
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Enviar Feedback'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FeedbackPage()),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ayuda'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpPage()),
              ),
            ),
          _buildSectionTitle('Acerca de'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Desarrollado por'),
                  subtitle: const Text('Nova ADEN Team'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Contacto'),
                  subtitle: const Text('soporte@nova-aden.com'),
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
                          _showSnackBar('👋 Sesión cerrada', Colors.blue);
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

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
