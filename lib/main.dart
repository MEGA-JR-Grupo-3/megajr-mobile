// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Páginas
import 'package:mobile_megajr_grupo3/pages/login_page.dart';
import 'package:mobile_megajr_grupo3/pages/register_page.dart';
import 'package:mobile_megajr_grupo3/pages/dashboard_page.dart';
import 'package:mobile_megajr_grupo3/pages/initial_page.dart';
import 'package:mobile_megajr_grupo3/pages/splash_screen.dart';
import 'package:mobile_megajr_grupo3/pages/team_screen.dart';

// Provedores
import 'package:mobile_megajr_grupo3/providers/theme_provider.dart';
import 'package:mobile_megajr_grupo3/providers/auth_provider.dart'; // Seu AuthProvider
import 'package:mobile_megajr_grupo3/services/api_service.dart';

// Tema
import 'package:mobile_megajr_grupo3/theme/app_theme.dart';

// Widgets auxiliares
import 'package:mobile_megajr_grupo3/widgets/app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(), // Seu AuthProvider
        ),
        Provider<ApiService>(
          create:
              (context) => ApiService(
                baseUrl: 'https://megajr-back-end.onrender.com/api',
              ),
        ),
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
      title: 'JubiTasks Mobile',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/initial': (context) => const InitialPage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/team': (context) => const TeamScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _minSplashTimePassed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _minSplashTimePassed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isAuthDataLoaded || !_minSplashTimePassed) {
      return const SplashScreen();
    }

    if (authProvider.isAuthenticated) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute == '/initial' ||
          currentRoute == '/login' ||
          currentRoute == '/register') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        });
        return Container();
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Olá, ${authProvider.registeredName.isNotEmpty ? authProvider.registeredName : authProvider.user?.displayName ?? authProvider.user?.email?.split('@').first ?? "Jubileu!"}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        drawer: const AppDrawer(),
        body: Navigator(
          key: GlobalKey<NavigatorState>(),
          initialRoute: '/dashboard',
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/dashboard':
                page = const DashboardPage();
                break;
              case '/team':
                page = const TeamScreen();
                break;
              default:
                page = const DashboardPage();
                break;
            }
            return MaterialPageRoute(
              builder: (context) => page,
              settings: settings,
            );
          },
        ),
      );
    } else {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute != '/initial' &&
          currentRoute != '/login' &&
          currentRoute != '/register') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/initial');
        });
        return Container();
      }
      return Navigator(
        key: GlobalKey<NavigatorState>(),
        initialRoute: '/initial',
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/initial':
              page = const InitialPage();
              break;
            case '/login':
              page = const LoginScreen();
              break;
            case '/register':
              page = const RegisterScreen();
              break;
            default:
              page = const InitialPage();
              break;
          }
          return MaterialPageRoute(
            builder: (context) => page,
            settings: settings,
          );
        },
      );
    }
  }
}
