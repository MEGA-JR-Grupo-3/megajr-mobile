// lib/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async'; // Required for Timer

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    // Setup for the pulse animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400), // animate-[pulse_0.75s]
    )..repeat(reverse: true); // ease-in-out_infinite

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      // Adjust begin/end for desired pulse effect
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // ease-in-out
      ),
    );

    // Simulates a loading time, then navigates
    Timer(const Duration(milliseconds: 1400), () {
      // 1400ms duration
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        Navigator.of(context).pushReplacementNamed('/initial');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ScaleTransition(
          scale: _pulseAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "JubiTasks",
                style: TextStyle(
                  fontSize: 22, // text-[22px]
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 56), // gap-14 (roughly 14 * 4 = 56px)
              Image.asset(
                'assets/gif-pato.gif', // Path to your GIF asset
                width: 200, // width={200}
                height: 200, // height={200}
              ),
            ],
          ),
        ),
      ),
    );
  }
}
