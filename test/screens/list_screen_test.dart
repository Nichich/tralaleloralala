import 'dart:async';

import 'package:brainrot_dex/models/brainrot.dart';
import 'package:brainrot_dex/widgets/brainrot_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('shows spinner while loading, then cards', (tester) async {
    final completer = Completer<List<Brainrot>>();
    await pumpApp(tester, api: FakeApiService(() => completer.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(sampleBrainrots);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(BrainrotCard), findsWidgets);
  });

  testWidgets('error shows message and retry reloads', (tester) async {
    final api = FakeApiService.fails('Нет подключения к интернету');
    await pumpApp(tester, api: api);
    await tester.pumpAndSettle();

    expect(find.text('Брейнрот не загрузился. Проверь интернет'), findsOneWidget);
    expect(find.text('Нет подключения к интернету'), findsOneWidget);

    api.handler = () async => sampleBrainrots;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();

    expect(find.byType(BrainrotCard), findsWidgets);
    expect(api.calls, 2);
  });

  testWidgets('empty data shows empty view with retry', (tester) async {
    await pumpApp(tester, api: FakeApiService.returns([]));
    await tester.pumpAndSettle();

    expect(find.text('Брейнротов пока нет'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });

  testWidgets('search filters case-insensitively and shows nothing found', (tester) async {
    await pumpApp(tester, api: FakeApiService.returns(sampleBrainrots));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'TUNG');
    await tester.pump();
    expect(find.byType(BrainrotCard), findsOneWidget);
    expect(find.text('Tung Tung Tung Sahur'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'шрек');
    await tester.pump();
    expect(find.text('Никого не нашли'), findsOneWidget);

    await tester.tap(find.byTooltip('Очистить поиск'));
    await tester.pump();
    expect(find.byType(BrainrotCard), findsWidgets);
  });
}
