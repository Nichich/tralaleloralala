import 'package:brainrot_dex/providers/favorites_provider.dart';
import 'package:brainrot_dex/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService(await SharedPreferences.getInstance());
  });

  test('toggle adds and removes and persists', () async {
    final provider = FavoritesProvider(storage);
    expect(provider.isEmpty, isTrue);

    await provider.toggle('a');
    expect(provider.isFavorite('a'), isTrue);
    expect(FavoritesProvider(storage).isFavorite('a'), isTrue);

    await provider.toggle('a');
    expect(provider.isFavorite('a'), isFalse);
    expect(storage.loadFavorites(), isEmpty);
  });

  test('clear removes everything and persists', () async {
    await storage.saveFavorites({'a', 'b'});
    final provider = FavoritesProvider(storage);

    await provider.clear();

    expect(provider.ids, isEmpty);
    expect(storage.loadFavorites(), isEmpty);
  });
}
