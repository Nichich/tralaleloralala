import 'package:flutter/material.dart';

import '../models/brainrot.dart';
import '../theme/app_theme.dart';

class RarityChip extends StatelessWidget {
  const RarityChip({super.key, required this.rarity});

  final Rarity rarity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<RarityColors>() ?? RarityColors.light;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background(rarity),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          rarity.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.foreground(rarity),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
