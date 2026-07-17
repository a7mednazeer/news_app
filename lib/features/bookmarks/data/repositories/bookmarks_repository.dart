import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/local_storage_service.dart';

/// Persists bookmarked article IDs locally. Kept as a small dedicated
/// repository (rather than folded into NewsRepository) since bookmark
/// state is a device-local concern, distinct from remote article data —
/// this separation keeps NewsRepository purely about content fetching.
class BookmarksRepository {
  final LocalStorageService _storage;
  BookmarksRepository(this._storage);

  Set<String> getBookmarkedIds() {
    return _storage.getStringList(StorageKeys.bookmarkedArticles).toSet();
  }

  Future<void> toggleBookmark(String articleId) async {
    final current = getBookmarkedIds();
    if (current.contains(articleId)) {
      current.remove(articleId);
    } else {
      current.add(articleId);
    }
    await _storage.setStringList(
      StorageKeys.bookmarkedArticles,
      current.toList(),
    );
  }

  Future<void> removeBookmark(String articleId) async {
    final current = getBookmarkedIds()..remove(articleId);
    await _storage.setStringList(
      StorageKeys.bookmarkedArticles,
      current.toList(),
    );
  }

  bool isBookmarked(String articleId) =>
      getBookmarkedIds().contains(articleId);
}
