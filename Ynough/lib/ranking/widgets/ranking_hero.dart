import 'package:flutter/material.dart';

import '../../navbar/navbar.dart';
import '../ranking_page.dart';

class RankingHero extends StatelessWidget {
  const RankingHero({
    super.key,
    required this.topTeams,
  });

  final List<RankedTeam> topTeams;

  @override
  Widget build(BuildContext context) {
    if (topTeams.length < 3) {
      return const SizedBox.shrink();
    }

    final second = topTeams[1];
    final first = topTeams[0];
    final third = topTeams[2];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3E5F44), Color(0xFF587A5D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 3',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ynoughCream,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les equipes les mieux classees pour le moment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ynoughCream.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 560) {
                return Column(
                  children: [
                    _PodiumCard(team: first, highlight: true),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _PodiumCard(team: second)),
                        const SizedBox(width: 12),
                        Expanded(child: _PodiumCard(team: third)),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _PodiumCard(team: second)),
                  const SizedBox(width: 12),
                  Expanded(child: _PodiumCard(team: first, highlight: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _PodiumCard(team: third)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.team,
    this.highlight = false,
  });

  final RankedTeam team;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = highlight ? ynoughCream : Colors.white.withValues(alpha: 0.14);
    final foregroundColor = highlight ? ynoughBlack : ynoughCream;

    return Container(
      padding: EdgeInsets.fromLTRB(16, highlight ? 22 : 18, 16, 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlight ? Colors.transparent : Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: highlight ? const Color(0xFFE8D38A) : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${team.rank}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: highlight ? ynoughBlack : ynoughCream,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            team.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            team.players.join(' & '),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 14),
          Text(
            '${team.points} pts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${team.wins} V / ${team.losses} D',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foregroundColor.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
