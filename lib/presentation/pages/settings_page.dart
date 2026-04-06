import 'help_feedback_page.dart';
import 'notes_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_settings_page.dart';
import 'backup_page.dart';
import 'notes_page.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool)? onToggleTheme;
  final bool isDark;
  const SettingsPage({super.key, this.onToggleTheme, required this.isDark});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _autoBackup = true;
  double _taxRate = 0.0;
  String _reportHeader = '';
  int _lockDays = 30;
  bool _stockReminders = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _taxRate = prefs.getDouble('tax_rate') ?? 0.0;
      _reportHeader = prefs.getString('report_header') ?? '';
      _lockDays = prefs.getInt('lock_days') ?? 30;
      _stockReminders = prefs.getBool('stock_reminders') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tax_rate', _taxRate);
    await prefs.setString('report_header', _reportHeader);
    await prefs.setInt('lock_days', _lockDays);
    await prefs.setBool('stock_reminders', _stockReminders);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Guardado'), backgroundColor: Colors.green),
      );
    }
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
          _buildSectionTitle('Apariencia'),
          SwitchListTile(
            secondary: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
            title: const Text('Modo Oscuro', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Cambiar tema de la aplicación'),
            value: widget.isDark,
            onChanged: (value) {
              if (widget.onToggleTheme != null) {
                widget.onToggleTheme!(value);
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('General'),
          _buildSettingsTile(
            icon: Icons.currency_exchange,
            title: 'Monedas y Tasas',
            subtitle: 'Configurar CUP, MLC, USD',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencySettingsPage())),
          ),
          _buildSettingsTile(
            icon: Icons.backup,
            title: 'Respaldos',
            subtitle: 'Crear o restaurar copias',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupPage())),
          ),
          _buildSettingsTile(
            icon: Icons.note,
            title: 'Notas Diarias',
            subtitle: 'RF 70: Registrar notas del día',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesPage())),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Reportes y Operaciones'),
          // RF 66: Cabecera personalizada
          TextField(
            decoration: InputDecoration(
              labelText: 'Cabecera de Reportes',
              hintText: 'Ej: Mi Negocio S.A.',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            controller: TextEditingController(text: _reportHeader),
            onChanged: (v) => _reportHeader = v,
          ),
          const SizedBox(height: 12),
          // RF 65: Impuestos
          Row(
            children: [
              const Text('Impuesto %: '),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  controller: TextEditingController(text: _taxRate.toString()),
                  onChanged: (v) => _taxRate = double.tryParse(v) ?? 0.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // RF 69: Bloquear edición antigua
          Row(
            children: [
              const Text('Bloquear operaciones > '),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  controller: TextEditingController(text: _lockDays.toString()),
                  onChanged: (v) => _lockDays = int.tryParse(v) ?? 30,
                ),
              ),
              const Text(' días'),
            ],
          ),
          const SizedBox(height: 12),
          // RF 68: Recordatorios de stock
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active, color: Colors.orange),
            title: const Text('Recordatorios de Stock', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Alertas periódicas de stock bajo'),
            value: _stockReminders,
            onChanged: (v) => setState(() => _stockReminders = v),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Sistema'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.green),
            title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Alertas de stock bajo'),
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.backup_table, color: Colors.blue),
            title: const Text('Respaldo Automático', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Diario a las 23:59'),
            value: _autoBackup,
            onChanged: (v) => setState(() => _autoBackup = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('GUARDAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Información'),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'Acerca de',
            subtitle: 'Versión 1.0.0',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFeedbackPage())),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova ADEN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Versión: 1.0.0'),
            const SizedBox(height: 8),
            const Text('Administrador de Negocio'),
            const SizedBox(height: 8),
            const Text('Desarrollado con Flutter & Dart'),
            const SizedBox(height: 16),
            const Text('© 2026 Todos los derechos reservados.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}
