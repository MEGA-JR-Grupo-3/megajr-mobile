// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_megajr_grupo3/components/input.dart'; // You'll need to create this file
import 'package:mobile_megajr_grupo3/components/input_password.dart'; // You'll need to create this file
import 'package:mobile_megajr_grupo3/components/button.dart'; // You'll need to create this file
import 'package:mobile_megajr_grupo3/components/google_login_button.dart'; // You'll need to create this file

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = "";
  bool _isLoading = false; // To show loading state

  // Function to check if the user exists in the backend database
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

      // Check if user exists in the backend
      final bool userExists = await checkIfUserExists(email);
      if (!userExists) {
        setState(() {
          _errorMessage = "Erro ao fazer login. Usuário não encontrado.";
          _isLoading = false;
        });
        return;
      }

      // If user exists, proceed with Firebase login
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // In Flutter, you don't typically store auth tokens in localStorage like web.
        // Firebase handles session management internally.
        // If you need the token for your backend, you can get it:
        // String? token = await userCredential.user!.getIdToken();
        // print('Firebase Auth Token: $token');

        // Navigate to dashboard
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
      } else {
        message = 'Erro ao fazer login. Verifique seu e-mail e senha.';
      }
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
      print("Erro de autenticação Firebase: ${e.code} - ${e.message}");
    } catch (error) {
      setState(() {
        _errorMessage = "Erro inesperado ao fazer login.";
        _isLoading = false;
      });
      print("Erro ao fazer login: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to handle Google login success (placeholder)
  Future<void> _handleGoogleLoginSuccess(User? user) async {
    if (user != null) {
      print("Login com Google Sucesso: ${user.displayName}");
      // You'll need to implement actual Google Sign-In for Flutter.
      // This is just a placeholder for the callback logic.

      // Example of sending user data to your backend after Google login
      final userName = user.displayName;
      final userEmail = user.email;

      try {
        final response = await http.post(
          Uri.parse("https://megajr-back-end.onrender.com/cadastro-google"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'name': userName, 'email': userEmail}),
        );

        if (response.statusCode == 200) {
          print("Dados do usuário do Google enviados ao backend com sucesso.");
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          print(
            "Erro na resposta do backend ao comunicar dados do Google: ${response.statusCode}",
          );
          // Still navigate to dashboard even if backend call fails,
          // as Firebase auth was successful. Handle backend errors gracefully.
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } catch (error) {
        print(
          "Erro ao fazer requisição para cadastro/verificação do Google (CATCH): $error",
        );
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
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
              const SizedBox(height: 60), // Add some top padding
              const Text(
                "Jubileu está esperando sua próxima tarefa!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black, // Or your app's primary text color
                ),
              ),
              const SizedBox(height: 80), // Gap between title and image/form
              // Image (PatoImg) - In Flutter, you use AssetImage or NetworkImage
              // For a local asset, make sure 'assets/splash-pato.png' is added to pubspec.yaml
              Image.asset(
                'assets/splash-pato.png', // Make sure this asset is in your pubspec.yaml
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 80), // Gap between image and form

              Form(
                child: Column(
                  children: [
                    CustomInput(
                      // Using CustomInput from your components
                      controller: _emailController,
                      labelText: "E-mail",
                      hintText: "seu@email.com",
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {}); // Rebuild to update button state
                      },
                    ),
                    const SizedBox(height: 16), // Spacing between inputs
                    CustomInputPassword(
                      // Using CustomInputPassword from your components
                      controller: _passwordController,
                      labelText: "Senha",
                      hintText: "sua senha",
                      onChanged: (value) {
                        setState(() {}); // Rebuild to update button state
                      },
                    ),
                    const SizedBox(height: 25), // Spacing before button
                    CustomButton(
                      // Using CustomButton from your components
                      buttonText: _isLoading ? "Entrando..." : "Entrar",
                      onPressed:
                          (_emailController.text.trim().isNotEmpty &&
                                  _passwordController.text.trim().isNotEmpty &&
                                  !_isLoading)
                              ? _handleFormSubmit
                              : null, // Disable button if fields are empty or loading
                      buttonStyle: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.grey; // Disabled color
                            }
                            return const Color(0xFF5C2A84); // Enabled color
                          },
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ), // Rounded corners
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
              const SizedBox(height: 20), // Spacing after email/password button
              GoogleLoginButton(
                // Using GoogleLoginButton from your components
                onSuccess: _handleGoogleLoginSuccess,
              ),
              const SizedBox(height: 20), // Spacing after Google button
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
