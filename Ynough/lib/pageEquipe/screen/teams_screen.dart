import 'package:flutter/material.dart';

import '../../api/ynough_api.dart';
import '../widgets/team_card.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final _api = YnoughApi();
  final _teamNameController = TextEditingController();
  final _player1Controller = TextEditingController();
  final _player2Controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late Future<List<_TeamOverview>> _teamsFuture;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _teamsFuture = _loadTeams();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  Future<List<_TeamOverview>> _loadTeams() async {
    final results = await Future.wait<dynamic>([
      _api.fetchTeams(),
      _api.fetchMatches(),
    ]);

    final teams = results[0] as List<ApiTeam>;
    final matches = results[1] as List<ApiMatch>;
    final statsByTeamId = {
      for (final team in teams)
        team.id: _TeamStats(
          team: team,
        ),
    };

    for (final match in matches.where((match) => match.status == 'finished')) {
      final team1 = statsByTeamId[match.team1Id];
      final team2 = statsByTeamId[match.team2Id];
      if (team1 == null || team2 == null) {
        continue;
      }

      team1.played++;
      team2.played++;

      if (match.team1Score > match.team2Score) {
        team1.wins++;
        team1.points += 3;
        team2.losses++;
      } else if (match.team2Score > match.team1Score) {
        team2.wins++;
        team2.points += 3;
        team1.losses++;
      }
    }

    final overview = statsByTeamId.values
        .map(
          (stats) => _TeamOverview(
            id: stats.team.id,
            name: stats.team.name,
            members: stats.team.players.join(' & '),
            points: stats.points,
            wins: stats.wins,
            losses: stats.losses,
            played: stats.played,
          ),
        )
        .toList()
      ..sort((left, right) {
        final pointsCompare = right.points.compareTo(left.points);
        if (pointsCompare != 0) {
          return pointsCompare;
        }
        return left.name.compareTo(right.name);
      });

    return overview;
  }

  Future<void> _refreshTeams() async {
    setState(() {
      _teamsFuture = _loadTeams();
    });
  }

  Future<void> _openCreateTeamDialog() async {
    _teamNameController.clear();
    _player1Controller.clear();
    _player2Controller.clear();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              if (!(_formKey.currentState?.validate() ?? false) || _submitting) {
                return;
              }

              setDialogState(() {
                _submitting = true;
              });

              try {
                await _api.createTeam(
                  name: _teamNameController.text.trim(),
                  player1: _player1Controller.text.trim(),
                  player2: _player2Controller.text.trim(),
                );
                if (!mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                await _refreshTeams();
              } catch (error) {
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Creation impossible: $error')),
                );
              } finally {
                if (mounted) {
                  setDialogState(() {
                    _submitting = false;
                  });
                }
              }
            }

            return AlertDialog(
              title: const Text('Nouvelle equipe'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nom de l\'equipe'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _teamNameController,
                        decoration: InputDecoration(
                          hintText: 'Les Ynoughs',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom est obligatoire.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Membres de l\'equipe'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _player1Controller,
                        decoration: InputDecoration(
                          hintText: 'Joueur 1',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le premier joueur est obligatoire.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _player2Controller,
                        decoration: InputDecoration(
                          hintText: 'Joueur 2',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le second joueur est obligatoire.';
                          }
                          if (value.trim() == _player1Controller.text.trim()) {
                            return 'Les joueurs doivent etre differents.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _submitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: _submitting ? null : submit,
                  icon: const Icon(Icons.check),
                  label: Text(_submitting ? 'Creation...' : 'Creer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTeam(_TeamOverview team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'equipe'),
        content: Text('Supprimer ${team.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await _api.deleteTeam(team.id);
      await _refreshTeams();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suppression impossible: $error')),
      );
    }
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
                  'Aucune equipe enregistree pour le moment.',
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
        title: FutureBuilder<List<_TeamOverview>>(
          future: _teamsFuture,
          builder: (context, snapshot) {
            final count = snapshot.data?.length ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Equipes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$count equipes inscrites',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                label: const Text('Ajouter une equipe'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<_TeamOverview>>(
                future: _teamsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Impossible de charger les equipes.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final teams = snapshot.data ?? const <_TeamOverview>[];
                  if (teams.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshTeams,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: teams.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        return TeamsCard(
                          teamName: team.name,
                          teamMembers: team.members,
                          points: team.points,
                          wins: team.wins,
                          losses: team.losses,
                          played: team.played,
                          onDelete: () => _deleteTeam(team),
                        );
                      },
                    ),
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

class _TeamOverview {
  const _TeamOverview({
    required this.id,
    required this.name,
    required this.members,
    required this.points,
    required this.wins,
    required this.losses,
    required this.played,
  });

  final int id;
  final String name;
  final String members;
  final int points;
  final int wins;
  final int losses;
  final int played;
}

class _TeamStats {
  _TeamStats({
    required this.team,
  });

  final ApiTeam team;
  int points = 0;
  int wins = 0;
  int losses = 0;
  int played = 0;
}
