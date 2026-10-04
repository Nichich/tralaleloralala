import 'package:brainrot_dex/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = StorageService(prefs);
  });

  test('theme defaults to system', () {
    expect(storage.loadThemeMode(), ThemeMode.system);
  });

  test('theme round trip', () async {
    await storage.saveThemeMode(ThemeMode.dark);
    expect(StorageService(prefs).loadThemeMode(), ThemeMode.dark);
  });

  test('unknown stored theme falls back to system', () async {
    await prefs.setString(StorageService.themeModeKey, 'purple');
    expect(storage.loadThemeMode(), ThemeMode.system);
  });

  test('favorites default to empty and round trip', () async {
    expect(storage.loadFavorites(), isEmpty);
    await storage.saveFavorites({'a', 'b'});
    expect(StorageService(prefs).loadFavorites(), {'a', 'b'});
  });
}
