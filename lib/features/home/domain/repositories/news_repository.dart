import '../../../../core/network/result.dart';
import '../entities/article.dart';
import '../entities/news_category.dart';

/// Contract the rest of the app depends on. Providers only ever talk to
/// this interface, never to [MockNewsDataSource] directly — so tests can
/// supply a fake implementation and a future API-backed implementation is
/// a drop-in replacement registered in a single Riverpod provider.
abstract class NewsRepository {
  List<NewsCategory> getCategories();

  Future<Result<List<Article>>> getArticles({
    required int page,
    String? categoryId,
  });

  Future<Result<List<Article>>> getBreakingNews();

  Future<Result<List<Article>>> getTrending();

  Future<Result<List<Article>>> getRecommended();

  Future<Result<List<Article>>> getPopular();

  Future<Result<Article>> getArticleById(String id);

  Future<Result<List<Article>>> getRelatedArticles(String articleId);

  Future<Result<List<Article>>> searchArticles(String query, {int page});

  /// Batch-resolves a set of article IDs into full [Article] objects —
  /// used to hydrate the Bookmarks screen from the locally-persisted ID
  /// set. Maps directly to `GET /articles?ids=...` once a real API exists.
  Future<Result<List<Article>>> getArticlesByIds(Set<String> ids);
}
