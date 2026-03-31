import 'package:flutter/material.dart';

import '../api/ynough_api.dart';
import '../navbar/navbar.dart';
import '../widgets/page_header.dart';
import 'match_item.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final _api = YnoughApi();
  late Future<_MatchesViewData> _matchesFuture;
  MatchFilter _selectedFilter = MatchFilter.all;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _loadMatches();
  }

  Future<_MatchesViewData> _loadMatches() async {
    final results = await Future.wait<dynamic>([
      _api.fetchTeams(),
      _api.fetchMatches(),
    ]);

    final teams = results[0] as List<ApiTeam>;
    final matches = results[1] as List<ApiMatch>;
    final teamsById = {for (final team in teams) team.id: team};

    final items = matches
        .map((match) {
          final team1 = teamsById[match.team1Id];
          final team2 = teamsById[match.team2Id];
          if (team1 == null || team2 == null) {
            return null;
          }

          return MatchItem(
            id: match.id,
            homeTeamId: team1.id,
            awayTeamId: team2.id,
            homeTeamName: team1.name,
            awayTeamName: team2.name,
            homePlayers: team1.players,
            awayPlayers: team2.players,
            homeScore: match.team1Score,
            awayScore: match.team2Score,
            status: _toMatchStatus(match.status),
          );
        })
        .whereType<MatchItem>()
        .toList()
      ..sort((left, right) => right.id.compareTo(left.id));

    return _MatchesViewData(
      teams: teams,
      matches: items,
    );
  }

  Future<void> _refreshMatches() async {
    setState(() {
      _matchesFuture = _loadMatches();
    });
  }

  Future<void> _openCreateMatchDialog(List<ApiTeam> teams) async {
    int? team1Id;
    int? team2Id;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              if (_submitting || team1Id == null || team2Id == null || team1Id == team2Id) {
                return;
              }

              setDialogState(() {
                _submitting = true;
              });

              try {
                await _api.createMatch(
                  team1Id: team1Id!,
                  team2Id: team2Id!,
                  date: DateTime.now(),
                );
                if (!mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                await _refreshMatches();
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
              title: const Text('Nouveau match'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Equipe 1'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: team1Id,
                    items: teams
                        .map(
                          (team) => DropdownMenuItem<int>(
                            value: team.id,
                            child: Text(team.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        team1Id = value;
                        if (team1Id == team2Id) {
                          team2Id = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Equipe 2'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: team2Id,
                    items: teams
                        .where((team) => team.id != team1Id)
                        .map(
                          (team) => DropdownMenuItem<int>(
                            value: team.id,
                            child: Text(team.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        team2Id = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (team1Id == team2Id && team1Id != null)
                    const Text(
                      'Les deux equipes doivent etre differentes.',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _submitting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                FilledButton.icon(
                  onPressed: _submitting ? null : submit,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(_submitting ? 'Creation...' : 'Lancer le match'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateScore(MatchItem match, {required bool homeTeam, required int delta}) async {
    final nextHomeScore = homeTeam ? (match.homeScore + delta).clamp(0, 999) : match.homeScore;
    final nextAwayScore = homeTeam ? match.awayScore : (match.awayScore + delta).clamp(0, 999);

    try {
      await _api.updateMatchScore(
        matchId: match.id,
        team1Score: nextHomeScore,
        team2Score: nextAwayScore,
      );
      await _refreshMatches();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mise a jour du score impossible: $error')),
      );
    }
  }

  Future<void> _finishMatch(MatchItem match) async {
    try {
      await _api.updateMatchStatus(matchId: match.id, status: 'finished');
      await _refreshMatches();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fin du match impossible: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 8, 24),
      color: ynoughCream,
      child: SafeArea(
        top: false,
        child: FutureBuilder<_MatchesViewData>(
          future: _matchesFuture,
          builder: (context, snapshot) {
            final data = snapshot.data;
            final matches = data?.matches ?? const <MatchItem>[];
            final teams = data?.teams ?? const <ApiTeam>[];
            final filteredMatches = _selectedFilter.apply(matches);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Matchs',
                  subtitle: '${matches.length} matchs programmes',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: teams.length < 2 ? null : () => _openCreateMatchDialog(teams),
                    icon: const Icon(Icons.add),
                    label: const Text('Nouveau match'),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: MatchFilter.values.map((filter) {
                    final count = filter.apply(matches).length;
                    return ChoiceChip(
                      selected: _selectedFilter == filter,
                      label: Text('${filter.label} ($count)'),
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildBody(snapshot, filteredMatches),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    AsyncSnapshot<_MatchesViewData> snapshot,
    List<MatchItem> filteredMatches,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const _MatchesLoadingState();
    }

    if (snapshot.hasError) {
      return _MatchesErrorState(error: '${snapshot.error}');
    }

    if (filteredMatches.isEmpty) {
      return const _EmptyMatchesState();
    }

    return RefreshIndicator(
      onRefresh: _refreshMatches,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: _buildSections(context, filteredMatches),
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context, List<MatchItem> matches) {
    final liveMatches = matches.where((match) => match.status == MatchStatus.live).toList();
    final upcomingMatches =
        matches.where((match) => match.status == MatchStatus.upcoming).toList();
    final finishedMatches =
        matches.where((match) => match.status == MatchStatus.finished).toList();

    final sections = <Widget>[];

    void addSection(String title, List<MatchItem> data) {
      if (data.isEmpty) {
        return;
      }
      sections.add(_SectionTitle(title: title));
      sections.add(const SizedBox(height: 12));
      sections.addAll(
        data.map(
          (match) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MatchCard(
              match: match,
              onScoreChanged: match.status == MatchStatus.live
                  ? ({required bool homeTeam, required int delta}) =>
                      _updateScore(match, homeTeam: homeTeam, delta: delta)
                  : null,
              onFinish: match.status == MatchStatus.live ? () => _finishMatch(match) : null,
            ),
          ),
        ),
      );
    }

    if (_selectedFilter == MatchFilter.all) {
      addSection('En cours', liveMatches);
      addSection('A venir', upcomingMatches);
      addSection('Termines', finishedMatches);
      return sections;
    }

    addSection(_selectedFilter.sectionTitle, matches);
    return sections;
  }
}

enum MatchFilter {
  all('Tous', 'Tous'),
  live('En cours', 'En cours'),
  upcoming('A venir', 'A venir'),
  finished('Termines', 'Termines');

  const MatchFilter(this.label, this.sectionTitle);

  final String label;
  final String sectionTitle;

  List<MatchItem> apply(List<MatchItem> matches) {
    switch (this) {
      case MatchFilter.all:
        return matches;
      case MatchFilter.live:
        return matches.where((match) => match.status == MatchStatus.live).toList();
      case MatchFilter.upcoming:
        return matches.where((match) => match.status == MatchStatus.upcoming).toList();
      case MatchFilter.finished:
        return matches.where((match) => match.status == MatchStatus.finished).toList();
    }
  }
}

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    this.onScoreChanged,
    this.onFinish,
  });

  final MatchItem match;
  final void Function({required bool homeTeam, required int delta})? onScoreChanged;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusBadge(status: match.status),
            const SizedBox(height: 18),
            _TeamRow(
              teamName: match.homeTeamName,
              players: match.homePlayers,
              score: match.homeScore,
              editable: match.status == MatchStatus.live,
              onIncrement: onScoreChanged == null ? null : () => onScoreChanged!(homeTeam: true, delta: 1),
              onDecrement: onScoreChanged == null ? null : () => onScoreChanged!(homeTeam: true, delta: -1),
            ),
            const SizedBox(height: 14),
            _TeamRow(
              teamName: match.awayTeamName,
              players: match.awayPlayers,
              score: match.awayScore,
              editable: match.status == MatchStatus.live,
              onIncrement: onScoreChanged == null ? null : () => onScoreChanged!(homeTeam: false, delta: 1),
              onDecrement: onScoreChanged == null ? null : () => onScoreChanged!(homeTeam: false, delta: -1),
            ),
            if (match.status == MatchStatus.live) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onFinish,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B044),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Terminer le match'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.teamName,
    required this.players,
    required this.score,
    required this.editable,
    this.onIncrement,
    this.onDecrement,
  });

  final String teamName;
  final List<String> players;
  final int score;
  final bool editable;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teamName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ynoughBlack,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                players.isEmpty ? 'Joueurs non renseignes' : players.join(' & '),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ynoughBlack.withValues(alpha: 0.62),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        if (editable)
          Row(
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$score',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ynoughBlack,
                    ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          )
        else
          Text(
            '$score',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: ynoughBlack,
                ),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final MatchStatus status;

  @override
  Widget build(BuildContext context) {
    final (text, color, icon) = switch (status) {
      MatchStatus.live => ('En cours', const Color(0xFFFF3B30), Icons.play_arrow_outlined),
      MatchStatus.upcoming => ('A venir', const Color(0xFF8D99AE), Icons.schedule),
      MatchStatus.finished => ('Termine', const Color(0xFF3E5F44), Icons.check_circle_outline),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFFF3B30),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: ynoughBlack,
              ),
        ),
      ],
    );
  }
}

class _MatchesLoadingState extends StatelessWidget {
  const _MatchesLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _MatchesErrorState extends StatelessWidget {
  const _MatchesErrorState({
    required this.error,
  });

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Impossible de charger les matchs.\n$error',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EmptyMatchesState extends StatelessWidget {
  const _EmptyMatchesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Aucun match disponible.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _MatchesViewData {
  const _MatchesViewData({
    required this.teams,
    required this.matches,
  });

  final List<ApiTeam> teams;
  final List<MatchItem> matches;
}

MatchStatus _toMatchStatus(String status) {
  switch (status) {
    case 'in_progress':
      return MatchStatus.live;
    case 'finished':
      return MatchStatus.finished;
    case 'scheduled':
    case 'cancelled':
    default:
      return MatchStatus.upcoming;
  }
}
