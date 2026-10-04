import 'package:brainrot_dex/widgets/brainrot_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

Future<void> _openFirst(WidgetTester tester) async {
  await tester.tap(find.byType(BrainrotCard).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tap on card opens details', (tester) async {
    await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots));
    await tester.pumpAndSettle();
    await _openFirst(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Суперсила Tralalero Tralala'), findsOneWidget);
    expect(find.text('Описание Tralalero Tralala'), findsOneWidget);
    expect(find.text('Аура 1000'), findsOneWidget);
  });

  testWidgets('hero on details flies on back swipe too', (tester) async {
    await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots));
    await tester.pumpAndSettle();
    await _openFirst(tester);

    expect(tester.widget<Hero>(find.byType(Hero)).transitionOnUserGestures, isTrue);
  });

  testWidgets('narrow landscape puts image left of the text', (tester) async {
    tester.view.physicalSize = const Size(568, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Tralalero Tralala'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tralalero Tralala'));
    await tester.pumpAndSettle();

    final image = tester.getRect(find.byType(Hero));
    final superpower = tester.getRect(find.text('Суперсила Tralalero Tralala'));
    expect(superpower.left, greaterThanOrEqualTo(image.right));
  });

  testWidgets('heart toggles favorite and persists', (tester) async {
    final storage = await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots));
    await tester.pumpAndSettle();
    await _openFirst(tester);

    await tester.tap(find.byTooltip('В избранное'));
    await tester.pump();
    expect(find.byIcon(Icons.favorite), findsWidgets);
    expect(storage.loadFavorites(), {'tralalero_tralala'});

    await tester.tap(find.byTooltip('Убрать из избранного'));
    await tester.pump();
    expect(storage.loadFavorites(), isEmpty);
  });

  testWidgets('missing sound shows snackbar instead of crashing', (tester) async {
    final sound = FakeSoundService(result: false);
    await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots), sound: sound);
    await tester.pumpAndSettle();
    await _openFirst(tester);

    await tester.tap(find.text('Проиграть звук'));
    await tester.pump();

    expect(sound.played, ['tralalero_tralala.mp3']);
    expect(find.text('Звук пока не завезли'), findsOneWidget);
  });

  testWidgets('played sound shows no snackbar', (tester) async {
    await pumpApp(
      tester,
      api: FakeApiService.returns(sampleBrainrots),
      sound: FakeSoundService(result: true),
    );
    await tester.pumpAndSettle();
    await _openFirst(tester);

    await tester.tap(find.text('Проиграть звук'));
    await tester.pump();

    expect(find.text('Звук пока не завезли'), findsNothing);
  });
}
