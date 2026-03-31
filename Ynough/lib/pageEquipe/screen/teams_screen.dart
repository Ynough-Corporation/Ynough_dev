import 'package:flutter/material.dart';
import 'package:ynough/pageEquipe/widgets/team_card.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final teamNameController = TextEditingController();
  final player1Controller = TextEditingController();
  final player2Controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> teamsList = [
    {
      'teamName': 'Les Invincibles',
      'teamMembers': 'Thomas & Sophie',
      'points': 100,
    },
    {
      'teamName': 'Fire Squad',
      'teamMembers': 'Lucas & Emma',
      'points': 12,
    },
  ];

  @override
  void dispose() {
    teamNameController.dispose();
    player1Controller.dispose();
    player2Controller.dispose();
    super.dispose();
  }

  Future<void> _openCreateTeamDialog() async {
    teamNameController.clear();
    player1Controller.clear();
    player2Controller.clear();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Nouvelle équipe'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nom de l\'équipe'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: teamNameController,
                    decoration: InputDecoration(
                      hintText: 'Les Ynoughs',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Membres de l\'équipe'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: player1Controller,
                    decoration: InputDecoration(
                      hintText: 'Joueur 1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: player2Controller,
                    decoration: InputDecoration(
                      hintText: 'Joueur 2',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? false)) {
                  return;
                }

                setState(() {
                  teamsList.add({
                    'teamName': teamNameController.text.trim(),
                    'teamMembers':
                        '${player1Controller.text.trim()} & ${player2Controller.text.trim()}',
                    'points': 0,
                  });
                });

                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check),
              label: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          elevation: 0,
          color: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Padding(
            padding: EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups, size: 72, color: Color(0xFFFFF7EB)),
                SizedBox(height: 20),
                Text(
                  'Equipes inscrites, leur nombre de victoires et de defaites, bouton ajouter une equipe',
                  style: TextStyle(color: Color(0xE6FFF7EB)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Équipes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${teamsList.length} équipes inscrites',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                onPressed: _openCreateTeamDialog,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une équipe'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: teamsList.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      itemCount: teamsList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final team = teamsList[index];
                        return TeamsCard(
                          teamName: team['teamName'],
                          teamMembers: team['teamMembers'],
                          points: team['points'],
                          onDelete: () {
                            setState(() {
                              teamsList.remove(team);
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: _openCreateTeamDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
