import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/news_card.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../home/data/datasources/mock_categories.dart';
import '../providers/category_feed_provider.dart';

class CategoryDetailsScreen extends ConsumerStatefulWidget {
  final String categoryId;
  const CategoryDetailsScreen({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends ConsumerState<CategoryDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(categoryFeedProvider(widget.categoryId).notifier).loadNextPage();
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
    final category = categoryById(widget.categoryId);
    final feedState = ref.watch(categoryFeedProvider(widget.categoryId));
    final notifier = ref.read(categoryFeedProvider(widget.categoryId).notifier);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 140,
              backgroundColor: category.color,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(category.name),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [category.color, Color.lerp(category.color, Colors.black, 0.3)!],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      category.icon,
                      size: 96,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ),
            ),
            if (feedState.isLoadingFirstPage)
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
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
                  height: 400,
                  child: ErrorStateView(
                    message: feedState.failure!.message,
                    onRetry: notifier.loadFirstPage,
                  ),
                ),
              )
            else if (feedState.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 400,
                  child: EmptyStateView(
                    icon: category.icon,
                    title: 'No ${category.name} stories yet',
                    message: 'Check back soon for updates in this category.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList.separated(
                  itemCount: feedState.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final article = feedState.items[index];
                    return NewsCard(
                      article: article,
                      showCategory: false,
                      onTap: () => context.push(AppRoutes.articleDetailsPath(article.id)),
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
