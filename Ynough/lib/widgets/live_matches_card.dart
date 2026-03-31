import 'package:flutter/material.dart';

class LiveMatchesCard extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> apiCall;

  const LiveMatchesCard({
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
          // Point rouge du live
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Matchs en direct",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ],
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
                return const Text('Erreur de chargement', style: TextStyle(color: Colors.red));
              }

              final matches = snapshot.data ?? [];

              // Si aucun match en cours
              if (matches.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      "Aucun match en direct pour le moment.",
                      style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

              // Liste des matchs en cours
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
                        // Score au centre
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3E5F44).withOpacity(0.1), 
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${match['scoreA'] ?? 0} - ${match['scoreB'] ?? 0}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: Color(0xFF3E5F44), // Ton vert
                                fontSize: 16
                              ),
                            ),
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