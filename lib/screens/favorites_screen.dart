import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/brainrot_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/brainrot_grid.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final brainrots = context.watch<BrainrotProvider>();
    final favorites = context.watch<FavoritesProvider>();

    switch (brainrots.status) {
      case LoadStatus.loading:
        return const LoadingView();
      case LoadStatus.error:
        return ErrorView(message: brainrots.errorMessage, onRetry: brainrots.retry);
      case LoadStatus.empty:
      case LoadStatus.loaded:
        final items = brainrots.items.where((b) => favorites.isFavorite(b.id)).toList();
        if (items.isEmpty) {
          return const EmptyView(
            message: 'Коллекция пуста. Иди собирай брейнротов',
            icon: Icons.favorite_border,
          );
        }
        return BrainrotGrid(
          items: items,
          onTap: (brainrot) => Navigator.of(context).push(DetailScreen.route(brainrot)),
        );
    }
  }
}
