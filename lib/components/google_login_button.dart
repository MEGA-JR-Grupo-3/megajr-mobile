// lib/components/google_login_button.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// REMOVA ESTA LINHA SE ELA ESTIVER APENAS PARA A DEFINIÇÃO DUPLICADA: import 'package:google_sign_in/google_sign_in.dart';

import '../services/auth_service.dart'; // ESTA É A IMPORTAÇÃO CORRETA PARA SEU AUTHSERVICE

class GoogleLoginButton extends StatelessWidget {
  final Function(User) onSuccess;
  final Function(Object) onError;

  const GoogleLoginButton({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    // Instancie SEU ÚNICO AuthService do arquivo de serviços
    final AuthService _authService = AuthService();

    return Padding(
      padding: const EdgeInsets.only(top: 13.0),
      child: ElevatedButton(
        onPressed: () async {
          try {
            UserCredential? userCredential =
                await _authService
                    .signInWithGoogle(); // Chamando o método do AuthService correto
            if (userCredential != null && userCredential.user != null) {
              onSuccess(userCredential.user!);
            } else {
              onError("Login do Google cancelado ou falhou.");
            }
          } catch (e) {
            print("Erro no onPressed do GoogleLoginButton: $e");
            onError(e);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          minimumSize: const Size(312, 50),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment.center,
              radius: 0.7,
              colors: [Color(0xFF5A2C7B), Color(0xFF330F4F)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(minWidth: 312, minHeight: 50),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/googleIcon.png', height: 24, width: 24),
                const SizedBox(width: 10),
                const Text(
                  'Entre com sua conta Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
