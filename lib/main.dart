import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/pages/splash_page.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  runApp(NovaAdenApp(initialDarkMode: isDark));
}

class NovaAdenApp extends StatefulWidget {
  final bool initialDarkMode;
  const NovaAdenApp({super.key, required this.initialDarkMode});
  @override
  State<NovaAdenApp> createState() => _NovaAdenAppState();
}

class _NovaAdenAppState extends State<NovaAdenApp> {
  late bool _isDark;
  @override
  void initState() {
    super.initState();
    _isDark = widget.initialDarkMode;
  }
  void _toggleTheme(bool isDarkMode) async {
    setState(() => _isDark = isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDarkMode);
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: _isDark ? _darkTheme : _lightTheme,
      home: SplashPage(onToggleTheme: _toggleTheme, isDark: _isDark),
    );
  }
  ThemeData get _lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[700],
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.blue[700]!,
      secondary: Colors.green[600]!,
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onError: Colors.white,
    ),
  );
  ThemeData get _darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.blue[400]!,
      secondary: Colors.green[400]!,
      surface: Colors.grey[850]!,
      error: Colors.red[400]!,
      onPrimary: Colors.black87,
      onSecondary: Colors.black87,
      onSurface: Colors.white,
      onError: Colors.black87,
    ),
  );
}
