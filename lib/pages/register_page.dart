// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For json.encode

// Assuming you have these custom components
import 'package:mobile_megajr_grupo3/components/input.dart';
import 'package:mobile_megajr_grupo3/components/input_password.dart';
import 'package:mobile_megajr_grupo3/components/button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Function to show a SnackBar for success/error messages (like toast)
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Function to show a custom error dialog for email already exists
  void _showEmailExistsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.grey[900], // Dark background
          title: const Text(
            "Erro de Cadastro",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Este e-mail já está cadastrado.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              CustomButton(
                buttonText: "Fazer Login",
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(
                    context,
                  ).pushReplacementNamed('/login'); // Navigate to login
                },
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C2A84), // Your button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text(
                  "Fechar",
                  style: TextStyle(
                    color: Colors.white54,
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

  Future<void> _handleFormSubmit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      // Call your backend API to register the user
      final response = await http.post(
        Uri.parse(
          'https://megajr-back-end.onrender.com/cadastro',
        ), // Replace with your actual backend endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'senha':
              password,
        }),
      );

      if (response.statusCode == 409) {
        _showEmailExistsDialog();
        return; // Stop further processing
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Handle other non-success status codes
        _showSnackBar("Erro ao cadastrar. Tente novamente.", isError: true);
        print("Backend error: ${response.statusCode} - ${response.body}");
        return;
      }

      // If backend registration is successful, proceed with Firebase authentication
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showSnackBar("Cadastro realizado com sucesso!");
      Navigator.of(
        context,
      ).pushReplacementNamed('/dashboard'); // Navigate to dashboard
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        // This case might be caught by your backend (status 409) first,
        // but it's good to handle it here too for robustness.
        message = 'Este e-mail já está em uso.';
        _showEmailExistsDialog(); // Show specific dialog for this case
        return;
      } else if (e.code == 'invalid-email') {
        message = 'O formato do e-mail é inválido.';
      } else {
        message = 'Erro no Firebase: ${e.message}';
      }
      _showSnackBar(message, isError: true);
      print("Firebase Auth Error: ${e.code} - ${e.message}");
    } catch (error) {
      _showSnackBar(
        "Erro inesperado ao cadastrar. Tente novamente.",
        isError: true,
      );
      print("General Error during registration: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if all fields are filled to enable the button
    final bool areFieldsFilled =
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60), // Top padding
            const Text(
              "Organize suas tarefas com Jubitasks!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.black, // Or your app's primary text color
              ),
            ),
            const SizedBox(height: 80), // Gap
            Image.asset(
              'assets/splash-pato.png', // Make sure this asset is in your pubspec.yaml
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 80), // Gap

            Form(
              child: Column(
                children: [
                  CustomInput(
                    controller: _nameController,
                    labelText: "Nome",
                    hintText: "seu nome",
                    onChanged:
                        (value) => setState(
                          () {},
                        ), // Trigger rebuild to update button state
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _emailController,
                    labelText: "E-mail",
                    hintText: "seu@email.com",
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  CustomInputPassword(
                    controller: _passwordController,
                    labelText: "Senha",
                    hintText: "sua senha",
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 20), // Spacing before button
                  CustomButton(
                    buttonText: _isLoading ? "Cadastrando..." : "Cadastrar-se",
                    onPressed:
                        (areFieldsFilled && !_isLoading)
                            ? _handleFormSubmit
                            : null,
                    buttonStyle: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.grey;
                        }
                        return const Color(0xFF5C2A84);
                      }),
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
            const SizedBox(height: 20), // Spacing after register button
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login'); // Navigate to login
              },
              child: const Text(
                "login",
                style: TextStyle(
                  color: Color(0xFF676767),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
