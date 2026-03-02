import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nova_aden/core/constants/app_constants.dart';
import 'package:nova_aden/presentation/pages/splash_page.dart';
import 'presentation/bloc/producto_bloc.dart';
import 'presentation/bloc/venta_bloc.dart';
import 'core/repositories/product_repository.dart';
import 'core/repositories/sale_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NovaAdenApp());
}

class NovaAdenApp extends StatelessWidget {
  const NovaAdenApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instanciar repositorios con los nombres correctos (en inglés)
    final productRepo = ProductRepository();
    final saleRepo = SaleRepository();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductoBloc(repository: productRepo)),
        ChangeNotifierProvider(create: (_) => VentaBloc(repository: saleRepo)),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        
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
        ),
        
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(AppConstants.primaryColorValue),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        
        themeMode: ThemeMode.system,
        home: const SplashPage(),
      ),
    );
  }
}
