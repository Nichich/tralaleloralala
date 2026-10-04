import 'package:brainrot_dex/services/sound_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('empty file name returns false', () async {
    expect(await SoundService().play(''), isFalse);
  });

  test('missing asset returns false instead of throwing', () async {
    expect(await SoundService().play('definitely_missing.mp3'), isFalse);
  });
}
