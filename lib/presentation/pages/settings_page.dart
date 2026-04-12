import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../core/utils/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _companyName = 'Nova ADEN';
  double _taxRate = 0.0;
  bool _stockReminderEnabled = false;
  int _stockReminderDays = 7;
  bool _notificationsEnabled = true;

  final _companyCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _companyName = prefs.getString('company_name') ?? 'Nova ADEN';
      _companyCtrl.text = _companyName;
      
      _taxRate = prefs.getDouble('tax_rate') ?? 0.0;
      _taxCtrl.text = _taxRate.toStringAsFixed(1);
      
      _stockReminderEnabled = prefs.getBool('stock_reminder_enabled') ?? false;
      _stockReminderDays = prefs.getInt('stock_reminder_days') ?? 7;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) await prefs.setString(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is bool) await prefs.setBool(key, value);
    if (value is int) await prefs.setInt(key, value);
    setState(() {});
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tema
          Card(child: SwitchListTile(
            secondary: Icon(Provider.of<ThemeProvider>(context).isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.blue),
            title: Text(Provider.of<ThemeProvider>(context).isDarkMode ? 'Modo Claro' : 'Modo Oscuro'),
            subtitle: const Text('Cambia el tema de la aplicación'),
            value: Provider.of<ThemeProvider>(context).isDarkMode,
            onChanged: (v) => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          )),
          const SizedBox(height: 24),
          
          // GENERAL
          const Text('General', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Card(child: ListTile(
            leading: const Icon(Icons.business, color: Colors.blue),
            title: const Text('Nombre de empresa'),
            subtitle: Text(_companyName),
            onTap: () => _editField('company_name', _companyCtrl),
          )),
          const SizedBox(height: 16),
          
          // REPORTES
          const Text('Reportes y Operaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Card(child: ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.green),
            title: const Text('Impuesto predeterminado'),
            subtitle: Text('${_taxRate.toStringAsFixed(1)}%'),
            onTap: () => _editField('tax_rate', _taxCtrl),
          )),
          const SizedBox(height: 16),
          
          // INVENTARIO
          const Text('Inventario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Card(child: SwitchListTile(
            secondary: const Icon(Icons.inventory_2, color: Colors.purple),
            title: const Text('Recordatorios de stock'),
            subtitle: Text('Cada $_stockReminderDays días'),
            value: _stockReminderEnabled,
            onChanged: (v) {
              setState(() => _stockReminderEnabled = v);
              _savePref('stock_reminder_enabled', v);
              if (v) {
                showDialog(context: context, builder: (_) => AlertDialog(
                  title: const Text('Frecuencia'),
                  content: DropdownButton<int>(
                    value: _stockReminderDays,
                    items: [3, 7, 15, 30].map((d) => DropdownMenuItem(value: d, child: Text('$d días'))).toList(),
                    onChanged: (nv) { setState(() => _stockReminderDays = nv!); _savePref('stock_reminder_days', nv); },
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Listo'))],
                ));
              }
            },
          )),
          const SizedBox(height: 16),
          
          // SISTEMA
          const Text('Sistema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Card(child: SwitchListTile(
            secondary: const Icon(Icons.notifications_active, color: Colors.purple),
            title: const Text('Notificaciones'),
            subtitle: const Text('Alertas de stock bajo'),
            value: _notificationsEnabled,
            onChanged: (v) { setState(() => _notificationsEnabled = v); _savePref('notifications_enabled', v); },
          )),
          const SizedBox(height: 24),
          const Center(child: Text('Nova ADEN v1.0.0', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  void _editField(String key, TextEditingController ctrl) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(key == 'company_name' ? 'Nombre de Empresa' : 'Impuesto %'),
      content: TextField(controller: ctrl, keyboardType: key == 'tax_rate' ? TextInputType.number : TextInputType.text),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          final val = key == 'tax_rate' ? (double.tryParse(ctrl.text) ?? 0.0) : ctrl.text.trim();
          _savePref(key, val);
          Navigator.pop(context);
        }, child: const Text('Guardar')),
      ],
    ));
  }
}
