import 'package:flutter/material.dart';

import '../models/brainrot.dart';

const Color _seedColor = Color(0xFF6A4CFF);

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light, RarityColors.light);

  static ThemeData get dark => _build(Brightness.dark, RarityColors.dark);

  static ThemeData _build(Brightness brightness, RarityColors rarityColors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: brightness),
      extensions: [rarityColors],
    );
  }
}

// ColorScheme has no slot for gold, so rarity colors live in a theme extension
// with separate light and dark values.
@immutable
class RarityColors extends ThemeExtension<RarityColors> {
  const RarityColors({
    required this.common,
    required this.onCommon,
    required this.rare,
    required this.onRare,
    required this.legendary,
    required this.onLegendary,
  });

  static const light = RarityColors(
    common: Color(0xFFE3E3E3),
    onCommon: Color(0xFF424242),
    rare: Color(0xFFD6E4FF),
    onRare: Color(0xFF0B57D0),
    legendary: Color(0xFFFFE8A3),
    onLegendary: Color(0xFF7A5900),
  );

  static const dark = RarityColors(
    common: Color(0xFF424242),
    onCommon: Color(0xFFE3E3E3),
    rare: Color(0xFF0B3A82),
    onRare: Color(0xFFD6E4FF),
    legendary: Color(0xFF5C4300),
    onLegendary: Color(0xFFFFE08A),
  );

  final Color common;
  final Color onCommon;
  final Color rare;
  final Color onRare;
  final Color legendary;
  final Color onLegendary;

  Color background(Rarity rarity) => switch (rarity) {
        Rarity.common => common,
        Rarity.rare => rare,
        Rarity.legendary => legendary,
      };

  Color foreground(Rarity rarity) => switch (rarity) {
        Rarity.common => onCommon,
        Rarity.rare => onRare,
        Rarity.legendary => onLegendary,
      };

  @override
  RarityColors copyWith({
    Color? common,
    Color? onCommon,
    Color? rare,
    Color? onRare,
    Color? legendary,
    Color? onLegendary,
  }) {
    return RarityColors(
      common: common ?? this.common,
      onCommon: onCommon ?? this.onCommon,
      rare: rare ?? this.rare,
      onRare: onRare ?? this.onRare,
      legendary: legendary ?? this.legendary,
      onLegendary: onLegendary ?? this.onLegendary,
    );
  }

  @override
  RarityColors lerp(ThemeExtension<RarityColors>? other, double t) {
    if (other is! RarityColors) return this;
    return RarityColors(
      common: Color.lerp(common, other.common, t)!,
      onCommon: Color.lerp(onCommon, other.onCommon, t)!,
      rare: Color.lerp(rare, other.rare, t)!,
      onRare: Color.lerp(onRare, other.onRare, t)!,
      legendary: Color.lerp(legendary, other.legendary, t)!,
      onLegendary: Color.lerp(onLegendary, other.onLegendary, t)!,
    );
  }
}
