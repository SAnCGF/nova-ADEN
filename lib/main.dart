import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'presentation/pages/welcome_page.dart';

void main() {
  runApp(const NovaAdenApp());
}

class NovaAdenApp extends StatelessWidget {
  const NovaAdenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WelcomePage(),
    );
  }
}
