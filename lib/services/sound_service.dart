import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  SoundService({this.fallback = 'fallback.mp3'});

  // Played for characters that don't have their own sound yet.
  final String fallback;

  AudioPlayer? _player;

  AudioPlayer get _audio => _player ??= AudioPlayer();

  Future<bool> play(String fileName) async {
    try {
      final asset = await resolveAsset(fileName);
      if (asset == null) return false;
      await _audio.stop();
      await _audio.play(AssetSource(asset));
      return true;
    } catch (error) {
      debugPrint('Sound $fileName failed: $error');
      return false;
    }
  }

  // Path relative to assets/, as AssetSource expects it, or null if nothing is bundled.
  Future<String?> resolveAsset(String fileName) async {
    for (final name in [fileName.trim(), fallback]) {
      if (name.isEmpty) continue;
      // audioplayers fails on a missing asset in a platform-specific way,
      // so check the bundle first and get a predictable result.
      try {
        await rootBundle.load('assets/sounds/$name');
        return 'sounds/$name';
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<void> stop() async {
    await _player?.stop();
  }

  Future<void> dispose() async {
    await _player?.dispose();
  }
}
