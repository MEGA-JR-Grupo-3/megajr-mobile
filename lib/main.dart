import 'package:flutter/material.dart';
import 'pages/initial_page.dart';

void main() {
  runApp(const JubiTasksApp());
}

class JubiTasksApp extends StatelessWidget {
  const JubiTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JubiTasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial'),
      home: const HomePage(),
    );
  }
}