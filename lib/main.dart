import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/api_service.dart';
import 'services/sound_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Prefs are loaded before runApp so the saved theme applies on the first frame.
  final prefs = await SharedPreferences.getInstance();
  runApp(BrainrotDexApp(
    api: ApiService(),
    storage: StorageService(prefs),
    sound: SoundService(),
  ));
}
