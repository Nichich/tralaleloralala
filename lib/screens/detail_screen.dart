import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/brainrot.dart';
import '../providers/favorites_provider.dart';
import '../services/sound_service.dart';
import '../widgets/brainrot_image.dart';
import '../widgets/rarity_chip.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.brainrot});

  final Brainrot brainrot;

  static Route<void> route(Brainrot brainrot) =>
      MaterialPageRoute<void>(builder: (_) => DetailScreen(brainrot: brainrot));

  Future<void> _playSound(BuildContext context) async {
    final sound = context.read<SoundService>();
    final messenger = ScaffoldMessenger.of(context);
    final played = await sound.play(brainrot.sound);
    if (!played) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Звук пока не завезли')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<FavoritesProvider>().isFavorite(
      brainrot.id,
    );
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Hero(
          tag: brainrot.id,
          // iOS users go back with an edge swipe, so the hero must fly on it too.
          transitionOnUserGestures: true,
          child: BrainrotImage(brainrot: brainrot),
        ),
      ),
    );
    final info = _DetailInfo(
      brainrot: brainrot,
      onPlaySound: () => _playSound(context),
    );

    return PopScope(
      // The sound is several seconds long; don't let it follow the user back to the list.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) context.read<SoundService>().stop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            brainrot.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              tooltip: isFavorite ? 'Убрать из избранного' : 'В избранное',
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () =>
                  context.read<FavoritesProvider>().toggle(brainrot.id),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > constraints.maxHeight;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: image),
                          const SizedBox(width: 24),
                          Expanded(flex: 3, child: info),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: image,
                            ),
                          ),
                          const SizedBox(height: 24),
                          info,
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailInfo extends StatelessWidget {
  const _DetailInfo({required this.brainrot, required this.onPlaySound});

  final Brainrot brainrot;
  final VoidCallback onPlaySound;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          brainrot.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(child: RarityChip(rarity: brainrot.rarity)),
            const SizedBox(width: 16),
            Icon(Icons.bolt, size: 20, color: theme.colorScheme.primary),
            Flexible(
              child: Text(
                'Аура ${brainrot.aura}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Суперсила', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          brainrot.superpower.isEmpty ? 'Засекречена' : brainrot.superpower,
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Text('Лор', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          brainrot.description.isEmpty
              ? 'Лор утерян в глубинах тиктока'
              : brainrot.description,
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onPlaySound,
          icon: const Icon(Icons.volume_up),
          label: const Text('Проиграть звук'),
        ),
      ],
    );
  }
}
