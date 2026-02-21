import 'package:flutter/material.dart';
import 'package:nova_aden/core/models/app_settings.dart';
import 'package:nova_aden/core/repositories/settings_repository.dart';
import 'package:nova_aden/presentation/pages/backup_page.dart';
import 'package:nova_aden/presentation/pages/price_update_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsRepository _repository = SettingsRepository();
  AppSettings _settings = AppSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    _settings = await _repository.getSettings();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // RF 35: Configuración de Moneda
                _buildSectionTitle('💰 Moneda'),
                _buildCurrencyCard(),
                
                const SizedBox(height: 24),
                
                // RF 36: Actualización Masiva de Precios
                _buildSectionTitle('🏷️ Precios'),
                _buildPriceUpdateCard(),
                
                const SizedBox(height: 24),
                
                // RF 37, 38, 39: Respaldos
                _buildSectionTitle('💾 Respaldos'),
                _buildBackupCard(),
                
                const SizedBox(height: 24),
                
                // Otras configuraciones
                _buildSectionTitle('⚙️ Otras Configuraciones'),
                _buildSwitchCard(
                  title: 'Mostrar costos en reportes',
                  subtitle: 'Visible solo para administradores',
                  value: _settings.showCostInReports,
                  onChanged: (v) async {
                    _settings.showCostInReports = v;
                    await _repository.saveSettings(_settings);
                  },
                ),
                _buildSwitchCard(
                  title: 'Permitir stock negativo',
                  subtitle: 'No recomendado para inventario preciso',
                  value: _settings.allowNegativeStock,
                  onChanged: (v) async {
                    _settings.allowNegativeStock = v;
                    await _repository.saveSettings(_settings);
                  },
                ),
                _buildSliderCard(
                  title: 'Alerta de stock bajo',
                  subtitle: 'Alertar cuando stock sea menor a',
                  value: _settings.lowStockThreshold.toDouble(),
                  min: 1,
                  max: 50,
                  divisions: 49,
                  onChanged: (v) async {
                    _settings.lowStockThreshold = v.toInt();
                    await _repository.saveSettings(_settings);
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Información de la app
                _buildAppInfoCard(),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
    );
  }

  Widget _buildCurrencyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Moneda Principal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('CUP'),
                    subtitle: const Text('Peso Cubano'),
                    value: 'CUP',
                    groupValue: _settings.currency,
                    onChanged: (v) async {
                      await _repository.updateCurrency(v!, _settings.exchangeRate);
                      setState(() => _settings.currency = v);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('MLC'),
                    subtitle: const Text('Moneda Libre Convertible'),
                    value: 'MLC',
                    groupValue: _settings.currency,
                    onChanged: (v) async {
                      await _repository.updateCurrency(v!, _settings.exchangeRate);
                      setState(() => _settings.currency = v);
                    },
                  ),
                ),
              ],
            ),
            if (_settings.currency == 'MLC') ...[
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tasa de cambio a CUP',
                  prefixText: '1 MLC = ',
                  suffixText: 'CUP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: TextEditingController(text: _settings.exchangeRate.toString()),
                onChanged: (v) async {
                  final rate = double.tryParse(v) ?? 1.0;
                  await _repository.updateCurrency(_settings.currency, rate);
                  setState(() => _settings.exchangeRate = rate);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceUpdateCard() {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.price_change, color: Colors.white)),
        title: const Text('Actualizar Precios Masivamente'),
        subtitle: const Text('Modificar precios de todos los productos por porcentaje o valor fijo'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PriceUpdatePage())),
      ),
    );
  }

  Widget _buildBackupCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.backup, color: Colors.white)),
            title: const Text('Gestionar Respaldos'),
            subtitle: const Text('Crear, restaurar o eliminar respaldos de datos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BackupPage())),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: _repository.getBackupStats(),
            builder: (context, snapshot) {
              final stats = snapshot.data ?? {};
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Respaldos', '${stats['totalBackups'] ?? 0}'),
                    _buildStatItem('Tamaño', _formatSize(stats['totalSize'] ?? 0.0)),
                    _buildStatItem('Último', _formatDate(stats['lastBackup'])),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        secondary: const Icon(Icons.toggle_on, color: Color(0xFF1E3A5F)),
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    label: value.toInt().toString(),
                    onChanged: onChanged,
                  ),
                ),
                Text('${value.toInt()} und', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('nova-ADEN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('v1.0.0', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Gestión Operativa para MIPYMES y TCP', style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text('Software Libre - GPL', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text('© 2025 - Cuba', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    ]);
  }

  String _formatSize(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final dt = date is DateTime ? date : DateTime.parse(date);
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
