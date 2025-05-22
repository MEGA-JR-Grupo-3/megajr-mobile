// lib/widgets/team_member_card.dart
import 'package:flutter/material.dart';

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String? imageUrl; // <--- ADD THIS FIELD FOR THE IMAGE PATH

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    this.imageUrl, // <--- ADD THIS TO THE CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Remove default card margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container( // Container to create the circular border
              width: 100, // Adjust size as needed
              height: 100, // Adjust size as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6A1B9A), // Deep purple border color
                  width: 3,
                ),
              ),
              child: ClipOval( // ClipOval to ensure the image is perfectly circular
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.asset( // <--- Use Image.asset for local images
                        imageUrl!,
                        fit: BoxFit.cover, // Cover the circle
                        height: 100,
                        width: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person, // Placeholder icon if image fails
                            size: 60,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon( // Fallback icon if no image URL is provided
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              role,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}