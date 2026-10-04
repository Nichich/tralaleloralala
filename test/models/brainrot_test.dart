import 'dart:convert';
import 'dart:io';

import 'package:brainrot_dex/models/brainrot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rarity.fromString', () {
    test('parses known values ignoring case and spaces', () {
      expect(Rarity.fromString('legendary'), Rarity.legendary);
      expect(Rarity.fromString(' RARE '), Rarity.rare);
      expect(Rarity.fromString('common'), Rarity.common);
    });

    test('falls back to common for unknown values', () {
      expect(Rarity.fromString('mythic'), Rarity.common);
      expect(Rarity.fromString(''), Rarity.common);
      expect(Rarity.fromString(null), Rarity.common);
    });
  });

  group('Brainrot.fromJson', () {
    test('reads all fields', () {
      final brainrot = Brainrot.fromJson({
        'id': 'tralalero_tralala',
        'name': 'Tralalero Tralala',
        'description': 'Акула в найках',
        'superpower': 'Бегает',
        'rarity': 'legendary',
        'aura': 9000,
        'image': '',
        'sound': 'tralalero_tralala.mp3',
      });

      expect(brainrot.id, 'tralalero_tralala');
      expect(brainrot.name, 'Tralalero Tralala');
      expect(brainrot.description, 'Акула в найках');
      expect(brainrot.superpower, 'Бегает');
      expect(brainrot.rarity, Rarity.legendary);
      expect(brainrot.aura, 9000);
      expect(brainrot.image, '');
      expect(brainrot.sound, 'tralalero_tralala.mp3');
    });

    test('tolerates wrong types in optional fields', () {
      final fromString = Brainrot.fromJson({'id': 'a', 'name': 'A', 'aura': '9000'});
      expect(fromString.aura, 9000);

      final broken = Brainrot.fromJson({
        'id': 'b',
        'name': 'B',
        'aura': true,
        'description': 42,
        'rarity': null,
        'sound': ['x'],
      });
      expect(broken.aura, 0);
      expect(broken.description, '');
      expect(broken.rarity, Rarity.common);
      expect(broken.sound, '');
      expect(broken.image, '');
    });

    test('non-finite aura becomes 0', () {
      final brainrot = Brainrot.fromJson(
          jsonDecode('{"id":"a","name":"A","aura":1e400}') as Map<String, dynamic>);
      expect(brainrot.aura, 0);
    });

    test('throws FormatException without id or name', () {
      expect(() => Brainrot.fromJson({'name': 'A'}), throwsFormatException);
      expect(() => Brainrot.fromJson({'id': 'a', 'name': '  '}), throwsFormatException);
      expect(() => Brainrot.fromJson({'id': 1, 'name': 'A'}), throwsFormatException);
    });
  });

  test('data/brainrots.json has 10 valid unique characters', () {
    final raw = jsonDecode(File('data/brainrots.json').readAsStringSync()) as List<dynamic>;
    final maps = raw.cast<Map<String, dynamic>>();
    final items = maps.map(Brainrot.fromJson).toList();

    expect(items, hasLength(10));
    expect(items.map((b) => b.id).toSet(), hasLength(10));
    for (var i = 0; i < items.length; i++) {
      expect(Rarity.values.map((r) => r.name), contains(maps[i]['rarity']));
      expect(items[i].description, isNotEmpty);
      expect(items[i].superpower, isNotEmpty);
      final image = items[i].image;
      if (image.isNotEmpty) {
        final fileName = Uri.parse(image).pathSegments.last;
        expect(fileName.split('.').first, items[i].id);
        expect(File('images/$fileName').existsSync(), isTrue, reason: 'no images/$fileName in repo');
      }
      expect(items[i].sound, '${items[i].id}.mp3');
    }
  });
}
