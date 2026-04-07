import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  bool _isDarkMode = false;
  
  ThemeController() { 
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTheme()); 
  }
  
  bool get isDarkMode => _isDarkMode;
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }
  
  ThemeData get lightTheme => ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
    appBarTheme: AppBarTheme(backgroundColor: Colors.blue[900]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.blue[900]!),
  );
  
  ThemeData get darkTheme => ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
    appBarTheme: AppBarTheme(backgroundColor: Colors.blue[700]),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.blue[800]!),
  );
}
