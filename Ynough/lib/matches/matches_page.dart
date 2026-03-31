import 'package:flutter/material.dart';

import 'match_item.dart';
import '../navbar/navbar.dart';
import '../widgets/page_header.dart';

const List<MatchItem> _mockMatches = [
  MatchItem(
    id: '1',
    homeTeamName: 'Les Champions',
    awayTeamName: 'Fire Squad',
    homePlayers: ['Alex', 'Marie'],
    awayPlayers: ['Lucas', 'Emma'],
    homeScore: 9,
    awayScore: 8,
    status: MatchStatus.live,
  ),
  MatchItem(
    id: '2',
    homeTeamName: 'Les Rookies',
    awayTeamName: 'Les Invincibles',
    homePlayers: ['Pierre', 'Julie'],
    awayPlayers: ['Thomas', 'Sophie'],
    homeScore: 0,
    awayScore: 0,
    status: MatchStatus.upcoming,
  ),
  MatchItem(
    id: '3',
    homeTeamName: 'Power Smash',
    awayTeamName: 'Thunder Team',
    homePlayers: ['Noah', 'Lina'],
    awayPlayers: ['Hugo', 'Lea'],
    homeScore: 11,
    awayScore: 6,
    status: MatchStatus.finished,
  ),
  MatchItem(
    id: '4',
    homeTeamName: 'Blue Falcons',
    awayTeamName: 'Red Storm',
    homePlayers: ['Ines', 'Yanis'],
    awayPlayers: ['Mila', 'Ethan'],
    homeScore: 7,
    awayScore: 10,
    status: MatchStatus.finished,
  ),
  MatchItem(
    id: '5',
    homeTeamName: 'Golden Set',
    awayTeamName: 'Night Hawks',
    homePlayers: ['Sarah', 'Amine'],
    awayPlayers: ['Chloe', 'Nolan'],
    homeScore: 4,
    awayScore: 2,
    status: MatchStatus.finished,
  ),
];

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  MatchFilter _selectedFilter = MatchFilter.all;

  @override
  Widget build(BuildContext context) {
    final matches = _mockMatches;
    final filteredMatches = _selectedFilter.apply(matches);

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
              title: 'Matchs',
              subtitle: '${matches.length} matchs programmés',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: null,
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
              child: filteredMatches.isEmpty
                  ? const _EmptyMatchesState()
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: _buildSections(context, filteredMatches),
                    ),
            ),
          ],
        ),
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
        data.map((match) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MatchCard(match: match),
            )),
      );
    }

    if (_selectedFilter == MatchFilter.all) {
      addSection('En cours', liveMatches);
      addSection('À venir', upcomingMatches);
      addSection('Terminés', finishedMatches);
      return sections;
    }

    addSection(_selectedFilter.sectionTitle, matches);
    return sections;
  }
}

enum MatchFilter {
  all('Tous', 'Tous'),
  live('En cours', 'En cours'),
  upcoming('À venir', 'À venir'),
  finished('Terminés', 'Terminés');

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
  });

  final MatchItem match;

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
            ),
            const SizedBox(height: 14),
            _TeamRow(
              teamName: match.awayTeamName,
              players: match.awayPlayers,
              score: match.awayScore,
            ),
            if (match.status == MatchStatus.live) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B044),
                    disabledBackgroundColor: const Color(0xFF10B044),
                    disabledForegroundColor: Colors.white,
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
  });

  final String teamName;
  final List<String> players;
  final int score;

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
                players.isEmpty ? 'Joueurs non renseignés' : players.join(' & '),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ynoughBlack.withValues(alpha: 0.62),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
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
      MatchStatus.upcoming => ('À venir', const Color(0xFF8D99AE), Icons.schedule),
      MatchStatus.finished => ('Terminé', const Color(0xFF3E5F44), Icons.check_circle_outline),
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
