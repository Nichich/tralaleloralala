import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService(this._prefs);

  static const themeModeKey = 'theme_mode';
  static const favoritesKey = 'favorite_ids';

  final SharedPreferences _prefs;

  ThemeMode loadThemeMode() {
    final stored = _prefs.getString(themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(themeModeKey, mode.name);
  }

  Set<String> loadFavorites() => (_prefs.getStringList(favoritesKey) ?? const <String>[]).toSet();

  Future<void> saveFavorites(Set<String> ids) async {
    await _prefs.setStringList(favoritesKey, ids.toList());
  }
}
