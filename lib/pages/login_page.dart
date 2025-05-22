// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_megajr_grupo3/components/input.dart';
import 'package:mobile_megajr_grupo3/components/input_password.dart';
import 'package:mobile_megajr_grupo3/components/button.dart';
import 'package:mobile_megajr_grupo3/components/google_login_button.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = "";
  bool _isLoading = false;
  final AuthService _authService = AuthService(); // Instancie o AuthService

  Future<bool> checkIfUserExists(String email) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://megajr-back-end.onrender.com/check-user?email=$email',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] ?? false;
      } else {
        return false;
      }
    } catch (error) {
      print("Erro ao verificar se usuário existe no backend: $error");
      return false;
    }
  }

  // Function to handle email/password login
  Future<void> _handleFormSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });

    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final bool userExists = await checkIfUserExists(email);
      if (!userExists) {
        setState(() {
          _errorMessage = "Erro ao fazer login. Usuário não encontrado.";
          _isLoading = false;
        });
        return;
      }

      // If user exists, proceed with Firebase login
      UserCredential userCredential = await _authService
          .signInWithEmailAndPassword(email, password);

      if (userCredential.user != null) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Nenhum usuário encontrado para esse e-mail.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta fornecida para esse usuário.';
      } else if (e.code == 'invalid-email') {
        message = 'O formato do e-mail é inválido.';
      } else if (e.code == 'too-many-requests') {
        message = 'Muitas tentativas de login. Tente novamente mais tarde.';
      } else {
        message = 'Erro ao fazer login. Verifique seu e-mail e senha.';
      }
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = "Erro inesperado ao fazer login.";
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para lidar com o resultado do login com Google (sucesso ou falha)
  Future<void> _handleGoogleLoginResult(User? user, Object? error) async {
    if (user != null) {
      setState(() {
        _isLoading = true; // Mostra loading enquanto envia para o backend
      });
      print("Login com Google Sucesso: ${user.displayName} (${user.email})");

      final userName = user.displayName;
      final userEmail = user.email;

      try {
        final response = await http.post(
          Uri.parse("https://megajr-back-end.onrender.com/cadastro-google"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'name': userName, 'email': userEmail}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 200 OK ou 201 Created
          print("Dados do usuário do Google enviados ao backend com sucesso.");
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          // O login Firebase foi bem-sucedido, mas o backend teve um problema.
          // Decide se navega ou mostra um aviso.
          print(
            "Erro na resposta do backend ao comunicar dados do Google: ${response.statusCode} - ${response.body}",
          );
          // Opcional: mostrar um aviso ao usuário sobre o erro no backend, mas ainda navegar.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Login bem-sucedido, mas houve um problema com nosso serviço.',
              ),
            ),
          );
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } catch (e) {
        print(
          "Erro ao fazer requisição para cadastro/verificação do Google (CATCH): $e",
        );
        // Opcional: mostrar um aviso ao usuário
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login bem-sucedido, mas houve um problema de comunicação.',
            ),
          ),
        );
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Usuário nulo ou houve um erro no login do Google no GoogleLoginButton
      print("Erro ou cancelamento do login com Google: $error");
      setState(() {
        _errorMessage =
            error.toString(); // Exibe o erro do callback do GoogleLoginButton
        _isLoading = false;
      });
    }
  }

  // Function to show a custom error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(
            0xFF2C2C2C,
          ), // Dark background for the dialog
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  setState(() {
                    _errorMessage = ""; // Clear the error message
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C2A84), // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  "Fechar",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(
                    context,
                  ).pushNamed('/register'); // Navigate to register
                },
                child: const Text(
                  "cadastrar-se",
                  style: TextStyle(
                    color: Color(0xFF676767),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error dialog if _errorMessage is not empty
    if (_errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(_errorMessage);
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Jubileu está esperando sua próxima tarefa!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 80),
              Image.asset(
                'assets/splash-pato.png',
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 80),

              Form(
                child: Column(
                  children: [
                    CustomInput(
                      controller: _emailController,
                      labelText: "E-mail",
                      hintText: "seu@email.com",
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomInputPassword(
                      controller: _passwordController,
                      labelText: "Senha",
                      hintText: "sua senha",
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 25),
                    CustomButton(
                      buttonText: _isLoading ? "Entrando..." : "Entrar",
                      onPressed:
                          (_emailController.text.trim().isNotEmpty &&
                                  _passwordController.text.trim().isNotEmpty &&
                                  !_isLoading)
                              ? _handleFormSubmit
                              : null,
                      buttonStyle: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.grey;
                            }
                            return const Color(0xFF5C2A84);
                          },
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GoogleLoginButton(
                onSuccess: (user) {
                  // Passa o usuário para a função de tratamento de resultado
                  _handleGoogleLoginResult(user, null);
                },
                onError: (error) {
                  // Passa o erro para a função de tratamento de resultado
                  _handleGoogleLoginResult(null, error);
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: const Text(
                  "cadastrar-se",
                  style: TextStyle(
                    color: Color(0xFF676767),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
