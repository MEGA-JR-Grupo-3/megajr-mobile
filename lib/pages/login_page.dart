// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_megajr_grupo3/services/auth_service.dart';
import 'package:mobile_megajr_grupo3/services/api_service.dart';
import 'package:mobile_megajr_grupo3/widgets/custom_button.dart';
import 'package:mobile_megajr_grupo3/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false; // Estado para gerenciar o carregamento/botão

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Função para Login com E-mail e Senha ---
  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpa mensagens de erro anteriores
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userCredential = await authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        final firebaseIdToken = await user.getIdToken();
        final apiService = Provider.of<ApiService>(context, listen: false);

        // Chamar o backend para user-data
        final backendResponse = await apiService.post(
          '/user-data', // Endpoint do backend
          headers: {"Authorization": "Bearer $firebaseIdToken"},
          body: {},
        );

        if (backendResponse.statusCode == 200) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          }
        } else {
          // Tratar erro do backend
          String errorText = 'Erro desconhecido do backend.';
          if (backendResponse.body != null && backendResponse.body.isNotEmpty) {
            errorText = 'Erro do backend: ${backendResponse.body}';
          }
          _showErrorDialog(errorText);
        }
      } else {
        _showErrorDialog("E-mail ou senha inválidos.");
      }
    } catch (e) {
      String message = "Erro ao fazer login. Tente novamente.";
      if (e.toString().contains('user-not-found') ||
          e.toString().contains('wrong-password')) {
        message = "E-mail ou senha inválidos.";
      } else if (e.toString().contains('too-many-requests')) {
        message = "Muitas tentativas de login. Tente novamente mais tarde.";
      }
      _showErrorDialog(message);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Função para Login com Google ---
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userCredential = await authService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        final firebaseIdToken = await user.getIdToken();
        final apiService = Provider.of<ApiService>(context, listen: false);

        // Chamar o backend para google-login
        final backendResponse = await apiService.post(
          '/google-login',
          headers: {"Authorization": "Bearer $firebaseIdToken"},
          body: {"name": user.displayName, "email": user.email},
        );

        if (backendResponse.statusCode == 200) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          }
        } else {
          String errorText =
              'Erro desconhecido do backend ao sincronizar Google.';
          if (backendResponse.body != null && backendResponse.body.isNotEmpty) {
            errorText = 'Erro do backend: ${backendResponse.body}';
          }
          _showErrorDialog(errorText);
          await authService
              .signOut(); // Deslogar do Firebase se o backend falhar
        }
      } else {
        // Usuário cancelou o login Google ou erro no Firebase
        _showErrorDialog("Login com Google cancelado ou falhou.");
      }
    } catch (e) {
      _showErrorDialog("Erro ao fazer login com Google: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Diálogo de Erro ---
  void _showErrorDialog(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
    });
    // Você pode usar um AlertDialog aqui, mas o seu Next.js usava um overlay,
    // então vou simular algo similar se você quiser.
    // Para um AlertDialog simples:
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Erro de Login"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text("Fechar"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _errorMessage = null; // Limpa o erro ao fechar
                  });
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor:
            Theme.of(context).primaryColor, // Use a cor primária do seu tema
      ),
      body: Stack(
        // Usamos Stack para o overlay de erro, como no seu Next.js
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
                    child: Text(
                      'Jubileu está esperando sua próxima tarefa!',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        // Você pode ajustar o tamanho da fonte e cor aqui
                      ),
                    ),
                  ),

                  // Imagem (se você tiver uma forma de carregar assets em Flutter)
                  // Certifique-se de adicionar 'assets/splash-pato.png' ao pubspec.yaml
                  Image.asset(
                    'assets/splash-pato.png', // Substitua pelo caminho correto do seu asset
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 48), // Espaçamento

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Campo de E-mail
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            hintText: 'seu@email.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu e-mail.';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return 'E-mail inválido.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Campo de Senha
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: 'sua senha',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira sua senha.';
                            }
                            if (value.length < 6) {
                              return 'A senha deve ter pelo menos 6 caracteres.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),

                        // Botão de Entrar
                        CustomButton(
                          buttonText: _isLoading ? 'Entrando...' : 'Entrar',
                          onClick:
                              _isLoading ? null : _signInWithEmailAndPassword,
                          // Desabilitar o botão enquanto está carregando
                          disabled: _isLoading,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botão de Login com Google
                  // Precisamos de um CustomButton para o Google, ou adaptar o existente
                  // Vou criar um botão simples por agora, você pode estilizar com seu ButtonGoogle
                  CustomButton(
                    buttonText: 'Login com Google',
                    primaryColor: Colors.blue, // Cor do Google
                    secondaryColor: Colors.blueAccent,
                    onClick: _isLoading ? null : _signInWithGoogle,
                    disabled: _isLoading,
                  ),
                  const SizedBox(height: 20),

                  // Link para Cadastrar-se
                  GestureDetector(
                    onTap:
                        _isLoading
                            ? null
                            : () {
                              Navigator.of(context).pushNamed('/register');
                            },
                    child: Text(
                      'cadastrar-se',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.secondary, // Cor secundária do tema
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Overlay para a mensagem de erro (similar ao que você tinha no Next.js)
          if (_errorMessage != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Material(
                    color:
                        Colors
                            .transparent, // Torna o Material transparente para o Card
                    child: Card(
                      margin: const EdgeInsets.all(24.0),
                      color: Theme.of(context).cardColor, // Cor do card do tema
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.red),
                            ),
                            const SizedBox(height: 20),
                            CustomButton(
                              buttonText: "Fechar",
                              onClick: () {
                                setState(() {
                                  _errorMessage = null;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _errorMessage =
                                      null; // Limpa o erro antes de navegar
                                });
                                Navigator.of(context).pushNamed('/register');
                              },
                              child: Text(
                                'cadastrar-se',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
