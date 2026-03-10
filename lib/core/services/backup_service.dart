import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BackupService {
  // RF 75: Backup automático a carpeta externa
  static Future<File> createBackup(Database db) async {
    final directory = await getExternalStorageDirectory();
    final backupDir = Directory('${directory?.path}/NovaADEN/Backups');
    await backupDir.create(recursive: true);
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = '${backupDir.path}/backup_$timestamp.db';
    
    final dbPath = await getDatabasesPath();
    final sourcePath = join(dbPath, 'nova_aden.db');
    
    await File(sourcePath).copy(backupPath);
    return File(backupPath);
  }

  // RF 76: Comprimir respaldo
  static Future<File> compressBackup(File backupFile) async {
    // Implementación simple - en producción usar package archive
    final compressedPath = '${backupFile.path}.zip';
    // TODO: Implementar compresión real con package archive
    return backupFile;
  }

  // RF 77: Validar integridad de respaldo
  static Future<bool> validateBackup(File backupFile) async {
    try {
      if (!await backupFile.exists()) return false;
      if (await backupFile.length() < 1000) return false;
      
      // Intentar abrir la BD para validar
      final db = await openDatabase(backupFile.path, readOnly: true);
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      await db.close();
      
      return tables.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Restaurar backup
  static Future<bool> restoreBackup(File backupFile) async {
    try {
      if (!await validateBackup(backupFile)) return false;
      
      final dbPath = await getDatabasesPath();
      final targetPath = join(dbPath, 'nova_aden.db');
      
      await backupFile.copy(targetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Listar backups disponibles
  static Future<List<File>> listBackups() async {
    final directory = await getExternalStorageDirectory();
    final backupDir = Directory('${directory?.path}/NovaADEN/Backups');
    
    if (!await backupDir.exists()) return [];
    
    final files = await backupDir.list().toList();
    return files.whereType<File>().where((f) => f.path.endsWith('.db')).toList();
  }
}
