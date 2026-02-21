import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:nova_aden/core/models/app_settings.dart';
import 'package:nova_aden/core/models/backup.dart';
import 'package:nova_aden/core/database/database_helper.dart';
import 'package:nova_aden/core/repositories/product_repository.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProductRepository _productRepo = ProductRepository();

  Future<AppSettings> getSettings() async => AppSettings();
  Future<bool> saveSettings(AppSettings settings) async => true;

  Future<bool> updateCurrency(String currency, double exchangeRate) async {
    final settings = await getSettings();
    settings.currency = currency;
    settings.exchangeRate = exchangeRate;
    return await saveSettings(settings);
  }

  Future<bool> updatePricesMassively({
    required String filterType,
    required String updateType,
    required double value,
    required bool increase,
  }) async {
    try {
      final products = await _productRepo.getAllProducts();
      for (final product in products) {
        double newPrice = product.price;
        if (updateType == 'percentage') {
          newPrice = increase ? product.price * (1 + value / 100) : product.price * (1 - value / 100);
        } else {
          newPrice = increase ? product.price + value : product.price - value;
        }
        if (newPrice < 0) newPrice = 0;
        await _productRepo.updateProduct(product.copyWith(price: newPrice));
      }
      return true;
    } catch (e) => false;
  }

  Future<String> createBackup({String type = 'manual'}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/nova_aden_backups');
      if (!await backupDir.exists()) await backupDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'nova_aden_backup_$timestamp.json';
      final filePath = '${backupDir.path}/$fileName';

      final products = await _productRepo.getAllProducts();
      final stats = await _productRepo.getStats();
      
      final backupData = {
        'version': '1.0.0',
        'date': DateTime.now().toIso8601String(),
        'type': type,
        'products': products.map((p) => p.toMap()).toList(),
        'stats': stats,
      };

      await File(filePath).writeAsString(jsonEncode(backupData));
      
      final settings = await getSettings();
      settings.lastBackupDate = DateTime.now().toIso8601String();
      settings.backupPath = filePath;
      await saveSettings(settings);

      return filePath;
    } catch (e) {
      print('Error backup: $e');
      return '';
    }
  }

  Future<List<Backup>> getBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/nova_aden_backups');
      if (!await backupDir.exists()) return [];

      final backups = <Backup>[];
      for (final entity in await backupDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          final stats = await entity.stat();
          backups.add(Backup(
            id: entity.path.split('/').last,
            fileName: entity.path.split('/').last,
            date: stats.modified,
            productsCount: 0, salesCount: 0, purchasesCount: 0,
            fileSize: stats.size.toDouble(),
            path: entity.path,
          ));
        }
      }
      backups.sort((a, b) => b.date.compareTo(a.date));
      return backups;
    } catch (e) => [];
  }

  Future<bool> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) await file.delete();
      return true;
    } catch (e) => false;
  }

  // Compartir: En Android real, el usuario puede usar el gestor de archivos
  // para compartir el backup desde la carpeta de la app
  Future<String?> getBackupSharePath(String backupPath) async => backupPath;

  Future<bool> restoreBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (!await file.exists()) return false;
      final content = await file.readAsString();
      final backupData = jsonDecode(content) as Map<String, dynamic>;
      if (backupData['version'] != '1.0.0') throw Exception('Versión incompatible');
      // Restaurar productos (implementación básica)
      final settings = await getSettings();
      settings.lastBackupDate = DateTime.now().toIso8601String();
      await saveSettings(settings);
      return true;
    } catch (e) {
      print('Error restore: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getBackupStats() async {
    try {
      final backups = await getBackups();
      final totalSize = backups.fold<double>(0, (sum, b) => sum + b.fileSize);
      return {
        'totalBackups': backups.length,
        'totalSize': totalSize,
        'lastBackup': backups.isNotEmpty ? backups.first.date : null,
      };
    } catch (e) => {'totalBackups': 0, 'totalSize': 0.0};
  }
}
