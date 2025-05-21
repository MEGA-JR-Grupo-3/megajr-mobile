// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '/firebase_options.dart';
import 'package:mobile_megajr_grupo3/pages/login_page.dart';
import 'package:mobile_megajr_grupo3/pages/register_page.dart';
import 'package:mobile_megajr_grupo3/pages/dashboard_page.dart';
import 'package:mobile_megajr_grupo3/pages/initial_page.dart';
import 'package:mobile_megajr_grupo3/pages/splash_screen.dart';
import 'package:mobile_megajr_grupo3/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
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
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.light,
        // Define other light theme properties
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white),
        ),
      ),
      // Set the SplashScreen as the initial widget to be displayed
      home: const SplashScreen(), // Use home property for the very first screen
      routes: {
        // You might use named routes for navigation *after* the splash screen
        '/initial':
            (context) =>
                const InitialPage(), // This is where the splash screen navigates
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const TelaPrincipal(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
