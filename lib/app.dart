import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/brainrot_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/sound_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

class BrainrotDexApp extends StatelessWidget {
  const BrainrotDexApp({
    super.key,
    required this.api,
    required this.storage,
    required this.sound,
  });

  final ApiService api;
  final StorageService storage;
  final SoundService sound;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SoundService>(create: (_) => sound, dispose: (_, sound) => sound.dispose()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(storage)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(storage)),
        ChangeNotifierProvider(create: (_) => BrainrotProvider(api)..load()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Брейнрот-декс',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.mode,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
