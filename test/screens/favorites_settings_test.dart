import 'package:brainrot_dex/widgets/brainrot_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(NavigationDestination, label));
  await tester.pumpAndSettle();
}

ThemeMode _appThemeMode(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

void main() {
  testWidgets('empty favorites show collection-empty message', (tester) async {
    await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots));
    await tester.pumpAndSettle();
    await _openTab(tester, 'Избранное');

    expect(find.text('Коллекция пуста. Иди собирай брейнротов'), findsOneWidget);
  });

  testWidgets('hero works from favorites while the same card lives in the list tab',
      (tester) async {
    await pumpApp(
      tester,
      api: FakeApiService.returns(sampleBrainrots),
      favorites: {'tralalero_tralala'},
    );
    await tester.pumpAndSettle();
    await _openTab(tester, 'Избранное');

    expect(find.byType(BrainrotCard), findsOneWidget);
    await tester.tap(find.byType(BrainrotCard));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Суперсила Tralalero Tralala'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await _openTab(tester, 'Все');
    await tester.tap(find.byType(BrainrotCard).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved dark theme applies on the first frame', (tester) async {
    await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots), themeMode: ThemeMode.dark);
    expect(_appThemeMode(tester), ThemeMode.dark);
  });

  testWidgets('segmented button switches and saves theme', (tester) async {
    final storage = await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots));
    await tester.pumpAndSettle();
    await _openTab(tester, 'Настройки');

    await tester.tap(find.text('Темная'));
    await tester.pumpAndSettle();
    expect(_appThemeMode(tester), ThemeMode.dark);
    expect(storage.loadThemeMode(), ThemeMode.dark);

    await tester.tap(find.text('Светлая'));
    await tester.pumpAndSettle();
    expect(_appThemeMode(tester), ThemeMode.light);
  });

  testWidgets('clear favorites asks for confirmation', (tester) async {
    final storage = await pumpApp(
      tester,
      api: FakeApiService.returns(sampleBrainrots),
      favorites: {'tralalero_tralala'},
    );
    await tester.pumpAndSettle();
    await _openTab(tester, 'Настройки');

    await tester.tap(find.text('Очистить избранное'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(storage.loadFavorites(), {'tralalero_tralala'});

    await tester.tap(find.text('Очистить избранное'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Очистить'));
    await tester.pumpAndSettle();
    expect(storage.loadFavorites(), isEmpty);
  });

  testWidgets('settings show app version', (tester) async {
    await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots));
    await tester.pumpAndSettle();
    await _openTab(tester, 'Настройки');

    expect(find.text('Версия 1.0.0'), findsOneWidget);
  });
}
