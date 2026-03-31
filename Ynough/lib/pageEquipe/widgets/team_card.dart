import 'package:flutter/material.dart';

class TeamsCard extends StatelessWidget {
  final String teamName;
  final String teamMembers;
  final int points;
  final VoidCallback onDelete;

  const TeamsCard({
    super.key,
    required this.teamName,
    required this.teamMembers,
    required this.points,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teamName),
                  Text(teamMembers),
                ],
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.red, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    points.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('Points'),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'En attente',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('Victoires'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}