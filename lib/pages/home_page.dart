import 'package:flutter/material.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _index = 0;

  final List<Widget> _pages = [
    Container(), // Lista de tarefas
    Container(), // Em andamento
    Container(), // Concluídas
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5C2A84),
        child: const Icon(Icons.add, size: 40, color: Colors.white,),
        onPressed: () {},
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: const Color(0xFF5C2A84),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.hourglass_empty), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: ''),
        ],
      ),
    );
  }
}
