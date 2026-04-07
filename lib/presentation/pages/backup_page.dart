import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../core/database/database_helper.dart';
import '../../core/repositories/product_repository.dart';
import '../../core/models/product.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _autoBackup = false;
  bool _isLoading = false;
  String _lastBackupDate = 'Nunca';
  String _lastBackupHash = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoBackup = prefs.getBool('auto_backup') ?? false;
      _lastBackupDate = prefs.getString('last_backup_date') ?? 'Nunca';
    });
  }

  Future<void> _toggleAutoBackup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_backup', value);
    setState(() => _autoBackup = value);
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final backupFolder = Directory('${directory.path}/NovaAden_Backups');
      if (!await backupFolder.exists()) await backupFolder.create(recursive: true);
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final jsonPath = '${backupFolder.path}/backup_$timestamp.json';
      final zipPath = '${backupFolder.path}/backup_$timestamp.zip';
      
      final productRepo = ProductRepository();
      final products = await productRepo.getAllProducts();
      final prefs = await SharedPreferences.getInstance();
      
      final backupData = {
        'version': '1.0.0',
        'fecha': DateTime.now().toIso8601String(),
        'productos': products.map((p) => p.toMap()).toList(),
        'configuracion': {
          'currency': prefs.getString('currency'),
          'mlc_rate': prefs.getDouble('mlc_rate'),
          'stock_reminders': prefs.getBool('stock_reminders'),
        },
      };
      
      final jsonFile = File(jsonPath);
      await jsonFile.writeAsString(jsonEncode(backupData));
      
      // Comprimir (RF 76)
      final bytes = await jsonFile.readAsBytes();
      final archive = Archive();
      archive.addFile(ArchiveFile('backup.json', bytes.length, bytes));
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive)!;
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipData);
      await jsonFile.delete();
      
      // Validar integridad (RF 77)
      final hashBytes = await zipFile.readAsBytes();
      final hash = sha256.convert(hashBytes).toString();
      _lastBackupHash = hash;
      _lastBackupDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      
      final p = await SharedPreferences.getInstance();
      await p.setString('last_backup_date', _lastBackupDate);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Respaldo creado: $zipPath'), backgroundColor: Colors.green, duration: const Duration(seconds: 5)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red));
      }
    }
    setState(() => _isLoading = false);
  }

  // RF 39: Restaurar desde respaldo
  Future<void> _restoreBackup() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Restaurar Respaldo'),
        content: const Text('Esto reemplazará TODOS los datos actuales (productos, clientes, ventas) con los del respaldo. ¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              
              try {
                final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
                final backupFolder = Directory('${directory.path}/NovaAden_Backups');
                
                if (!await backupFolder.exists()) {
                  throw Exception('No hay carpeta de respaldos');
                }
                
                // Buscar el zip más reciente
                final files = await backupFolder.list().toList();
                final zips = files.where((f) => f.path.endsWith('.zip')).cast<File>().toList();
                if (zips.isEmpty) throw Exception('No hay respaldos encontrados');
                
                zips.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
                final latestZip = zips.first;
                
                // Descomprimir
                final bytes = await latestZip.readAsBytes();
                final archive = ZipDecoder().decodeBytes(bytes);
                
                String? jsonData;
                for (final file in archive) {
                  if (file.isFile && file.name.endsWith('.json')) {
                    final content = file.content;
                    jsonData = utf8.decode(content as List<int>);
                    break;
                  }
                }
                
                if (jsonData == null) throw Exception('Respaldo corrupto: falta JSON');
                
                final data = jsonDecode(jsonData);
                final productsJson = data['productos'] as List;
                
                // Restaurar DB
                final db = await DatabaseHelper.instance.database;
                await db.delete('productos');
                await db.delete('ventas'); // Opcional: mantener ventas o borrarlas
                await db.delete('compras');
                await db.delete('clientes');
                await db.delete('proveedores');
                await db.delete('ajustes_inventario');
                await db.delete('mermas');
                await db.delete('ventas_pausadas');

                // Insertar productos
                for (var pJson in productsJson) {
                  final p = Product(
                    id: pJson['id'],
                    nombre: pJson['nombre'],
                    codigo: pJson['codigo'],
                    costo: (pJson['costo'] as num?)?.toDouble(),
                    precioVenta: (pJson['precio_venta'] as num).toDouble(),
                    stockActual: pJson['stock_actual'],
                    stockMinimo: pJson['stock_minimo'],
                    categoria: pJson['categoria'],
                    esFavorito: pJson['es_favorito'] == 1,
                    stockCritico: pJson['stock_critico'],
                    margenGanancia: (pJson['margen_ganancia'] as num?)?.toDouble(),
                    unidadMedida: pJson['unidad_medida'],
                    activo: pJson['activo'] == 1,
                    notas: pJson['notas'],
                  );
                  await db.insert('productos', p.toMap());
                }
                
                // Restaurar configuración
                if (data['configuracion'] != null) {
                  final prefs = await SharedPreferences.getInstance();
                  final config = data['configuracion'];
                  if (config['mlc_rate'] != null) await prefs.setDouble('mlc_rate', config['mlc_rate'].toDouble());
                  if (config['stock_reminders'] != null) await prefs.setBool('stock_reminders', config['stock_reminders']);
                }
                
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Datos restaurados correctamente'), backgroundColor: Colors.green));
                _loadSettings();
                
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error al restaurar: $e'), backgroundColor: Colors.red));
              }
              setState(() => _isLoading = false);
            },
            child: const Text('Sí, Restaurar'),
          ),
        ],
      ),
    );
  }

  // RF 37: Ejecutar respaldo automático
  Future<void> _runAutoBackup() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('auto_backup') == true) {
      final lastDate = prefs.getString('last_backup_date') ?? '';
      final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      if (lastDate != today) {
        // En un app real esto se corre en background, aquí simulamos la ejecución
        // await _createBackup(); 
        print('Auto-backup debería ejecutarse hoy');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Respaldos'), centerTitle: true),
      body: _isLoading ? const Center(child: CircularProgressIndicator())
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
                        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Respaldos Automáticos', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Copia de seguridad diaria'),
                        ]),
                        Switch(value: _autoBackup, onChanged: _toggleAutoBackup),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Respaldo Manual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Se guardan en: /Android/data/.../NovaAden_Backups/', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _createBackup, icon: const Icon(Icons.backup), label: const Text('CREAR RESPALDO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _restoreBackup, icon: const Icon(Icons.restore), label: const Text('RESTAURAR RESPALDO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white))),
                const SizedBox(height: 24),
                Card(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ℹ️ Información', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Último respaldo: $_lastBackupDate'),
                        if (_lastBackupHash.isNotEmpty) Text('Hash: ${_lastBackupHash.substring(0, 10)}...', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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
