enum MatchStatus {
  live,
  upcoming,
  finished,
}

class MatchItem {
  const MatchItem({
    required this.id,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homePlayers,
    required this.awayPlayers,
    required this.homeScore,
    required this.awayScore,
    required this.status,
  });

  final String id;
  final String homeTeamName;
  final String awayTeamName;
  final List<String> homePlayers;
  final List<String> awayPlayers;
  final int homeScore;
  final int awayScore;
  final MatchStatus status;
}
