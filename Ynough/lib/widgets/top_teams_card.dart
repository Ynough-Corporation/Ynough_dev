import 'package:flutter/material.dart';

class TopTeamsCard extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> apiCall;

  const TopTeamsCard({
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
            "Top 3 des équipes",
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
                return const Text('Erreur lors du chargement du classement', style: TextStyle(color: Colors.red));
              }

              final teams = snapshot.data ?? [];

              if (teams.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      "Aucune équipe enregistrée pour le moment.",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }

              // Si la base contient des équipes, on les affiche
              return Column(
                children: List.generate(teams.length, (index) {
                  final team = teams[index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFF3E5F44), 
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Color(0xFFFFF7EB), 
                              fontSize: 14, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        
                        Expanded(
                          child: Text(
                            team['name'] ?? 'Inconnu',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                        ),
                        
                        Text(
                          "${team['score'] ?? 0} pts",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E5F44), 
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}