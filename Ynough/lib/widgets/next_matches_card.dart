import 'package:flutter/material.dart';

class NextMatchesCard extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> apiCall;

  const NextMatchesCard({
    super.key,
    required this.apiCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Matchs à venir",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A0A0A),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: apiCall,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF3E5F44)),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Text('Erreur lors du chargement des matchs', style: TextStyle(color: Colors.red));
              }

              final matches = snapshot.data ?? [];

              if (matches.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      "Aucun match prévu.",
                      style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

              return Column(
                children: matches.map((match) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Équipe A
                        Expanded(
                          child: Text(
                            match['teamA'] ?? 'Équipe A',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0A0A0A)),
                          ),
                        ),
                        // Séparateur VS et Date
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              const Text(
                                "VS",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E5F44), fontSize: 12),
                              ),
                              Text(
                                match['date'] ?? '',
                                style: TextStyle(color: Colors.grey[600], fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        // Équipe B
                        Expanded(
                          child: Text(
                            match['teamB'] ?? 'Équipe B',
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0A0A0A)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}