import 'package:flutter/material.dart';

import '../../navbar/navbar.dart';

class RankingTableHeader extends StatelessWidget {
  const RankingTableHeader({
    super.key,
    required this.totalTeams,
  });

  final int totalTeams;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Classement complet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ynoughBlack,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalTeams equipes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ynoughBlack.withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: ynoughBlack,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            'Pts / V / D / J',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ynoughCream,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
