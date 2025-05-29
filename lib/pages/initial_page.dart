import 'package:flutter/material.dart';
import 'package:mobile_megajr_grupo3/widgets/custom_button.dart'; // Ajuste o caminho conforme necessário
import 'package:mobile_megajr_grupo3/widgets/theme_switch.dart'; // Ajuste o caminho conforme necessário

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(
            context,
          ).colorScheme.background, // Usa a cor de fundo do tema
      body: Stack(
        // Usamos Stack para posicionar o ThemeSwitch
        children: [
          Center(
            child: SingleChildScrollView(
              // Permite rolagem em telas menores
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Imagem do Pato
                    Image.asset(
                      'assets/splash-pato.png', // Verifique este caminho no seu pubspec.yaml
                      height: 200,
                      width: 200, // Você pode ajustar a largura se precisar
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      height: 50,
                    ), // Espaço entre imagem e texto/botões
                    Text(
                      'Já é parceiro do Jubileu?',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 58), // Espaço similar ao pb-[58px]
                    // Botão "Fazer Login"
                    CustomButton(
                      buttonText: 'Fazer Login',
                      onClick: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                    ),
                    const SizedBox(height: 40), // Espaço similar ao mb-[40px]
                    // Botão "Cadastrar-se"
                    CustomButton(
                      buttonText: 'Cadastrar-se',
                      onClick: () {
                        Navigator.of(context).pushNamed('/register');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ThemeSwitch posicionado no canto superior direito
          const Positioned(
            top: 40, // Ajuste este valor para o espaçamento desejado
            right: 20, // Ajuste este valor para o espaçamento desejado
            child: ThemeSwitch(),
          ),
        ],
      ),
    );
  }
}
