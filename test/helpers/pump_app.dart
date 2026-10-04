import 'package:brainrot_dex/app.dart';
import 'package:brainrot_dex/services/api_service.dart';
import 'package:brainrot_dex/services/sound_service.dart';
import 'package:brainrot_dex/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

Future<StorageService> pumpApp(
  WidgetTester tester, {
  required ApiService api,
  SoundService? sound,
  Set<String> favorites = const {},
  ThemeMode? themeMode,
}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageService(await SharedPreferences.getInstance());
  await storage.saveFavorites(favorites);
  if (themeMode != null) await storage.saveThemeMode(themeMode);

  await tester.pumpWidget(BrainrotDexApp(
    api: api,
    storage: storage,
    sound: sound ?? FakeSoundService(),
  ));
  await tester.pump();
  return storage;
}
