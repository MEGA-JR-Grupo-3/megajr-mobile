// lib/pages/initial_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importe o provider
import 'package:mobile_megajr_grupo3/components/button.dart';
import 'package:mobile_megajr_grupo3/providers/theme_provider.dart'; // Importe seu ThemeProvider
import 'package:mobile_megajr_grupo3/theme/custom_colors.dart'; // Importe suas cores personalizadas

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Acesse o ThemeProvider para controlar o tema
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    // Acesse o ThemeData atual para estilos padrões
    final theme = Theme.of(context);
    // Acesse suas cores personalizadas
    final customColors = CustomAppColors.of(context);

    return Scaffold(
      // A cor de fundo do Scaffold virá de theme.scaffoldBackgroundColor,
      // que você já configurou em app_theme.dart
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
                    value: theme.brightness == Brightness.dark,
                    onChanged: (bool value) {
                      themeProvider.toggleTheme(value);
                    },
                    activeColor: customColors.primary,
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
                  Text(
                    "Já é parceiro do Jubileu?",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
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
