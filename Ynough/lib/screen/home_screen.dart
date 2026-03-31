import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../api/ynough_api.dart';
import '../widgets/live_matches_card.dart';
import '../widgets/next_matches_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_teams_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<_HomeData> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _loadHomeData();
  }

  Future<_HomeData> _loadHomeData() async {
    final api = YnoughApi();
    final results = await Future.wait<dynamic>([
      api.fetchTeams(),
      api.fetchMatches(),
    ]);

    final teams = results[0] as List<ApiTeam>;
    final matches = results[1] as List<ApiMatch>;
    final teamsById = {for (final team in teams) team.id: team};
    final statsByTeamId = {
      for (final team in teams) team.id: _TeamStats(team: team),
    };

    for (final match in matches.where((match) => match.status == 'finished')) {
      final team1 = statsByTeamId[match.team1Id];
      final team2 = statsByTeamId[match.team2Id];
      if (team1 == null || team2 == null) {
        continue;
      }

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

    final topTeams = statsByTeamId.values
        .map(
          (stats) => {
            'name': stats.team.name,
            'score': stats.points,
          },
        )
        .toList()
      ..sort((left, right) {
        final pointsCompare = (right['score'] as int).compareTo(left['score'] as int);
        if (pointsCompare != 0) {
          return pointsCompare;
        }
        return (left['name'] as String).compareTo(right['name'] as String);
      });

    final liveMatches = matches
        .where((match) => match.status == 'in_progress')
        .map(
          (match) => {
            'teamA': teamsById[match.team1Id]?.name ?? 'Equipe inconnue',
            'teamB': teamsById[match.team2Id]?.name ?? 'Equipe inconnue',
            'scoreA': match.team1Score,
            'scoreB': match.team2Score,
          },
        )
        .toList(growable: false);

    final nextMatches = matches
        .where((match) => match.status == 'scheduled')
        .toList()
      ..sort((left, right) {
        final leftDate = left.date ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightDate = right.date ?? DateTime.fromMillisecondsSinceEpoch(0);
        return leftDate.compareTo(rightDate);
      });

    return _HomeData(
      teamsCount: teams.length.toString(),
      matchesCount: matches.length.toString(),
      liveCount: liveMatches.length.toString(),
      liveMatches: liveMatches,
      topTeams: topTeams.take(3).toList(growable: false),
      nextMatches: nextMatches
          .take(3)
          .map(
            (match) => {
              'teamA': teamsById[match.team1Id]?.name ?? 'Equipe inconnue',
              'teamB': teamsById[match.team2Id]?.name ?? 'Equipe inconnue',
              'date': _formatMatchDate(match.date),
            },
          )
          .toList(growable: false),
    );
  }

  Future<String> getTeamsCount() async => (await _homeDataFuture).teamsCount;

  Future<String> getMatchesCount() async => (await _homeDataFuture).matchesCount;

  Future<String> getLiveCount() async => (await _homeDataFuture).liveCount;

  Future<List<Map<String, dynamic>>> getLiveMatches() async => (await _homeDataFuture).liveMatches;

  Future<List<Map<String, dynamic>>> getLeaderboard() async => (await _homeDataFuture).topTeams;

  Future<List<Map<String, dynamic>>> getNextMatches() async => (await _homeDataFuture).nextMatches;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E5F44),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(
            'images/Logo-transparent.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        title: const Text(
          'YNOUGH BABYFOOT',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: StatCard(title: 'Equipes', apiCall: getTeamsCount())),
                const SizedBox(width: 10),
                Expanded(child: StatCard(title: 'Matchs', apiCall: getMatchesCount())),
                const SizedBox(width: 10),
                Expanded(child: StatCard(title: 'En cours', apiCall: getLiveCount())),
              ],
            ),
            const SizedBox(height: 24),
            LiveMatchesCard(apiCall: getLiveMatches()),
            const SizedBox(height: 24),
            TopTeamsCard(apiCall: getLeaderboard()),
            const SizedBox(height: 24),
            NextMatchesCard(apiCall: getNextMatches()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

String _formatMatchDate(DateTime? date) {
  if (date == null) {
    return '';
  }

  final twoDigitsDay = date.day.toString().padLeft(2, '0');
  final twoDigitsMonth = date.month.toString().padLeft(2, '0');
  final twoDigitsHour = date.hour.toString().padLeft(2, '0');
  final twoDigitsMinute = date.minute.toString().padLeft(2, '0');
  return '$twoDigitsDay/$twoDigitsMonth ${twoDigitsHour}h$twoDigitsMinute';
}

class _HomeData {
  const _HomeData({
    required this.teamsCount,
    required this.matchesCount,
    required this.liveCount,
    required this.liveMatches,
    required this.topTeams,
    required this.nextMatches,
  });

  final String teamsCount;
  final String matchesCount;
  final String liveCount;
  final List<Map<String, dynamic>> liveMatches;
  final List<Map<String, dynamic>> topTeams;
  final List<Map<String, dynamic>> nextMatches;
}

class _TeamStats {
  _TeamStats({
    required this.team,
  });

  final ApiTeam team;
  int wins = 0;
  int losses = 0;
  int points = 0;
}
