import 'package:flutter/material.dart';
import 'package:mobile_megajr_grupo3/widgets/team_member_card.dart';
import 'package:mobile_megajr_grupo3/widgets/project_detail_section.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  // Add 'imageUrl' field to each team member's data
  final List<Map<String, String>> _allTeamMembers = [
    {'name': 'Jean Flávio', 'role': 'Front-end developer', 'imageUrl': 'assets/jean_profile.png'},
    {'name': 'Jonathan Amaral', 'role': 'Mobile Developer', 'imageUrl': 'assets/jon_profile.png'},
    {'name': 'Edilson Enzo', 'role': 'Front-end Developer', 'imageUrl': 'assets/edilson_profile.png'},
    {'name': 'Lucas', 'role': 'Back-end Developer', 'imageUrl': 'assets/lucas_profile.png'},
    {'name': 'Lara Eridan', 'role': 'Back-end Developer', 'imageUrl': 'assets/lara_profile.png'},
    {'name': 'Nicolas', 'role': 'Designer Developer', 'imageUrl': 'assets/nicolas_profile.png'},
    // If a member doesn't have an image, you can set 'imageUrl': null or 'imageUrl': ''
  ];

  int _currentPageIndex = 0;
  final int _membersPerPage = 3;

  List<Map<String, String>> _getCurrentPageMembers() {
    final startIndex = _currentPageIndex * _membersPerPage;
    final endIndex = (startIndex + _membersPerPage).clamp(0, _allTeamMembers.length);
    return _allTeamMembers.sublist(startIndex, endIndex);
  }

  void _goToNextPage() {
    setState(() {
      if ((_currentPageIndex + 1) * _membersPerPage < _allTeamMembers.length) {
        _currentPageIndex++;
      }
    });
  }

  void _goToPreviousPage() {
    setState(() {
      if (_currentPageIndex > 0) {
        _currentPageIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPageMembers = _getCurrentPageMembers();
    final bool canGoNext = (_currentPageIndex + 1) * _membersPerPage < _allTeamMembers.length;
    final bool canGoBack = _currentPageIndex > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6), // Light background color
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // No shadow
        leading: IconButton( // Back arrow remains for general screen navigation
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: const Text(
          'Nome da equipe', // Or 'Sobre nós'
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // About Us Section
            _buildAboutUsSection(),
            const SizedBox(height: 30),

            // Navigation Row for Team Member Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Arrow Button
                _buildCircularIconButton(
                  icon: Icons.arrow_back,
                  onPressed: canGoBack ? _goToPreviousPage : null,
                  color: canGoBack ? Colors.deepPurple : Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(width: 10),

                // Team Member Cards (Expanded to take available space)
                Expanded(
                  child: Column(
                    children: currentPageMembers.map((member) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: TeamMemberCard(
                          name: member['name']!,
                          role: member['role']!,
                          imageUrl: member['imageUrl'], // <--- PASS THE IMAGE URL HERE
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),

                // Right Arrow Button
                _buildCircularIconButton(
                  icon: Icons.arrow_forward,
                  onPressed: canGoNext ? _goToNextPage : null,
                  color: canGoNext ? Colors.deepPurple : Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Project Description/Details Section
            const ProjectDetailSection(
              icon: Icons.push_pin,
              title: 'Descrição do Projeto',
              description: '[Adicione aqui a descrição do projeto de vocês]',
            ),
            const SizedBox(height: 20),
            const ProjectDetailSection(
              icon: Icons.lightbulb_outline,
              title: 'Desafio',
              description: '[Explique o objetivo proposto pela Mega]',
            ),
            const SizedBox(height: 20),
            const ProjectDetailSection(
              icon: Icons.build_outlined,
              title: 'Processo',
              description: '[Conte como foi a organização, ferramentas usadas, etc]',
            ),
            const SizedBox(height: 20),
            const ProjectDetailSection(
              icon: Icons.menu_book,
              title: 'Aprendizados e desafios individuais',
              description: '[Relate os aprendizados de cada membro, ou divida em subitens]',
            ),
            const SizedBox(height: 20),
            const ProjectDetailSection(
              icon: Icons.self_improvement,
              title: 'Agradecimento',
              description: '[Mensagem final de agradecimento à Mega e à equipe]',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper method to build the icon buttons without a circular container
  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 28),
      onPressed: onPressed,
      splashRadius: 24,
    );
  }

  Widget _buildAboutUsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/patodeoculos.png',
          height: 150,
          width: 150,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              width: 150,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.red),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Olá, parceiro',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Sobre nós',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'O que acontece quando 6 programadores, motivados pelo Mega P.S., se juntam para encarar esse desafio?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}