import 'package:flutter/material.dart';
import 'package:nova_aden/core/constants/app_constants.dart';
import 'package:nova_aden/presentation/pages/splash_page.dart';

void main() {
  // WidgetsFlutterBinding se inicializa automáticamente con runApp
  // No es necesario llamarlo explícitamente a menos que uses plugins antes de runApp
  runApp(const NovaAdenApp());
}

class NovaAdenApp extends StatelessWidget {
  const NovaAdenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Tema claro
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.primaryColorValue),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      
      // Tema oscuro
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.primaryColorValue),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      
      // Usar tema del sistema
      themeMode: ThemeMode.system,
      
      // Pantalla inicial optimizada
      home: const SplashPage(),
      
      // Prevenir rebuilds innecesarios
      builder: (context, child) {
        // Desactivar banner de debug para mejor rendimiento
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
