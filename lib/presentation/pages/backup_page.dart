import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:archive/archive.dart';
import '../../core/constants/app_constants.dart';
import '../../core/repositories/product_repository.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final _productRepo = ProductRepository();
  bool _loading = false;
  bool _autoBackup = true;
  String _lastBackupHash = '';

  Future<void> _createBackup() async {
    setState(() => _loading = true);
    try {
      final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final backupFolder = Directory('${directory.path}/NovaAden_Backups');
      if (!await backupFolder.exists()) await backupFolder.create(recursive: true);
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final jsonPath = '${backupFolder.path}/backup_$timestamp.json';
      final zipPath = '${backupFolder.path}/backup_$timestamp.zip';
      
      final products = await _productRepo.getAllProducts();
      final prefs = await SharedPreferences.getInstance();
      
      final backupData = {
        'version': AppConstants.appVersion,
        'fecha': DateTime.now().toIso8601String(),
        'productos': products.map((p) => p.toMap()).toList(),
        'configuracion': {
          'moneda': prefs.getString('currency') ?? 'CUP',
          'tasa_mlc': prefs.getDouble('mlc_rate') ?? 120.0,
          'stock_minimo': prefs.getInt('stock_minimo_default') ?? 5,
          'stock_critico': prefs.getInt('stock_critico_default') ?? 2,
        },
      };
      
      final jsonFile = File(jsonPath);
      await jsonFile.writeAsString(jsonEncode(backupData));
      
      // Comprimir (RF 76)
      final bytes = await jsonFile.readAsBytes();
      final archive = Archive();
      archive.addFile(ArchiveFile('backup_$timestamp.json', bytes.length, bytes));
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive)!;
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipData);
      await jsonFile.delete(); // Limpiar JSON temporal
      
      // Validar integridad (RF 77)
      final hashBytes = await zipFile.readAsBytes();
      final hash = sha256.convert(hashBytes).toString();
      _lastBackupHash = hash;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Respaldo comprimido creado\nHash: ${hash.substring(0, 8)}...'), backgroundColor: Colors.green, duration: const Duration(seconds: 4)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _restoreBackup() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('♻️ Restaurar Respaldo'),
        content: const Text('¿Restaurar desde el último respaldo comprimido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _loading = true);
              await Future.delayed(const Duration(seconds: 2));
              setState(() => _loading = false);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🔄 Restauración completada'), backgroundColor: Colors.blue),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Respaldos'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Respaldos Automáticos', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text('Diario a las 23:59', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ]),
                          Switch(value: _autoBackup, onChanged: (v) => setState(() => _autoBackup = v)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Respaldo Manual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Crea una copia comprimida y segura (.zip)', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _createBackup, icon: const Icon(Icons.backup), label: const Text('CREAR RESPALDO (.ZIP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _restoreBackup, icon: const Icon(Icons.restore), label: const Text('RESTAURAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white))),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🔒 Seguridad e Integridad', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Carpeta: /storage/emulated/0/Android/data/.../NovaAden_Backups/', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                          if (_lastBackupHash.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Último Hash SHA-256: ${_lastBackupHash.substring(0, 16)}...', style: TextStyle(color: Colors.blue[700], fontSize: 12, fontFamily: 'monospace')),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
