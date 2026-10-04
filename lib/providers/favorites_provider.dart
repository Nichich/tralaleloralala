import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(StorageService storage)
      : _storage = storage,
        _ids = storage.loadFavorites();

  final StorageService _storage;
  final Set<String> _ids;

  Set<String> get ids => Set.unmodifiable(_ids);
  bool get isEmpty => _ids.isEmpty;

  bool isFavorite(String id) => _ids.contains(id);

  Future<void> toggle(String id) async {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
    await _storage.saveFavorites(_ids);
  }

  Future<void> clear() async {
    if (_ids.isEmpty) return;
    _ids.clear();
    notifyListeners();
    await _storage.saveFavorites(_ids);
  }
}
