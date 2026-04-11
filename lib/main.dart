import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/utils/theme_provider.dart';
import 'presentation/pages/home_page.dart';

void main() {
  // CRÍTICO: Inicializar bindings antes de cualquier plugin
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // ✅ WRAPPER DE PROVIDER - Esto faltaba y causaba el crash
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const NovaAdenApp(),
    ),
  );
}

class NovaAdenApp extends StatelessWidget {
  const NovaAdenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Nova ADEN',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          home: const HomePage(),
        );
      },
    );
  }
}
