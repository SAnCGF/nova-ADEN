import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LicenseService {
  static const String _secretKey = 'nova-ADEN-2025-Cuba-MIPYME-SECRET';
  
  // ⚠️ LISTA BLANCA DE LICENCIAS VÁLIDAS
  static const List<String> _validLicenses = [
    'NOVA-0778-A026-8D53', // DESARROLLADOR - nova-ADEN
    'NOVA-A3F7-B2C9-D4E1', // MIPYME El Ahorro - CLIENTE001
    'NOVA-G7H8-I9J0-K1L2', // TCP La Caridad - CLIENTE002
    'NOVA-M3N4-O5P6-Q7R8', // MIPYME TechCuba - CLIENTE003
  ];
  
  // Instancia reutilizable para almacenamiento seguro (más rápido)
  static const _storage = FlutterSecureStorage();
  static const _licenseKey = 'nova_aden_license';
  static const _deviceKey = 'nova_aden_device_id';
  
  // Cache en memoria para evitar lecturas repetidas
  static String? _cachedLicense;
  static String? _cachedDeviceId;
  static bool _cacheInitialized = false;
  
  /// Genera un código de licencia único para un cliente
  static String generateLicenseCode({
    required String clientId,
    required String businessName,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$clientId-$businessName-$_secretKey-$timestamp';
    final hash = sha256.convert(utf8.encode(data)).toString().toUpperCase();
    return 'NOVA-${hash.substring(0, 4)}-${hash.substring(4, 8)}-${hash.substring(8, 12)}';
  }
  
  /// Valida formato de licencia (rápido, solo regex)
  static bool validateLicenseFormat(String licenseCode) {
    if (licenseCode.length != 19) return false;
    if (!licenseCode.startsWith('NOVA-')) return false;
    final pattern = RegExp(r'^NOVA-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return pattern.hasMatch(licenseCode);
  }
  
  /// Valida licencia contra lista blanca (O(1) con HashSet en producción)
  static bool validateLicenseInWhitelist(String licenseCode) {
    return _validLicenses.contains(licenseCode);
  }
  
  /// Obtener ID del dispositivo con cache (más rápido en relecturas)
  static Future<String> _getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    
    final deviceInfo = DeviceInfoPlugin();
    try {
      final androidInfo = await deviceInfo.androidInfo;
      _cachedDeviceId = androidInfo.id;
    } catch (e) {
      _cachedDeviceId = 'unknown';
    }
    return _cachedDeviceId!;
  }
  
  /// Validación completa optimizada
  static Future<Map<String, dynamic>> validateLicense(String licenseCode) async {
    // 1. Validar formato (rápido)
    if (!validateLicenseFormat(licenseCode)) {
      return {'valid': false, 'error': 'Formato de licencia inválido'};
    }
    
    // 2. Validar contra lista blanca (rápido)
    if (!validateLicenseInWhitelist(licenseCode)) {
      return {'valid': false, 'error': 'Licencia no registrada. Contacte al desarrollador.'};
    }
    
    // 3. Obtener ID del dispositivo (con cache)
    final currentDeviceId = await _getDeviceId();
    
    // 4. Verificar licencia guardada (con cache)
    if (!_cacheInitialized) {
      _cachedLicense = await _storage.read(key: _licenseKey);
      _cachedDeviceId = await _storage.read(key: _deviceKey);
      _cacheInitialized = true;
    }
    
    final savedLicense = _cachedLicense;
    final savedDeviceId = _cachedDeviceId;
    
    if (savedLicense != null) {
      if (savedLicense == licenseCode && savedDeviceId == currentDeviceId) {
        return {'valid': true, 'error': null};
      } else if (savedLicense == licenseCode && savedDeviceId != currentDeviceId) {
        return {'valid': false, 'error': 'Esta licencia ya está activada en otro dispositivo'};
      } else {
        return {'valid': false, 'error': 'Ya hay una licencia activada en este dispositivo'};
      }
    }
    
    // 5. Primera activación → Guardar
    await _storage.write(key: _licenseKey, value: licenseCode);
    await _storage.write(key: _deviceKey, value: currentDeviceId);
    _cachedLicense = licenseCode;
    
    return {'valid': true, 'error': null};
  }
  
  /// Verificar si hay licencia activada (optimizado para splash screen)
  static Future<bool> hasActiveLicense() async {
    // Intentar usar cache primero
    if (_cacheInitialized && _cachedLicense != null) {
      return validateLicenseInWhitelist(_cachedLicense!);
    }
    
    // Leer desde storage si no hay cache
    final license = await _storage.read(key: _licenseKey);
    if (license == null) return false;
    
    // Actualizar cache
    _cachedLicense = license;
    _cacheInitialized = true;
    
    return validateLicenseInWhitelist(license);
  }
  
  /// Limpiar cache (útil para testing)
  static void clearCache() {
    _cachedLicense = null;
    _cachedDeviceId = null;
    _cacheInitialized = false;
  }
}
