import '../../../../core/network/result.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/news_category.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/mock_categories.dart';
import '../datasources/mock_news_datasource.dart';

/// Implementation backed by [MockNewsDataSource].
///
/// To connect a real API: create `NewsRemoteDataSource` with an identical
/// method surface backed by Dio/http, inject it here instead of
/// [MockNewsDataSource], and wrap calls in try/catch mapping
/// DioException -> [NetworkFailure]/[ServerFailure]. No other layer changes.
class NewsRepositoryImpl implements NewsRepository {
  final MockNewsDataSource _dataSource;

  NewsRepositoryImpl({MockNewsDataSource? dataSource})
      : _dataSource = dataSource ?? MockNewsDataSource.instance;

  @override
  List<NewsCategory> getCategories() => kMockCategories;

  @override
  Future<Result<List<Article>>> getArticles({
    required int page,
    String? categoryId,
  }) async {
    try {
      final articles = await _dataSource.fetchArticles(
        page: page,
        categoryId: categoryId,
      );
      return Result.success(articles);
    } catch (_) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<List<Article>>> getBreakingNews() async {
    try {
      final articles = await _dataSource.fetchBreakingNews();
      return Result.success(articles);
    } catch (_) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<List<Article>>> getTrending() async {
    try {
      final articles = await _dataSource.fetchTrending();
      return Result.success(articles);
    } catch (_) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<List<Article>>> getRecommended() async {
    try {
      final articles = await _dataSource.fetchRecommended();
      return Result.success(articles);
    } catch (_) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<List<Article>>> getPopular() async {
    try {
      final articles = await _dataSource.fetchPopular();
      return Result.success(articles);
    } catch (_) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<Article>> getArticleById(String id) async {
    try {
      final article = await _dataSource.fetchArticleById(id);
      if (article == null) return const Result.failure(NotFoundFailure());
      return Result.success(article);
    } catch (_) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<List<Article>>> getRelatedArticles(String articleId) async {
    try {
      final articles = await _dataSource.fetchRelated(articleId);
      return Result.success(articles);
    } catch (_) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<List<Article>>> searchArticles(String query, {int page = 0}) async {
    try {
      final articles = await _dataSource.search(query, page: page);
      return Result.success(articles);
    } catch (_) {
      return const Result.failure(ServerFailure());
    }
  }

  @override
  Future<Result<List<Article>>> getArticlesByIds(Set<String> ids) async {
    try {
      final articles = await _dataSource.fetchByIds(ids);
      return Result.success(articles);
    } catch (_) {
      return const Result.failure(ServerFailure());
    }
  }
}
