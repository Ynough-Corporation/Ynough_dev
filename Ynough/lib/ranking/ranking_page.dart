import 'package:flutter/material.dart';

import '../api/ynough_api.dart';
import '../navbar/navbar.dart';
import '../widgets/page_header.dart';
import 'widgets/ranking_hero.dart';
import 'widgets/ranking_list_card.dart';
import 'widgets/ranking_table_header.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late final Future<List<RankedTeam>> _rankingFuture;

  @override
  void initState() {
    super.initState();
    _rankingFuture = _loadRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 8, 24),
      color: ynoughCream,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Classement',
              subtitle: 'Classement general des equipes',
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<RankedTeam>>(
                future: _rankingFuture,
                builder: (context, snapshot) {
                  final ranking = snapshot.data ?? const <RankedTeam>[];
                  final podiumTeams = ranking.take(3).toList();

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _RankingLoadingState();
                  }

                  if (snapshot.hasError) {
                    return _RankingErrorState(error: '${snapshot.error}');
                  }

                  if (ranking.isEmpty) {
                    return const _RankingEmptyState();
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      RankingHero(topTeams: podiumTeams),
                      const SizedBox(height: 24),
                      RankingTableHeader(totalTeams: ranking.length),
                      const SizedBox(height: 14),
                      ...ranking.map(
                        (team) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: RankingListCard(team: team),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<RankedTeam>> _loadRanking() async {
    final api = YnoughApi();
    final results = await Future.wait<dynamic>([
      api.fetchTeams(),
      api.fetchMatches(),
    ]);

    final teams = results[0] as List<ApiTeam>;
    final matches = results[1] as List<ApiMatch>;
    final statsByTeamId = {
      for (final team in teams)
        team.id: _TeamStats(
          name: team.name,
          players: team.players,
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

    final sorted = statsByTeamId.values.toList()
      ..sort((left, right) {
        final pointsCompare = right.points.compareTo(left.points);
        if (pointsCompare != 0) {
          return pointsCompare;
        }
        final winsCompare = right.wins.compareTo(left.wins);
        if (winsCompare != 0) {
          return winsCompare;
        }
        return left.name.compareTo(right.name);
      });

    return [
      for (var index = 0; index < sorted.length; index++)
        RankedTeam(
          rank: index + 1,
          name: sorted[index].name,
          players: sorted[index].players,
          played: sorted[index].played,
          wins: sorted[index].wins,
          losses: sorted[index].losses,
          points: sorted[index].points,
        ),
    ];
  }
}

class RankedTeam {
  const RankedTeam({
    required this.rank,
    required this.name,
    required this.players,
    required this.played,
    required this.wins,
    required this.losses,
    required this.points,
  });

  final int rank;
  final String name;
  final List<String> players;
  final int played;
  final int wins;
  final int losses;
  final int points;
}

class _TeamStats {
  _TeamStats({
    required this.name,
    required this.players,
  });

  final String name;
  final List<String> players;
  int played = 0;
  int wins = 0;
  int losses = 0;
  int points = 0;
}

class _RankingLoadingState extends StatelessWidget {
  const _RankingLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _RankingErrorState extends StatelessWidget {
  const _RankingErrorState({
    required this.error,
  });

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Impossible de charger le classement.\n$error',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _RankingEmptyState extends StatelessWidget {
  const _RankingEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Aucune equipe disponible.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
