import 'package:shared_preferences/shared_preferences.dart';

class OperationLockService {
  static const String _lockDateKey = 'operation_lock_date';
  static const int _defaultLockDays = 30;

  // RF 69: Verificar si una fecha puede editarse
  static Future<bool> canEditDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final lockDays = prefs.getInt(_lockDateKey) ?? _defaultLockDays;
    final lockDate = DateTime.now().subtract(Duration(days: lockDays));
    return date.isAfter(lockDate);
  }

  // Configurar días de bloqueo
  static Future<void> setLockDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lockDateKey, days);
  }

  // Obtener días de bloqueo actuales
  static Future<int> getLockDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lockDateKey) ?? _defaultLockDays;
  }

  // Mensaje de error
  static String getLockMessage() {
    return '⚠️ No se pueden editar operaciones de más de $_defaultLockDays días atrás';
  }
}
