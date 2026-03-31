import 'package:flutter/material.dart';

class TeamsCard extends StatelessWidget {
  final String teamName;
  final String teamMembers;
  final int points;
  final int victories;
  final int defeats;
  final int difference;
  final double winRate;
  final VoidCallback onDelete;

  const TeamsCard({
    super.key,
    required this.teamName,
    required this.teamMembers,
    required this.points,
    required this.victories,
    required this.defeats,
    required this.difference,
    required this.winRate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(teamName), Text(teamMembers)],
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete, color: Colors.red, size: 24),
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Points'),
                ],
              ),
              Column(
                children: [
                  Text(
                    victories.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('V'),
                ],
              ),
              Column(
                children: [
                  Text(
                    defeats.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('D'),
                ],
              ),
              Column(
                children: [
                  Text(
                    difference.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Diff'),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Taux de victoire'),
                  Text('${(winRate * 100).toInt()}%'),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: winRate,
                color: const Color.fromARGB(255, 13, 43, 235),
                backgroundColor: Color(0xFFE0E0E0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
