import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/paginated_state.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../home/domain/entities/article.dart';
import '../../../home/presentation/providers/news_repository_provider.dart';
import '../../data/repositories/recent_searches_repository.dart';

final recentSearchesRepositoryProvider = Provider<RecentSearchesRepository>((ref) {
  return RecentSearchesRepository(ref.watch(localStorageServiceProvider));
});

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  final RecentSearchesRepository _repository;
  RecentSearchesNotifier(this._repository) : super(_repository.getRecentSearches());

  Future<void> add(String query) async {
    await _repository.addSearch(query);
    state = _repository.getRecentSearches();
  }

  Future<void> remove(String query) async {
    await _repository.removeSearch(query);
    state = _repository.getRecentSearches();
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    state = [];
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier(ref.watch(recentSearchesRepositoryProvider));
});

/// Search results state: pairs the current query with its [PaginatedState],
/// since results must reset whenever the query changes (unlike home/
/// category feeds, which never change "context").
class SearchState {
  final String query;
  final PaginatedState<Article> results;

  const SearchState({
    this.query = '',
    this.results = const PaginatedState(items: [], hasMore: false),
  });

  SearchState copyWith({String? query, PaginatedState<Article>? results}) {
    return SearchState(query: query ?? this.query, results: results ?? this.results);
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  Timer? _debounce;

  SearchNotifier(this._ref) : super(const SearchState());

  void onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }
    state = state.copyWith(
      query: query,
      results: const PaginatedState(isLoadingFirstPage: true),
    );
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    final repo = _ref.read(newsRepositoryProvider);
    final result = await repo.searchArticles(query, page: 0);
    if (state.query != query) return; // stale response guard
    result.when(
      success: (articles) => state = state.copyWith(
        results: PaginatedState(
          items: articles,
          page: 1,
          hasMore: articles.isNotEmpty,
        ),
      ),
      failure: (f) => state = state.copyWith(
        results: PaginatedState(failure: f),
      ),
    );
  }

  Future<void> loadNextPage() async {
    final r = state.results;
    if (r.isLoadingNextPage || !r.hasMore || state.query.isEmpty) return;
    state = state.copyWith(results: r.copyWith(isLoadingNextPage: true));
    final repo = _ref.read(newsRepositoryProvider);
    final result = await repo.searchArticles(state.query, page: r.page);
    result.when(
      success: (articles) => state = state.copyWith(
        results: state.results.copyWith(
          items: [...state.results.items, ...articles],
          page: state.results.page + 1,
          isLoadingNextPage: false,
          hasMore: articles.isNotEmpty,
        ),
      ),
      failure: (f) => state = state.copyWith(
        results: state.results.copyWith(isLoadingNextPage: false),
      ),
    );
  }

  void submitSearch() {
    if (state.query.trim().isEmpty) return;
    _ref.read(recentSearchesProvider.notifier).add(state.query.trim());
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});
