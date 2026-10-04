import 'package:brainrot_dex/models/brainrot.dart';
import 'package:brainrot_dex/theme/app_theme.dart';
import 'package:brainrot_dex/widgets/brainrot_card.dart';
import 'package:brainrot_dex/widgets/brainrot_image.dart';
import 'package:brainrot_dex/widgets/empty_view.dart';
import 'package:brainrot_dex/widgets/error_view.dart';
import 'package:brainrot_dex/widgets/loading_view.dart';
import 'package:brainrot_dex/widgets/rarity_chip.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

Widget _wrap(Widget child, {ThemeData? theme}) =>
    MaterialApp(theme: theme ?? AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('LoadingView shows a spinner', (tester) async {
    await tester.pumpWidget(_wrap(const LoadingView()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ErrorView shows texts and calls onRetry', (tester) async {
    var retried = 0;
    await tester.pumpWidget(_wrap(ErrorView(message: 'Нет сети', onRetry: () => retried++)));

    expect(find.text('Брейнрот не загрузился. Проверь интернет'), findsOneWidget);
    expect(find.text('Нет сети'), findsOneWidget);
    await tester.tap(find.text('Повторить'));
    expect(retried, 1);
  });

  testWidgets('EmptyView shows retry only when callback given', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyView(message: 'Пусто')));
    expect(find.text('Пусто'), findsOneWidget);
    expect(find.text('Повторить'), findsNothing);

    await tester.pumpWidget(_wrap(EmptyView(message: 'Пусто', onRetry: () {})));
    expect(find.text('Повторить'), findsOneWidget);
  });

  testWidgets('RarityChip shows label in both themes', (tester) async {
    await tester.pumpWidget(_wrap(const RarityChip(rarity: Rarity.legendary)));
    expect(find.text('Легендарный'), findsOneWidget);

    await tester.pumpWidget(_wrap(const RarityChip(rarity: Rarity.rare), theme: AppTheme.dark));
    expect(find.text('Редкий'), findsOneWidget);
  });

  testWidgets('BrainrotImage with empty url shows first letter placeholder', (tester) async {
    await tester.pumpWidget(_wrap(SizedBox(
      width: 200,
      height: 200,
      child: BrainrotImage(brainrot: sampleBrainrots.first),
    )));

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.text('T'), findsOneWidget);
  });

  testWidgets('BrainrotImage with garbage url shows placeholder too', (tester) async {
    const brainrot = Brainrot(
      id: 'x',
      name: 'x-man',
      description: '',
      superpower: '',
      rarity: Rarity.common,
      aura: 0,
      image: 'not a url',
      sound: '',
    );
    await tester.pumpWidget(
        _wrap(const SizedBox(width: 100, height: 100, child: BrainrotImage(brainrot: brainrot))));

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.text('X'), findsOneWidget);
  });

  testWidgets('BrainrotCard shows data, has Hero and handles tap', (tester) async {
    var tapped = 0;
    final brainrot = sampleBrainrots.first;
    await tester.pumpWidget(_wrap(Center(
      child: SizedBox(
        width: 160,
        height: 220,
        child: BrainrotCard(brainrot: brainrot, onTap: () => tapped++),
      ),
    )));

    expect(find.text('Tralalero Tralala'), findsOneWidget);
    expect(find.text('Легендарный'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);
    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, brainrot.id);
    // iOS users go back with an edge swipe; the hero must fly on that gesture too.
    expect(hero.transitionOnUserGestures, isTrue);

    await tester.tap(find.byType(BrainrotCard));
    expect(tapped, 1);
  });
}
