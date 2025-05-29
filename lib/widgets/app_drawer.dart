// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_megajr_grupo3/providers/auth_provider.dart'; // Use seu AuthProvider

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  // Prioriza registeredName, depois displayName, depois email
                  authProvider.registeredName.isNotEmpty
                      ? authProvider.registeredName
                      : authProvider.user?.displayName ??
                          authProvider.user?.email ??
                          'Usuário',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  authProvider.user?.email ??
                      '', // Alterado de currentUser para user
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              Navigator.of(
                context,
              ).pushReplacementNamed('/dashboard'); // Navega para o dashboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.group), // Ícone para "Team"
            title: const Text('Minha Equipe'),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              Navigator.of(
                context,
              ).pushNamed('/team'); // Navega para a tela de equipe
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Página de Configurações em breve!'),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              Navigator.pop(context); // Fecha o drawer
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushReplacementNamed('/'); // Redireciona para a rota inicial
              }
            },
          ),
        ],
      ),
    );
  }
}
