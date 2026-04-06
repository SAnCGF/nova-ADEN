import 'package:shared_preferences/shared_preferences.dart';

class CurrencyHelper {
  static Future<double> getMlcRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('mlc_rate') ?? 120.0;
  }

  static Future<double> getUsdRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('usd_rate') ?? 1.0;
  }

  static double convertFromCUP(double cupAmount, String targetCurrency, double mlcRate, double usdRate) {
    if (targetCurrency == 'MLC') return cupAmount / mlcRate;
    if (targetCurrency == 'USD') return cupAmount / usdRate;
    return cupAmount;
  }

  static double convertToCUP(double foreignAmount, String sourceCurrency, double mlcRate, double usdRate) {
    if (sourceCurrency == 'MLC') return foreignAmount * mlcRate;
    if (sourceCurrency == 'USD') return foreignAmount * usdRate;
    return foreignAmount;
  }
}
