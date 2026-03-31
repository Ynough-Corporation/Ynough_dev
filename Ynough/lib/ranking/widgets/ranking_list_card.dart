import 'package:flutter/material.dart';

import '../../navbar/navbar.dart';
import '../ranking_page.dart';

class RankingListCard extends StatelessWidget {
  const RankingListCard({
    super.key,
    required this.team,
  });

  final RankedTeam team;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RankingIdentity(team: team),
                const SizedBox(height: 14),
                _RankingStats(team: team, compact: true),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _RankingIdentity(team: team)),
              const SizedBox(width: 16),
              _RankingStats(team: team),
            ],
          );
        },
      ),
    );
  }
}

class _RankingIdentity extends StatelessWidget {
  const _RankingIdentity({
    required this.team,
  });

  final RankedTeam team;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0x143E5F44),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            '${team.rank}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ynoughGreen,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ynoughBlack,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                team.players.join(' & '),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ynoughBlack.withValues(alpha: 0.62),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankingStats extends StatelessWidget {
  const _RankingStats({
    required this.team,
    this.compact = false,
  });

  final RankedTeam team;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final children = [
      _StatPill(label: 'PTS', value: '${team.points}', emphasized: true),
      _StatPill(label: 'Victoire', value: '${team.wins}'),
      _StatPill(label: 'Défaite', value: '${team.losses}'),
      _StatPill(label: 'Partie disputée', value: '${team.played}'),
    ];

    if (compact) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: children,
      );
    }

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 10,
      runSpacing: 10,
      children: children,
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: emphasized ? ynoughBlack : const Color(0xFFF4EEE0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: emphasized ? ynoughCream : ynoughBlack,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: emphasized
                      ? ynoughCream.withValues(alpha: 0.72)
                      : ynoughBlack.withValues(alpha: 0.58),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
