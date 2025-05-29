// lib/widgets/custom_sidebar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:mobile_megajr_grupo3/services/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomSidebar extends StatefulWidget {
  const CustomSidebar({super.key});

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  // Simula os estados do React
  String? _userName;
  String? _creationDate;
  String _profilePhotoUrl = 'assets/default-avatar.png';
  bool _isLargeScreen = false;

  late StreamSubscription<User?> _authStateSubscription;

  final String _backendUrl = 'https://megajr-back-end.onrender.com/api';

  @override
  void initState() {
    super.initState();
    // Observar o estado de autenticação
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _updateUserData,
    );

    // Adiciona listener para redimensionamento da tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScreenSize();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkScreenSize();
  }

  void _checkScreenSize() {
    final newIsLargeScreen = MediaQuery.of(context).size.width >= 1024;
    if (newIsLargeScreen != _isLargeScreen) {
      setState(() {
        _isLargeScreen = newIsLargeScreen;
      });
      if (_isLargeScreen && !Scaffold.of(context).isDrawerOpen) {}
    }
  }

  Future<void> _updateUserData(User? user) async {
    if (user != null) {
      setState(() {
        _profilePhotoUrl = user.photoURL ?? 'assets/default-avatar.png';
      });

      // Busca dados do usuário no backend
      try {
        final idToken = await user.getIdToken();
        final response = await http.post(
          Uri.parse('$_backendUrl/user-data'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          if (data['name'] != null) {
            setState(() {
              _userName = data['name'];
            });
          } else {
            setState(() {
              _userName = user.displayName ?? "Usuário Anônimo";
            });
          }
        } else {
          setState(() {
            _userName = user.displayName ?? "Usuário Anônimo";
          });
        }
      } catch (error) {
        setState(() {
          _userName = user.displayName ?? "Usuário Anônimo";
        });
      }

      // Data de criação da conta
      final creationTime = user.metadata.creationTime;
      if (creationTime != null) {
        final formattedDate = DateFormat('dd/MM/yyyy').format(creationTime);
        setState(() {
          _creationDate = formattedDate;
        });
      }
    } else {
      setState(() {
        _userName = null;
        _creationDate = null;
        _profilePhotoUrl = 'assets/default-avatar.png';
      });
    }
  }

  void _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signOut();

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/initial');
      if (Scaffold.of(context).isDrawerOpen) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return; //
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao fazer logout: $error')));
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40.0),
        hoverColor: const Color(0xFF6200EE).withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;

    return Drawer(
      width: _isLargeScreen ? 320 : 280,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, secondaryColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(-5, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: secondaryColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.3,
                                  ), // shadow-xl
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              image: DecorationImage(
                                image:
                                    _profilePhotoUrl.startsWith('http')
                                        ? NetworkImage(_profilePhotoUrl)
                                            as ImageProvider
                                        : AssetImage(_profilePhotoUrl)
                                            as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_userName != null)
                                Text(
                                  _userName!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (_creationDate != null)
                                Text(
                                  'Conta criada em: $_creationDate',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      if (!_isLargeScreen)
                        IconButton(
                          icon: const Icon(FontAwesomeIcons.xmark, size: 20),
                          color: Colors.white70,
                          onPressed: () {
                            if (Scaffold.of(context).isDrawerOpen) {
                              Navigator.of(context).pop();
                            }
                          },
                          tooltip: 'Fechar Menu',
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              // flex-grow
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildMenuItem(
                    icon: FontAwesomeIcons.pencil,
                    text: 'Editar Perfil',
                    onTap: () {
                      Navigator.pushNamed(context, '/edit-profile');
                      if (!_isLargeScreen &&
                          Scaffold.of(context).isDrawerOpen) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.gear,
                    text: 'Configurações',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/jub-settings',
                      ); // Substitua pela rota real
                      if (!_isLargeScreen &&
                          Scaffold.of(context).isDrawerOpen) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.circleInfo,
                    text: 'Sobre Nós',
                    onTap: () {
                      Navigator.pushNamed(context, '/about-us');
                      if (!_isLargeScreen &&
                          Scaffold.of(context).isDrawerOpen) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  _buildMenuItem(
                    icon: FontAwesomeIcons.circleQuestion,
                    text: 'Central de Ajuda',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/help',
                      ); // Substitua pela rota real
                      if (!_isLargeScreen &&
                          Scaffold.of(context).isDrawerOpen) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
            // Botão de Logout
            Padding(
              padding: const EdgeInsets.only(
                bottom: 60.0,
                left: 24.0,
                right: 24.0,
              ),
              child: _buildMenuItem(
                icon: FontAwesomeIcons.rightFromBracket,
                text: 'Sair',
                onTap: _handleLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
