import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SeeNearApp());
}

class SeeNearApp extends StatelessWidget {
  const SeeNearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEE:NEAR',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
