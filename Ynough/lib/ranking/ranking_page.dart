import 'package:flutter/material.dart';

import '../navbar/navbar.dart';
import '../widgets/page_header.dart';
import 'widgets/ranking_hero.dart';
import 'widgets/ranking_list_card.dart';
import 'widgets/ranking_table_header.dart';

const List<RankedTeam> _mockRanking = [
  RankedTeam(
    rank: 1,
    name: 'Les Champions',
    players: ['Alex', 'Marie'],
    played: 8,
    wins: 7,
    losses: 1,
    points: 21,
  ),
  RankedTeam(
    rank: 2,
    name: 'Thunder Team',
    players: ['Hugo', 'Lea'],
    played: 8,
    wins: 6,
    losses: 2,
    points: 18,
  ),
  RankedTeam(
    rank: 3,
    name: 'Night Hawks',
    players: ['Chloe', 'Nolan'],
    played: 8,
    wins: 5,
    losses: 3,
    points: 15,
  ),
  RankedTeam(
    rank: 4,
    name: 'Blue Falcons',
    players: ['Ines', 'Yanis'],
    played: 8,
    wins: 4,
    losses: 4,
    points: 12,
  ),
  RankedTeam(
    rank: 5,
    name: 'Golden Set',
    players: ['Sarah', 'Amine'],
    played: 8,
    wins: 3,
    losses: 5,
    points: 9,
  ),
  RankedTeam(
    rank: 6,
    name: 'Fire Squad',
    players: ['Lucas', 'Emma'],
    played: 8,
    wins: 2,
    losses: 6,
    points: 6,
  ),
  RankedTeam(
    rank: 7,
    name: 'Red Storm',
    players: ['Mila', 'Ethan'],
    played: 8,
    wins: 1,
    losses: 7,
    points: 3,
  ),
];

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final podiumTeams = _mockRanking.take(3).toList();

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
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  RankingHero(topTeams: podiumTeams),
                  const SizedBox(height: 24),
                  RankingTableHeader(totalTeams: _mockRanking.length),
                  const SizedBox(height: 14),
                  ..._mockRanking.map(
                    (team) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: RankingListCard(team: team),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
