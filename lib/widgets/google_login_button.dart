// lib/widgets/google_login_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class GoogleLoginButton extends StatefulWidget {
  final ValueChanged<User>? onSuccess;
  final ValueChanged<Object>? onError;

  final Color primaryColor;
  final Color secondaryColor;

  const GoogleLoginButton({
    super.key,
    this.onSuccess,
    this.onError,
    this.primaryColor = const Color(0xFF6200EE),
    this.secondaryColor = const Color(0xFFBB86FC),
  });

  @override
  State<GoogleLoginButton> createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends State<GoogleLoginButton> {
  bool _isHovering = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    final double translateY = _isHovering ? -5.0 : 0.0;
    final double elevation = _isHovering ? 8.0 : 4.0;
    final double buttonWidth = 312.0;
    final double buttonHeight = 48.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap:
            _isLoading
                ? null
                : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final UserCredential? userCredential =
                        await authService.signInWithGoogle();
                    if (userCredential != null && userCredential.user != null) {
                      widget.onSuccess?.call(userCredential.user!);
                    } else {
                      widget.onError?.call(
                        "Google Sign-In cancelado ou falhou.",
                      );
                    }
                  } catch (e) {
                    widget.onError?.call(e);
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.only(top: 13.0),
          width: buttonWidth,
          height: buttonHeight,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [widget.primaryColor, widget.secondaryColor],
              stops: const [0.0, 0.7],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: elevation,
                offset: Offset(0, elevation / 2),
              ),
            ],
          ),
          transform: Matrix4.translationValues(0.0, translateY, 0.0),
          child:
              _isLoading
                  ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                  : Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 10,
                        child: Image.asset(
                          'assets/googleIcon.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const Text(
                        'Entre com sua conta Google',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
