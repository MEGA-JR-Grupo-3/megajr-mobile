// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:mobile_megajr_grupo3/pages/login_page.dart';
import 'package:mobile_megajr_grupo3/pages/register_page.dart';
import 'package:mobile_megajr_grupo3/pages/dashboard_page.dart';
import 'package:mobile_megajr_grupo3/pages/initial_page.dart';
import 'package:mobile_megajr_grupo3/pages/splash_screen.dart';
import 'package:mobile_megajr_grupo3/providers/theme_provider.dart';
import 'package:mobile_megajr_grupo3/services/auth_service.dart';
import 'package:mobile_megajr_grupo3/pages/team_screen.dart';
import 'package:mobile_megajr_grupo3/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider<AuthService>(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Mega Jr App',
      themeMode: themeProvider.themeMode, // Controlado pelo ThemeProvider
      theme: AppTheme.lightTheme, // Use o tema claro definido em app_theme.dart
      darkTheme:
          AppTheme.darkTheme, // Use o tema escuro definido em app_theme.dart

      home: const SplashScreen(),

      routes: {
        '/initial': (context) => const InitialPage(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/register': (context) => const RegisterScreen(),
        '/team': (context) => const TeamScreen(),
      },
    );
  }
}
