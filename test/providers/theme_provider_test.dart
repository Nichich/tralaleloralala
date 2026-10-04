import 'package:brainrot_dex/providers/theme_provider.dart';
import 'package:brainrot_dex/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService(await SharedPreferences.getInstance());
  });

  test('defaults to system', () {
    expect(ThemeProvider(storage).mode, ThemeMode.system);
  });

  test('setMode notifies and persists', () async {
    final provider = ThemeProvider(storage);
    var notified = 0;
    provider.addListener(() => notified++);

    await provider.setMode(ThemeMode.dark);

    expect(provider.mode, ThemeMode.dark);
    expect(notified, 1);
    expect(ThemeProvider(storage).mode, ThemeMode.dark);
  });
}
