// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showEmailExistsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.grey[900],
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
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C2A84),
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
                  Navigator.of(context).pop();
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

      // PASSO 1: CADASTRAR NO FIREBASE AUTHENTICATION
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // PASSO 2: SE O FIREBASE FOR BEM-SUCEDIDO, PEGAR O ID TOKEN
      String? firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception("Não foi possível obter o ID Token do Firebase.");
      }

      // PASSO 3: ENVIAR PARA O SEU BACKEND COM O TOKEN
      final response = await http.post(
        Uri.parse('https://megajr-back-end.onrender.com/api/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $firebaseIdToken',
        },
        body: jsonEncode(<String, String>{'name': name, 'email': email}),
      );

      if (response.statusCode == 409) {
        _showEmailExistsDialog();
        // Opcional: Se o usuário foi criado no Firebase mas já existe no backend,
        // você pode querer deletar o usuário do Firebase aqui para manter a consistência,
        // ou ajustar a lógica do backend para lidar com isso.
        // await userCredential.user?.delete();
        return;
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        _showSnackBar("Erro ao cadastrar. Tente novamente.", isError: true);
        print("Backend error: ${response.statusCode} - ${response.body}");
        return;
      }

      _showSnackBar("Cadastro realizado com sucesso!");
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está em uso.';
        _showEmailExistsDialog();
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 60),
            const Text(
              "Organize suas tarefas com Jubitasks!",
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
                    controller: _nameController,
                    labelText: "Nome",
                    hintText: "seu nome",
                    onChanged: (value) => setState(() {}),
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
                  const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
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
