// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/paginated_state.dart';
import '../../../home/domain/entities/article.dart';
import '../../../home/domain/repositories/news_repository.dart';
import '../../../home/presentation/providers/news_repository_provider.dart';

/// Same pagination pattern as [HomeFeedNotifier] but scoped to a single
/// category. Implemented as a `family` so each category screen instance
/// gets its own independent paginated state.
class CategoryFeedNotifier extends StateNotifier<PaginatedState<Article>> {
  final NewsRepository _repository;
  final String categoryId;

  CategoryFeedNotifier(this._repository, this.categoryId)
      : super(const PaginatedState()) {
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoadingFirstPage: true, clearFailure: true);
    final result = await _repository.getArticles(page: 0, categoryId: categoryId);
    result.when(
      success: (articles) => state = state.copyWith(
        items: articles,
        page: 1,
        isLoadingFirstPage: false,
        hasMore: articles.isNotEmpty,
        clearFailure: true,
      ),
      failure: (f) => state = state.copyWith(isLoadingFirstPage: false, failure: f),
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearFailure: true);
    final result = await _repository.getArticles(page: 0, categoryId: categoryId);
    result.when(
      success: (articles) => state = state.copyWith(
        items: articles,
        page: 1,
        isRefreshing: false,
        hasMore: articles.isNotEmpty,
        clearFailure: true,
      ),
      failure: (f) => state = state.copyWith(isRefreshing: false, failure: f),
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingNextPage || !state.hasMore || state.isLoadingFirstPage) return;
    state = state.copyWith(isLoadingNextPage: true);
    final result = await _repository.getArticles(page: state.page, categoryId: categoryId);
    result.when(
      success: (articles) => state = state.copyWith(
        items: [...state.items, ...articles],
        page: state.page + 1,
        isLoadingNextPage: false,
        hasMore: articles.isNotEmpty,
      ),
      failure: (f) => state = state.copyWith(isLoadingNextPage: false),
    );
  }
}

final categoryFeedProvider = StateNotifierProvider.family<
    CategoryFeedNotifier, PaginatedState<Article>, String>((ref, categoryId) {
  return CategoryFeedNotifier(ref.watch(newsRepositoryProvider), categoryId);
});
