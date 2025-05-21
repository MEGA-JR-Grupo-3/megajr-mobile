// lib/pages/initial_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_megajr_grupo3/components/button.dart';

class InitialPage extends StatelessWidget {
  // Or HomePage
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20),
                  child: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (bool value) {},
                    activeColor: Colors.purple,
                  ),
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/splash-pato.png',
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 80),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Já é parceiro do Jubileu?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 58),
                  CustomButton(
                    buttonText: "Fazer Login",
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    buttonText: "Cadastrar-se",
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
