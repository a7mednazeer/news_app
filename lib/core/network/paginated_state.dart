import 'package:equatable/equatable.dart';
import 'result.dart';

/// Generic state for any infinite-scrolling, pull-to-refreshable list
/// (home feed, category feed, search results). Reused by every feature's
/// list notifier so loading/error/pagination logic isn't duplicated.
class PaginatedState<T> extends Equatable {
  final List<T> items;
  final int page;
  final bool isLoadingFirstPage;
  final bool isLoadingNextPage;
  final bool isRefreshing;
  final bool hasMore;
  final Failure? failure;

  const PaginatedState({
    this.items = const [],
    this.page = 0,
    this.isLoadingFirstPage = false,
    this.isLoadingNextPage = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.failure,
  });

  bool get isEmpty => items.isEmpty && !isLoadingFirstPage && failure == null;
  bool get hasError => failure != null && items.isEmpty;

  PaginatedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? isLoadingFirstPage,
    bool? isLoadingNextPage,
    bool? isRefreshing,
    bool? hasMore,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoadingFirstPage: isLoadingFirstPage ?? this.isLoadingFirstPage,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props =>
      [items, page, isLoadingFirstPage, isLoadingNextPage, isRefreshing, hasMore, failure];
}
