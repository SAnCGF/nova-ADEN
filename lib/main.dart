import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/database/database_helper.dart';
import 'presentation/pages/home_page.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Inicializar base de datos
  await DatabaseHelper.instance.database;
  
  runApp(const NovaAdenApp());
}

class NovaAdenApp extends StatelessWidget {
  const NovaAdenApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, theme, child) => MaterialApp(
          title: '${AppConstants.appName} - Administrador',
          debugShowCheckedModeBanner: false,
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomePage(),
        ),
      ),
    );
  }
}
