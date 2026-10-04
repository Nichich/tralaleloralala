import 'package:flutter/material.dart';

import '../models/brainrot.dart';
import 'brainrot_card.dart';

class BrainrotGrid extends StatelessWidget {
  const BrainrotGrid({super.key, required this.items, required this.onTap});

  final List<Brainrot> items;
  final ValueChanged<Brainrot> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // Always scrollable so pull-to-refresh works even with two cards.
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final brainrot = items[index];
        return BrainrotCard(
          key: ValueKey(brainrot.id),
          brainrot: brainrot,
          onTap: () => onTap(brainrot),
        );
      },
    );
  }
}
