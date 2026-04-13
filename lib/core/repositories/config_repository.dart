import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class ConfigRepository {
  // ✅ Guardar nota diaria actualizada automáticamente
  Future<void> guardarNotaDiaria(String nota) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Insertamos una configuración especial 'nota_diaria_actual' con timestamp
      await db.insert(
        'config',
        {
          'key': 'nota_diaria_actual',
          'value': nota,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Sobreescribe si ya existe
      );
    } catch (e) {
      print('Error guardando nota diaria: $e');
    }
  }

  // ✅ Obtener última nota diaria
  Future<String?> obtenerNotaDiaria() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        'config',
        where: 'key = ?',
        whereArgs: ['nota_diaria_actual'],
      );
      if (result.isNotEmpty) {
        return result.first['value'] as String?;
      }
      return null;
    } catch (e) {
      print('Error leyendo nota diaria: $e');
      return null;
    }
  }

  // ✅ Limpiar nota diaria (ej. al iniciar nueva sesión)
  Future<void> limpiarNotaDiaria() async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'config',
        where: 'key = ?',
        whereArgs: ['nota_diaria_actual'],
      );
    } catch (e) {
      print('Error limpiando nota diaria: $e');
    }
  }
}
