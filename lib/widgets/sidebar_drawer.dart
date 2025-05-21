// widgets/sidebar_drawer.dart
import 'package:flutter/material.dart';

class SidebarDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;
  // Add other items or callbacks as needed e.g. settings, profile

  const SidebarDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // This is for a Drawer, which is typically used on smaller screens.
    // For larger screens, you might embed this content directly in a Row.
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white, // Or use an Image.asset for a profile picture
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                style: const TextStyle(fontSize: 40.0, color: Colors.deepPurple),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple, // Theme this to match your app
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Navigate to Dashboard (already there, or handle if different sections)
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Settings Screen
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Configurações (Não implementado)")));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}