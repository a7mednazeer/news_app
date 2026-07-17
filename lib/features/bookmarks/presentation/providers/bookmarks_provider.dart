import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../home/domain/entities/article.dart';
import '../../../home/presentation/providers/news_repository_provider.dart';
import '../../data/repositories/bookmarks_repository.dart';

final bookmarksRepositoryProvider = Provider<BookmarksRepository>((ref) {
  return BookmarksRepository(ref.watch(localStorageServiceProvider));
});

/// Holds the current set of bookmarked article IDs in memory, backed by
/// local storage. Using a Set<String> (not full Article objects) keeps this
/// provider cheap to watch from every news card without duplicating article
/// data — the bookmarks *screen* resolves IDs back to full articles via the
/// repository (see [bookmarkedArticlesProvider]).
class BookmarksNotifier extends StateNotifier<Set<String>> {
  final BookmarksRepository _repository;

  BookmarksNotifier(this._repository) : super(_repository.getBookmarkedIds());

  Future<void> toggle(String articleId) async {
    await _repository.toggleBookmark(articleId);
    state = _repository.getBookmarkedIds();
  }

  Future<void> remove(String articleId) async {
    await _repository.removeBookmark(articleId);
    state = _repository.getBookmarkedIds();
  }

  bool isBookmarked(String articleId) => state.contains(articleId);
}

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, Set<String>>((ref) {
  return BookmarksNotifier(ref.watch(bookmarksRepositoryProvider));
});

/// Resolves the current bookmarked ID set into full [Article] objects.
/// Rebuilds automatically whenever [bookmarksProvider]'s ID set changes.
final bookmarkedArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final ids = ref.watch(bookmarksProvider);
  if (ids.isEmpty) return const [];
  final repo = ref.watch(newsRepositoryProvider);
  final result = await repo.getArticlesByIds(ids);
  return result.when(
    success: (articles) {
      final sorted = [...articles]
        ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return sorted;
    },
    failure: (_) => const [],
  );
});
