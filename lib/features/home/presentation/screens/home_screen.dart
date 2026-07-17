import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/news_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/article.dart';
import '../providers/home_feed_provider.dart';
import '../providers/news_repository_provider.dart';
import '../widgets/breaking_news_carousel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(homeFeedProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(homeFeedProvider);
    final categories = ref.watch(categoriesProvider);

    final visibleFeed = _selectedCategoryFilter == null
        ? feedState.items
        : feedState.items
            .where((a) => a.categoryId == _selectedCategoryFilter)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulletin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(AppRoutes.search),
            tooltip: 'Search',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeFeedProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: _SectionLabel(text: 'BREAKING NEWS'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _BreakingNewsSection(),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        itemCount: categories.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ChoiceChip(
                              label: const Text('All'),
                              selected: _selectedCategoryFilter == null,
                              onSelected: (_) =>
                                  setState(() => _selectedCategoryFilter = null),
                            );
                          }
                          final category = categories[index - 1];
                          return CategoryChip(
                            category: category,
                            selected: _selectedCategoryFilter == category.id,
                            onTap: () => setState(() {
                              _selectedCategoryFilter =
                                  _selectedCategoryFilter == category.id
                                      ? null
                                      : category.id;
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _TrendingSection(),
                    const SizedBox(height: AppSpacing.lg),
                    const _RecommendedSection(),
                    const SizedBox(height: AppSpacing.lg),
                    const SectionHeader(title: 'Latest', icon: Icons.dynamic_feed_rounded),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
            if (feedState.isLoadingFirstPage)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList.builder(
                  itemCount: 3,
                  itemBuilder: (context, i) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: NewsCardSkeleton(),
                  ),
                ),
              )
            else if (feedState.hasError)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 320,
                  child: ErrorStateView(
                    message: feedState.failure!.message,
                    onRetry: () => ref.read(homeFeedProvider.notifier).loadFirstPage(),
                  ),
                ),
              )
            else if (visibleFeed.isEmpty)
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: EmptyStateView(
                    title: 'No stories in this category yet',
                    message: 'Try selecting a different category or check back later.',
                    icon: Icons.article_outlined,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList.separated(
                  itemCount: visibleFeed.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final article = visibleFeed[index];
                    return NewsCard(
                      article: article,
                      onTap: () =>
                          context.push(AppRoutes.articleDetailsPath(article.id)),
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: feedState.isLoadingNextPage
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : (!feedState.hasMore && visibleFeed.isNotEmpty)
                          ? Text(
                              'You\'re all caught up',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
    );
  }
}

class _BreakingNewsSection extends ConsumerWidget {
  const _BreakingNewsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakingAsync = ref.watch(breakingNewsProvider);
    return breakingAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: FeaturedCardSkeleton(),
      ),
      error: (err, st) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: ErrorStateView(
          onRetry: () => ref.invalidate(breakingNewsProvider),
        ),
      ),
      data: (articles) => BreakingNewsCarousel(articles: articles),
    );
  }
}

class _TrendingSection extends ConsumerWidget {
  const _TrendingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingNewsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Trending Now', icon: Icons.local_fire_department_rounded),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 230,
          child: trendingAsync.when(
            loading: () => _horizontalSkeletonList(),
            error: (err, st) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(trendingNewsProvider),
                child: const Text('Failed to load — tap to retry'),
              ),
            ),
            data: (articles) => _horizontalList(context, articles),
          ),
        ),
      ],
    );
  }
}

class _RecommendedSection extends ConsumerWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedAsync = ref.watch(recommendedNewsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recommended For You', icon: Icons.auto_awesome_rounded),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 230,
          child: recommendedAsync.when(
            loading: () => _horizontalSkeletonList(),
            error: (err, st) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(recommendedNewsProvider),
                child: const Text('Failed to load — tap to retry'),
              ),
            ),
            data: (articles) => _horizontalList(context, articles),
          ),
        ),
      ],
    );
  }
}

Widget _horizontalSkeletonList() {
  return ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    itemCount: 3,
    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
    itemBuilder: (context, i) => const CompactCardSkeleton(),
  );
}

Widget _horizontalList(BuildContext context, List<Article> articles) {
  if (articles.isEmpty) {
    return const Center(child: Text('Nothing to show right now'));
  }
  return ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    itemCount: articles.length,
    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
    itemBuilder: (context, index) {
      final article = articles[index];
      return NewsCard(
        article: article,
        variant: NewsCardVariant.compact,
        onTap: () => context.push(AppRoutes.articleDetailsPath(article.id)),
      );
    },
  );
}
