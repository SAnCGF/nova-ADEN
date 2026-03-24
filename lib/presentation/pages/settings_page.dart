import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(title: Text('Apariencia'), subtitle: Text('Tema claro/oscuro')),
          const Divider(),
          const ListTile(title: Text('Información'), subtitle: Text('Versión 1.0.0')),
          const Divider(),
          ListTile(
            title: const Text('Cerrar Sesión'),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
