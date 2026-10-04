import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/brainrot.dart';
import '../services/api_service.dart';

enum LoadStatus { loading, loaded, error, empty }

class BrainrotProvider extends ChangeNotifier {
  BrainrotProvider(this._api);

  final ApiService _api;

  List<Brainrot> _items = const [];
  LoadStatus _status = LoadStatus.loading;
  String _errorMessage = '';
  bool _isFetching = false;

  List<Brainrot> get items => UnmodifiableListView(_items);
  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;

  Future<void> load() async {
    if (_isFetching) return;
    _status = LoadStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final error = await _fetch();
    if (error != null) {
      _status = LoadStatus.error;
      _errorMessage = error;
    }
    notifyListeners();
  }

  Future<void> retry() => load();

  // Pull-to-refresh: an already shown list must survive a failed request.
  Future<String?> refresh() async {
    if (_isFetching) return null;
    final error = await _fetch();
    if (error != null && _items.isEmpty) {
      _status = LoadStatus.error;
      _errorMessage = error;
    }
    notifyListeners();
    return error;
  }

  List<Brainrot> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return items;
    return _items.where((b) => b.name.toLowerCase().contains(normalized)).toList();
  }

  Future<String?> _fetch() async {
    _isFetching = true;
    try {
      final items = await _api.fetchBrainrots();
      _items = items;
      _status = items.isEmpty ? LoadStatus.empty : LoadStatus.loaded;
      _errorMessage = '';
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (error) {
      // Catches Errors too: otherwise the status would stay loading forever.
      debugPrint('Unexpected load error: $error');
      return 'Что-то пошло не так. Попробуй ещё раз';
    } finally {
      _isFetching = false;
    }
  }
}
