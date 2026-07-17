import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/paginated_state.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import 'news_repository_provider.dart';

/// Drives the main "Latest" feed on the Home screen: supports
/// pull-to-refresh and infinite scroll, and can optionally filter to the
/// user's onboarding-selected categories (see [personalize]).
class HomeFeedNotifier extends StateNotifier<PaginatedState<Article>> {
  final NewsRepository _repository;

  HomeFeedNotifier(this._repository) : super(const PaginatedState()) {
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    state = state.copyWith(isLoadingFirstPage: true, clearFailure: true);
    final result = await _repository.getArticles(page: 0);
    result.when(
      success: (articles) {
        state = state.copyWith(
          items: articles,
          page: 1,
          isLoadingFirstPage: false,
          hasMore: articles.isNotEmpty,
          clearFailure: true,
        );
      },
      failure: (f) {
        state = state.copyWith(isLoadingFirstPage: false, failure: f);
      },
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearFailure: true);
    final result = await _repository.getArticles(page: 0);
    result.when(
      success: (articles) {
        state = state.copyWith(
          items: articles,
          page: 1,
          isRefreshing: false,
          hasMore: articles.isNotEmpty,
          clearFailure: true,
        );
      },
      failure: (f) {
        state = state.copyWith(isRefreshing: false, failure: f);
      },
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingNextPage || !state.hasMore || state.isLoadingFirstPage) {
      return;
    }
    state = state.copyWith(isLoadingNextPage: true);
    final result = await _repository.getArticles(page: state.page);
    result.when(
      success: (articles) {
        state = state.copyWith(
          items: [...state.items, ...articles],
          page: state.page + 1,
          isLoadingNextPage: false,
          hasMore: articles.isNotEmpty,
        );
      },
      failure: (f) {
        // Keep existing items visible; surface a lightweight retry instead
        // of wiping the feed on a "load more" failure.
        state = state.copyWith(isLoadingNextPage: false);
      },
    );
  }
}

final homeFeedProvider =
    StateNotifierProvider<HomeFeedNotifier, PaginatedState<Article>>((ref) {
  return HomeFeedNotifier(ref.watch(newsRepositoryProvider));
});

final breakingNewsProvider = FutureProvider<List<Article>>((ref) async {
  final result = await ref.watch(newsRepositoryProvider).getBreakingNews();
  return result.when(success: (a) => a, failure: (_) => const []);
});

final trendingNewsProvider = FutureProvider<List<Article>>((ref) async {
  final result = await ref.watch(newsRepositoryProvider).getTrending();
  return result.when(success: (a) => a, failure: (_) => const []);
});

final recommendedNewsProvider = FutureProvider<List<Article>>((ref) async {
  final result = await ref.watch(newsRepositoryProvider).getRecommended();
  return result.when(success: (a) => a, failure: (_) => const []);
});

final popularNewsProvider = FutureProvider<List<Article>>((ref) async {
  final result = await ref.watch(newsRepositoryProvider).getPopular();
  return result.when(success: (a) => a, failure: (_) => const []);
});
