import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  AudioPlayer? _player;

  AudioPlayer get _audio => _player ??= AudioPlayer();

  Future<bool> play(String fileName) async {
    if (fileName.trim().isEmpty) return false;
    try {
      // audioplayers fails on a missing asset in a platform-specific way,
      // so check the bundle first and get a predictable error.
      await rootBundle.load('assets/sounds/$fileName');
      await _audio.stop();
      await _audio.play(AssetSource('sounds/$fileName'));
      return true;
    } catch (error) {
      debugPrint('Sound $fileName failed: $error');
      return false;
    }
  }

  Future<void> dispose() async {
    await _player?.dispose();
  }
}
