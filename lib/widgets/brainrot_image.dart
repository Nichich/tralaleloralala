import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/brainrot.dart';

class BrainrotImage extends StatelessWidget {
  const BrainrotImage({super.key, required this.brainrot});

  final Brainrot brainrot;

  @override
  Widget build(BuildContext context) {
    final url = brainrot.image;
    final placeholder = _Placeholder(name: brainrot.name);
    final uri = Uri.tryParse(url);
    if (url.isEmpty || uri == null || !uri.hasScheme) return placeholder;

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => placeholder,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = [
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
    ];
    final (background, foreground) =
        palette[name.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % palette.length];
    final letter = name.isEmpty ? '?' : name[0].toUpperCase();

    // Material gives the text a proper DefaultTextStyle during the Hero flight,
    // otherwise Flutter draws the yellow debug underline.
    return Material(
      color: background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image_not_supported_outlined, color: foreground),
                const SizedBox(height: 8),
                Text(letter, style: theme.textTheme.displaySmall?.copyWith(color: foreground)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
