import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/local_storage_service.dart';

class RecentSearchesRepository {
  final LocalStorageService _storage;
  static const int _maxItems = 10;

  RecentSearchesRepository(this._storage);

  List<String> getRecentSearches() =>
      _storage.getStringList(StorageKeys.recentSearches);

  Future<void> addSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final current = getRecentSearches()
      ..removeWhere((q) => q.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    if (current.length > _maxItems) current.removeRange(_maxItems, current.length);
    await _storage.setStringList(StorageKeys.recentSearches, current);
  }

  Future<void> removeSearch(String query) async {
    final current = getRecentSearches()..remove(query);
    await _storage.setStringList(StorageKeys.recentSearches, current);
  }

  Future<void> clearAll() async {
    await _storage.setStringList(StorageKeys.recentSearches, []);
  }
}
