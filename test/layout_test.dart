import 'package:brainrot_dex/widgets/brainrot_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';
import 'helpers/pump_app.dart';

const _sizes = {
  'narrow portrait': Size(320, 568),
  'narrow landscape': Size(568, 320),
  'phone portrait': Size(390, 844),
  'phone landscape': Size(844, 390),
  'tablet': Size(1024, 768),
};

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(NavigationDestination, label));
  await tester.pumpAndSettle();
}

void main() {
  for (final entry in _sizes.entries) {
    testWidgets('no overflow on any screen: ${entry.key}', (tester) async {
      _setSize(tester, entry.value);
      await pumpApp(
        tester,
        api: FakeApiService.returns(sampleBrainrots),
        favorites: {'bombombini_gusini'},
      );
      await tester.pumpAndSettle();

      final longCard = find.byKey(const ValueKey('bombombini_gusini'));
      await tester.scrollUntilVisible(
        longCard,
        200,
        scrollable: find.descendant(of: find.byType(GridView), matching: find.byType(Scrollable)),
      );
      // On a 320px-high screen the card is taller than the grid viewport, so its
      // center is off screen. Tap the name instead.
      final longName = find.descendant(of: longCard, matching: find.byType(Text)).first;
      await tester.ensureVisible(longName);
      await tester.pumpAndSettle();
      await tester.tap(longName);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Проиграть звук'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Проиграть звук'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await _openTab(tester, 'Избранное');
      expect(find.byType(BrainrotCard), findsOneWidget);
      await _openTab(tester, 'Настройки');
      await tester.ensureVisible(find.text('Очистить избранное'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Очистить избранное'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      await _openTab(tester, 'Избранное');

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow in error and empty states: ${entry.key}', (tester) async {
      _setSize(tester, entry.value);
      final api = FakeApiService.fails('Нет подключения к интернету');
      await pumpApp(tester, api: api);
      await tester.pumpAndSettle();
      expect(find.text('Повторить'), findsOneWidget);

      api.handler = () async => sampleBrainrots;
      await tester.ensureVisible(find.text('Повторить'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Повторить'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'шрек');
      await tester.pumpAndSettle();
      expect(find.text('Никого не нашли'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow in dark theme: ${entry.key}', (tester) async {
      _setSize(tester, entry.value);
      await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots), themeMode: ThemeMode.dark);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tralalero Tralala'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tralalero Tralala'));
      await tester.pumpAndSettle();
      expect(find.text('Суперсила Tralalero Tralala'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  }
}
