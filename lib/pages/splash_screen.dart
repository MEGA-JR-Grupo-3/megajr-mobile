import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // For Timer

import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _minSplashTimePassed = false;
  late Timer _splashTimer;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _minSplashTimePassed = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _splashTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool showSplash =
        !(authProvider.isAuthDataLoaded && _minSplashTimePassed);

    if (!showSplash) {
      // If splash is no longer needed, return an empty container
      // The parent widget (e.g., initial_page) will then build its content.
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor:
          Theme.of(
            context,
          ).colorScheme.background, // Use your defined background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your actual logo asset
            Image.asset(
              'assets/splash-pato.png', // Ensure this path is correct and asset is added to pubspec.yaml
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 20),
            Text(
              'JubiTasks',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Gerencie suas tarefas com o seu amigo Jubileu!',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(), // Loading indicator
          ],
        ),
      ),
    );
  }
}
