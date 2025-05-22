// lib/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async'; // Required for Timer
import 'package:firebase_auth/firebase_auth.dart'; // Import para o tipo User
import 'package:provider/provider.dart'; // Import para Provider
import 'package:mobile_megajr_grupo3/services/auth_service.dart'; // Import seu AuthService

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  // bool _isVisible = true; // Não precisamos mais disso, a navegação lida com a visibilidade

  // Variável para a subscription do stream de autenticação
  // Para poder cancelar no dispose e evitar memory leaks
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();

    // Setup for the pulse animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400), // animate-[pulse_0.75s]
    )..repeat(reverse: true); // ease-in-out_infinite

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // ease-in-out
      ),
    );

    // Inicia a verificação de login APÓS a animação ou durante ela.
    // Vamos usar Future.delayed para garantir que a animação tenha tempo para ocorrer
    // e o contexto esteja disponível para o Navigator.
    _checkLoginStatusAfterAnimation();
  }

  void _checkLoginStatusAfterAnimation() async {
    // Espere o tempo da sua animação OU um tempo mínimo se a animação for mais rápida
    await Future.delayed(
      const Duration(milliseconds: 1400),
    ); // Duração da sua animação

    // Garantir que o widget ainda está montado antes de fazer qualquer navegação
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    // Agora, assinamos o stream de authStateChanges.
    // O '.listen' receberá o estado atual do usuário imediatamente (logado/não logado)
    // e também escutará mudanças futuras (embora para uma splash screen, queremos a primeira).
    _authStateSubscription = authService.authStateChanges.listen((User? user) {
      // Garantir que o widget ainda está montado E que esta é a primeira vez que redirecionamos
      // para evitar múltiplos redirecionamentos se o stream emitir várias vezes.
      if (mounted) {
        if (user == null) {
          // Usuário não logado, vá para a tela inicial/login
          Navigator.of(context).pushReplacementNamed('/initial');
        } else {
          // Usuário logado, vá para o dashboard
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
        // Uma vez que a navegação é feita, podemos cancelar a subscription.
        // Isso é crucial para evitar que o listener permaneça ativo desnecessariamente.
        _authStateSubscription?.cancel();
        _authStateSubscription = null; // Limpa a referência
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _authStateSubscription
        ?.cancel(); // Certifique-se de cancelar a subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Não é necessário o '_isVisible' para esconder o widget.
    // O Navigator.pushReplacementNamed já irá remover esta tela da pilha.

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
