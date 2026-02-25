import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  Future<AppSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return AppSettings(
        currency: prefs.getString('currency') ?? 'CUP',
        exchangeRate: prefs.getDouble('exchangeRate') ?? 1.0,
        companyName: prefs.getString('companyName') ?? '',
        rnc: prefs.getString('rnc') ?? '',
        address: prefs.getString('address') ?? '',
        phone: prefs.getString('phone') ?? '',
      );
    } catch (e) {
      return AppSettings();
    }
  }

  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', settings.currency);
      await prefs.setDouble('exchangeRate', settings.exchangeRate);
      await prefs.setString('companyName', settings.companyName);
      await prefs.setString('rnc', settings.rnc);
      await prefs.setString('address', settings.address);
      await prefs.setString('phone', settings.phone);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCurrency(String currency, double rate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', currency);
      await prefs.setDouble('exchangeRate', rate);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> crearRespaldo() async {
    try {
      final dbPath = await getDatabasesPath();
      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File('${backupDir.path}/nova_aden_$timestamp.db');
      
      final dbFile = File('$dbPath/nova_aden.db');
      if (await dbFile.exists()) {
        await dbFile.copy(backupFile.path);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restaurarRespaldo() async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      if (!await backupDir.exists()) return [];
      
      final backups = <Map<String, dynamic>>[];
      await for (final entity in backupDir.list()) {
        if (entity is File && entity.path.endsWith('.db')) {
          final stat = await entity.stat();
          backups.add({
            'nombre': entity.path.split('/').last,
            'path': entity.path,
            'fecha': stat.modified.toIso8601String(),
            'tamano': stat.size,
          });
        }
      }
      return backups;
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> shareBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(backupPath)]);
      }
    } catch (e) {
      // Error al compartir
    }
  }

  Future<Directory> _getBackupDirectory() async {
    final externalDir = await getExternalStorageDirectory();
    final backupDir = Directory('${externalDir?.path}/archivos/nova_aden_backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<Map<String, dynamic>> getBackupStats() async {
    try {
      final backups = await getBackups();
      return {
        'totalBackups': backups.length,
        'totalSize': backups.fold(0.0, (sum, b) => sum + (b['tamano'] as int? ?? 0)),
      };
    } catch (e) {
      return {'totalBackups': 0, 'totalSize': 0.0};
    }
  }
}
