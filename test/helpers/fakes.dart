import 'package:brainrot_dex/models/brainrot.dart';
import 'package:brainrot_dex/services/api_service.dart';
import 'package:brainrot_dex/services/sound_service.dart';

class FakeApiService extends ApiService {
  FakeApiService(this.handler);

  FakeApiService.returns(List<Brainrot> items) : this(() async => items);

  FakeApiService.fails(String message) : this(() async => throw ApiException(message));

  Future<List<Brainrot>> Function() handler;
  int calls = 0;

  @override
  Future<List<Brainrot>> fetchBrainrots() {
    calls++;
    return handler();
  }
}

class FakeSoundService extends SoundService {
  FakeSoundService({this.result = false});

  final bool result;
  final List<String> played = [];

  @override
  Future<bool> play(String fileName) async {
    played.add(fileName);
    return result;
  }

  @override
  Future<void> dispose() async {}
}

Brainrot testBrainrot(String id, String name, {Rarity rarity = Rarity.common}) => Brainrot(
      id: id,
      name: name,
      description: 'Описание $name',
      superpower: 'Суперсила $name',
      rarity: rarity,
      aura: 1000,
      image: '',
      sound: '$id.mp3',
    );

final sampleBrainrots = [
  testBrainrot('tralalero_tralala', 'Tralalero Tralala', rarity: Rarity.legendary),
  testBrainrot('bombardiro_crocodilo', 'Bombardiro Crocodilo', rarity: Rarity.rare),
  testBrainrot('tung_tung_tung_sahur', 'Tung Tung Tung Sahur'),
  testBrainrot('bombombini_gusini', 'Bombombini Gusini Supersonico Turbo Gigante Maximo Extra Long'),
];
