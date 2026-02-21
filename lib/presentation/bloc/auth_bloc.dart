import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthBloc extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLicenseActive = false;
  String? _licenseKey;

  bool get isLicenseActive => _isLicenseActive;
  String? get licenseKey => _licenseKey;

  AuthBloc() {
    _checkLicense();
  }

  Future<void> _checkLicense() async {
    try {
      _licenseKey = await _storage.read(key: 'license_key');
      _isLicenseActive = _licenseKey != null && _licenseKey!.isNotEmpty;
      notifyListeners();
    } catch (e) {
      _isLicenseActive = false;
      notifyListeners();
    }
  }

  Future<bool> activateLicense(String licenseKey) async {
    try {
      await _storage.write(key: 'license_key', value: licenseKey);
      _licenseKey = licenseKey;
      _isLicenseActive = true;
      notifyListeners();
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }

  Future<void> deactivateLicense() async {
    await _storage.delete(key: 'license_key');
    _licenseKey = null;
    _isLicenseActive = false;
    notifyListeners();
  }

  bool validateLicense(String licenseKey) {
    // Validación simple: formato XXXX-XXXX-XXXX-XXXX
    final pattern = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return pattern.hasMatch(licenseKey);
  }
}
