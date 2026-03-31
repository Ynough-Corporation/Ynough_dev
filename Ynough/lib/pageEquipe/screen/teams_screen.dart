import 'package:flutter/material.dart';
import 'package:ynough/pageEquipe/widgets/team_card.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key}); // Le constructeur redevient propre et vide

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final teamNameController = TextEditingController();
  final player1Controller = TextEditingController();
  final player2Controller = TextEditingController();

  List<Map<String, dynamic>> teamsList = [
    {
      'teamName': 'Les Invincibles',
      'teamMembers': 'Thomas & Sophie',
      'points': 100,
      'victories': 2,
      'defeats': 2,
      'difference': 0,
      'winRate': 0.50,
    },
    {
      'teamName': 'Fire Squad',
      'teamMembers': 'Lucas & Emma',
      'points': 12,
      'victories': 4,
      'defeats': 0,
      'difference': 20,
      'winRate': 1.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 13, 43, 235), 
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            centerTitle: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Équipes', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${teamsList.length} équipes inscrites',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
      body: 
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            // Prend toute la largeur disponible pour le bouton.
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:  const Color.fromARGB(255, 13, 43, 235),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Nouvelle équipe'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Nom de l\'équipe'),
                          SizedBox(height: 8),
                          TextField(
                            controller: teamNameController,
                            decoration: InputDecoration(
                              labelText: 'Nom de l\'équipe',
                              hintText: 'Les Ynoughs',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Membres de l\'équipe'),
                          SizedBox(height: 8),
                          TextField(
                            controller: player1Controller,
                            decoration: InputDecoration(
                              labelText: 'Membres de l\'équipe',
                              hintText: 'Joueur 1',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: player2Controller,
                            decoration: InputDecoration(
                              labelText: 'Membres de l\'équipe',
                              hintText: 'Joueur 2',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                if (teamNameController.text.isEmpty) return;

                                setState(() {
                                  teamsList.add({
                                    'teamName': teamNameController.text,
                                    'teamMembers': '${player1Controller.text} & ${player2Controller.text}',
                                    'points': 0, // Une nouvelle équipe commence avec 0 partout
                                    'victories': 0,
                                    'defeats': 0,
                                    'difference': 0,
                                    'winRate': 0.0,
                                  });
                                });

                                // 3. On vide les champs pour la prochaine fois
                                teamNameController.clear();
                                player1Controller.clear();
                                player2Controller.clear();

                                // 4. On ferme violemment la modale
                                Navigator.of(context).pop();
                              },
                              child: const Text('Créer l\'équipe'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },

              icon: const Icon(Icons.add),
              label: const Text('Ajouter une équipe'),
            ),
          ),
          // generee directement dans la Column.
          ...teamsList.map((team) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
              ), // Espace au-dessus de chaque carte
              child: TeamsCard(
                teamName: team['teamName'],
                teamMembers: team['teamMembers'],
                points: team['points'],
                victories: team['victories'],
                defeats: team['defeats'],
                difference: team['difference'],
                winRate: team['winRate'],
                onDelete: () {
                  setState(() {
                    teamsList.remove(team);
                  });
                },
              ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Bouton ajouté !');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Équipes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Matchs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Classement',
          ),
        ],
      ),
    );
  }
}
