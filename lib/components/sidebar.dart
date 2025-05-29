import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart'; // For toast messages

import '../providers/auth_provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return PopupMenuButton<String>(
      // The icon that triggers the menu (e.g., a hamburger menu icon)
      icon: const Icon(Icons.menu),
      // Callback when an item is selected from the menu
      onSelected: (String result) async {
        switch (result) {
          case 'dashboard':
            // Navigate to the dashboard page using go_router
            context.go('/dashboard');
            break;
          case 'team':
            // Navigate to the team page using go_router
            context.go('/team');
            break;
          case 'profile':
            // Example: Navigate to a profile page
            // You'll need to create this page and route.
            // context.go('/profile');
            Fluttertoast.showToast(
              msg: 'Ir para Perfil (Ainda não implementado)',
            );
            break;
          case 'settings':
            // Example: Navigate to a settings page
            // You'll need to create this page and route.
            // context.go('/settings');
            Fluttertoast.showToast(
              msg: 'Ir para Configurações (Ainda não implementado)',
            );
            break;
          case 'notifications':
            // Example: Show a dialog for notification controls
            // You'll need to implement NotificationControlDialog if it's a separate component.
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                // Assuming you have a NotificationControlDialog widget
                // import '../widgets/notification_control_dialog.dart';
                // return const NotificationControlDialog();
                return AlertDialog(
                  title: const Text('Controle de Notificações'),
                  content: const Text('Configurações de notificação aqui...'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Fechar'),
                    ),
                  ],
                );
              },
            );
            break;
          case 'logout':
            // Perform logout
            await authProvider.signOut();
            // Show a toast message for logout confirmation
            Fluttertoast.showToast(msg: 'Logout realizado com sucesso!');
            // The AuthProvider's listener will automatically redirect to '/' via go_router's redirect logic
            break;
          default:
            // Handle any other cases or unexpected selections
            Fluttertoast.showToast(msg: 'Opção não reconhecida: $result');
            break;
        }
      },
      // Defines the items that appear in the popup menu
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'dashboard',
              child: ListTile(
                leading: const Icon(
                  Icons.dashboard,
                  color: Colors.blueAccent,
                ), // Example icon and color
                title: Text(
                  'Dashboard',
                  style:
                      Theme.of(
                        context,
                      ).textTheme.bodyLarge, // Use theme text style
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'team',
              child: ListTile(
                leading: const Icon(Icons.people, color: Colors.green),
                title: Text(
                  'Time',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const PopupMenuDivider(), // A visual divider
            PopupMenuItem<String>(
              value: 'profile',
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.grey),
                title: Text(
                  'Meu Perfil',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'settings',
              child: ListTile(
                leading: const Icon(Icons.settings, color: Colors.grey),
                title: Text(
                  'Configurações',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'notifications',
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.grey),
                title: Text(
                  'Controle de Notificações',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ), // Distinct color for logout
                title: Text(
                  'Sair',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.red,
                  ), // Highlight logout text
                ),
              ),
            ),
          ],
      // Optional: Add tooltip for accessibility
      tooltip: 'Abrir menu de navegação',
      // Optional: Customize the shape of the menu
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // Optional: Customize the elevation
      elevation: 8,
    );
  }
}
