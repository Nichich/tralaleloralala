import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';

const String kAppVersion = '1.0.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final favorites = context.read<FavoritesProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Очистить избранное?'),
        content: const Text('Все собранные брейнроты пропадут из коллекции.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await favorites.clear();
    messenger.showSnackBar(const SnackBar(content: Text('Избранное очищено')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final favorites = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const ListTile(
              leading: Icon(Icons.palette_outlined),
              title: Text('Тема'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Светлая', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Системная', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Темная', maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
                selected: {themeProvider.mode},
                onSelectionChanged: (selection) => themeProvider.setMode(selection.first),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Очистить избранное'),
              subtitle: Text(
                favorites.isEmpty ? 'Там и так пусто' : 'В коллекции: ${favorites.ids.length}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              enabled: !favorites.isEmpty,
              onTap: () => _confirmClear(context),
            ),
            const SizedBox(height: 24),
            Text(
              'Версия $kAppVersion',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
