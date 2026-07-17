import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/news_card.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(searchProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _runSearch(String value) {
    ref.read(searchProvider.notifier)
      ..onQueryChanged(value)
      ..submitSearch();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final hasQuery = searchState.query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.md,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          onChanged: (value) => ref.read(searchProvider.notifier).onQueryChanged(value),
          onSubmitted: _runSearch,
          decoration: InputDecoration(
            hintText: 'Search articles, topics, sources...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchProvider.notifier).clear();
                      setState(() {});
                    },
                  ),
          ),
          onTap: () => setState(() {}),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: !hasQuery
          ? _RecentSearchesView(
              recentSearches: recentSearches,
              onTapItem: (q) {
                _controller.text = q;
                _runSearch(q);
              },
            )
          : _SearchResultsView(scrollController: _scrollController),
    );
  }
}

class _RecentSearchesView extends ConsumerWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onTapItem;

  const _RecentSearchesView({required this.recentSearches, required this.onTapItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (recentSearches.isEmpty) {
      return const EmptyStateView(
        icon: Icons.history_rounded,
        title: 'Search Bulletin',
        message: 'Find articles by keyword, topic, or source.\nYour recent searches will appear here.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Searches', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => ref.read(recentSearchesProvider.notifier).clearAll(),
              child: const Text('Clear all'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ...recentSearches.map(
          (q) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history_rounded),
            title: Text(q),
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () => ref.read(recentSearchesProvider.notifier).remove(q),
            ),
            onTap: () => onTapItem(q),
          ),
        ),
      ],
    );
  }
}

class _SearchResultsView extends ConsumerWidget {
  final ScrollController scrollController;
  const _SearchResultsView({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final results = searchState.results;

    if (results.isLoadingFirstPage) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) => const HorizontalCardSkeleton(),
      );
    }
    if (results.hasError) {
      return ErrorStateView(
        message: results.failure!.message,
        onRetry: () => ref.read(searchProvider.notifier).onQueryChanged(searchState.query),
      );
    }
    if (results.isEmpty) {
      return NoSearchResultsView(query: searchState.query);
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: results.items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == results.items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: results.isLoadingNextPage
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        }
        final article = results.items[index];
        return NewsCard(
          article: article,
          variant: NewsCardVariant.horizontal,
          onTap: () => context.push(AppRoutes.articleDetailsPath(article.id)),
        );
      },
    );
  }
}
