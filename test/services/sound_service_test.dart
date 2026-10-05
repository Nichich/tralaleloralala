import 'package:brainrot_dex/services/sound_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('empty file name returns false', () async {
    expect(await SoundService(fallback: 'nope.mp3').play(''), isFalse);
  });

  test('missing asset without fallback returns false instead of throwing', () async {
    expect(await SoundService(fallback: 'nope.mp3').play('definitely_missing.mp3'), isFalse);
  });

  test('missing character sound resolves to the bundled fallback', () async {
    expect(await SoundService().resolveAsset('definitely_missing.mp3'), 'sounds/fallback.mp3');
  });

  test('empty sound name resolves to the fallback too', () async {
    expect(await SoundService().resolveAsset(''), 'sounds/fallback.mp3');
  });

  test('existing sound resolves to itself', () async {
    expect(await SoundService().resolveAsset('fallback.mp3'), 'sounds/fallback.mp3');
  });

  test('nothing to play when both files are missing', () async {
    expect(await SoundService(fallback: 'nope.mp3').resolveAsset('missing.mp3'), isNull);
  });
}
