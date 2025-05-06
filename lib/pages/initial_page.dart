import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2ED),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/pato.png', height: 500),
            const SizedBox(height: 20),
            const Text(
              'Já é parceiro do Jubileu?',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF6E3A87),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _button(context, 'Fazer Login', const LoginPage()),
            const SizedBox(height: 10),
            _button(context, 'Cadastrar-se', const RegisterPage()),
          ],
        ),
      ),
    );
  }

  Widget _button(BuildContext context, String text, Widget page) {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6E3A87),
          foregroundColor: Colors.white,
              textStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
