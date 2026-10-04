import 'package:flutter/material.dart';

import '../models/brainrot.dart';
import 'brainrot_image.dart';
import 'rarity_chip.dart';

class BrainrotCard extends StatelessWidget {
  const BrainrotCard({super.key, required this.brainrot, required this.onTap});

  final Brainrot brainrot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: brainrot.id,
                transitionOnUserGestures: true,
                child: BrainrotImage(brainrot: brainrot),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brainrot.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(child: RarityChip(rarity: brainrot.rarity)),
                      const SizedBox(width: 8),
                      Icon(Icons.bolt, size: 16, color: theme.colorScheme.primary),
                      Flexible(
                        child: Text(
                          '${brainrot.aura}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    ],
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
