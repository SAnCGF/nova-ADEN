cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:nova_aden/Nucleo/di/injection.dart';
import 'package:nova_aden/Presentacion/screens/gestion_producto_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nova-ADEN',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GestionProductoScreen(),
    );
  }
}
EOF