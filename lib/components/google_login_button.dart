import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Importa o Google Sign-In

class GoogleLoginButton extends StatelessWidget {
  final Function(User?) onSuccess;
  final Function(dynamic)?
  onError; // Callback onError adicionado para tratamento de erros mais robusto

  const GoogleLoginButton({
    super.key,
    required this.onSuccess,
    this.onError, // Torna onError opcional
  });

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // 1. Cria uma instância do GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // 2. Inicia o fluxo de login do Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Verifica se o usuário cancelou o processo de login
      if (googleUser == null) {
        print("Login com Google cancelado pelo usuário.");
        return; // Sai se o usuário cancelar
      }

      // 3. Obtém os detalhes de autenticação do GoogleSignInAccount
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 4. Cria uma nova credencial com o token de acesso e o token de ID
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Faz login no Firebase com a credencial do Google
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Chama o callback onSuccess com o usuário logado
      onSuccess(userCredential.user);
    } on FirebaseAuthException catch (e) {
      // Trata erros específicos do Firebase (por exemplo, account-exists-with-different-credential)
      print(
        "Erro de Autenticação Firebase durante o Login com Google: ${e.code} - ${e.message}",
      );
      if (onError != null) {
        onError!(e); // Passa a FirebaseAuthException
      }
      // Opcionalmente, mostra uma mensagem amigável ao usuário
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha no login: ${e.message}')));
    } catch (e) {
      // Trata quaisquer outros erros (por exemplo, problemas de rede, erros de configuração do Google Sign-In)
      print("Erro geral durante o Login com Google: $e");
      if (onError != null) {
        onError!(e); // Passa a exceção geral
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ocorreu um erro inesperado: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define as cores do gradiente com base nas suas variáveis CSS --primary e --secondary
    // Você precisará mapear estas para objetos Color reais do Flutter.
    // Para este exemplo, estou usando roxo e roxo escuro como placeholders.
    const Color primaryColor = Color(0xFF6200EE); // Cor primária de exemplo
    const Color secondaryColor = Color(0xFF3700B3); // Cor secundária de exemplo

    // Usando ElevatedButton com estilo personalizado para o gradiente e cantos arredondados
    return ElevatedButton(
      onPressed: () => _signInWithGoogle(context),
      style: ElevatedButton.styleFrom(
        padding:
            EdgeInsets
                .zero, // Remove o preenchimento padrão para permitir que o Ink ocupe todo o espaço
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            40.0,
          ), // Equivalente a rounded-4xl (CSS)
        ),
        elevation: 0, // Remove a elevação padrão
        backgroundColor:
            Colors
                .transparent, // Torna o botão transparente para mostrar o gradiente
        shadowColor: Colors.transparent, // Remove a sombra
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            center: Alignment.center, // circle_at_center
            radius:
                0.7, // Ajuste conforme necessário para obter um efeito semelhante a 70% em CSS
            colors: [
              primaryColor, // var(--primary) (CSS)
              secondaryColor, // var(--secondary) (CSS)
            ],
          ),
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: Container(
          width: 312.0, // w-[312px] (CSS/Tailwind)
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 24.0,
          ), // p-2 (CSS/Tailwind)
          child: Row(
            mainAxisSize: MainAxisSize.min, // Mantém o conteúdo compacto
            children: [
              Image.asset(
                'assets/googleicon.png', // Caminho para o seu ícone do Google (certifique-se de que está no pubspec.yaml)
                height: 24,
                width: 24,
              ),
              const SizedBox(
                width: 10,
              ), // espaçamento (similar a absolute left-[10px] em CSS/Tailwind)
              const Text(
                "Entre com sua conta Google",
                style: TextStyle(
                  color: Colors.white, // text-[#ffffff] (CSS/Tailwind)
                  fontWeight: FontWeight.w600, // font-[600] (CSS/Tailwind)
                  fontSize: 16.0, // Ajuste conforme necessário
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
