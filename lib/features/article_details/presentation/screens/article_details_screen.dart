import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bookmark_button.dart';
import '../../../../core/widgets/news_card.dart';
import '../../../../core/widgets/reading_progress_bar.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/utils/formatters.dart';
import '../../../bookmarks/presentation/providers/bookmarks_provider.dart';
import '../../../home/data/datasources/mock_categories.dart';
import '../../../home/domain/entities/article.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/article_details_provider.dart';

class ArticleDetailsScreen extends ConsumerStatefulWidget {
  final String articleId;
  const ArticleDetailsScreen({super.key, required this.articleId});

  @override
  ConsumerState<ArticleDetailsScreen> createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends ConsumerState<ArticleDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    setState(() {
      _progress = max <= 0 ? 1.0 : (current / max).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProgress);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncResult = ref.watch(articleByIdProvider(widget.articleId));

    return Scaffold(
      body: asyncResult.when(
        loading: () => const _ArticleLoadingView(),
        error: (err, st) => _ArticleErrorView(
          message: 'Something went wrong loading this article.',
          onRetry: () => ref.invalidate(articleByIdProvider(widget.articleId)),
        ),
        data: (result) => result.when(
          success: (article) => _ArticleContent(
            article: article,
            scrollController: _scrollController,
            progress: _progress,
          ),
          failure: (failure) => _ArticleErrorView(
            message: failure.message,
            onRetry: () => ref.invalidate(articleByIdProvider(widget.articleId)),
          ),
        ),
      ),
    );
  }
}

class _ArticleLoadingView extends StatelessWidget {
  const _ArticleLoadingView();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FeaturedCardSkeleton(),
            SizedBox(height: AppSpacing.lg),
            NewsListSkeleton(count: 1),
          ],
        ),
      ),
    );
  }
}

class _ArticleErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ArticleErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Expanded(child: ErrorStateView(message: message, onRetry: onRetry)),
        ],
      ),
    );
  }
}

class _ArticleContent extends ConsumerWidget {
  final Article article;
  final ScrollController scrollController;
  final double progress;

  const _ArticleContent({
    required this.article,
    required this.scrollController,
    required this.progress,
  });

  Future<void> _handleShare(BuildContext context) async {
    await SharePlus.instance.share(
      ShareParams(
        text: '${article.title}\n\nRead more on Bulletin: bulletin://article/${article.id}',
        subject: article.title,
      ),
    );
  }

  Future<void> _handleCopyLink(BuildContext context) async {
    final link = 'https://bulletin.news/article/${article.id}';
    await Clipboard.setData(ClipboardData(text: link));
    if (context.mounted) {
      AppSnackbar.show(context, message: 'Link copied to clipboard', type: SnackType.success);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(
      bookmarksProvider.select((ids) => ids.contains(article.id)),
    );
    final category = categoryById(article.categoryId);
    final textScale = ref.watch(textScaleProvider);
    final related = ref.watch(relatedArticlesProvider(article.id));

    return Stack(
      children: [
        CustomScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 300,
              leading: _CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                _CircleIconButton(
                  icon: Icons.ios_share_rounded,
                  onTap: () => _handleShare(context),
                ),
                const SizedBox(width: AppSpacing.xs),
                _CircleIconButton(
                  icon: Icons.link_rounded,
                  onTap: () => _handleCopyLink(context),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'article_image_${article.id}',
                  child: AppImage(assetPath: article.imageAsset),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: category.color,
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                            ),
                            child: Text(
                              category.name.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          if (article.isBreaking)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(AppRadii.pill),
                              ),
                              child: const Text(
                                'BREAKING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: (26.0) * textScale,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Text(
                              article.author.isNotEmpty ? article.author[0] : '?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(article.author, style: Theme.of(context).textTheme.titleMedium),
                                Text(
                                  '${article.source} • ${formatRelativeTime(article.publishedAt)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          BookmarkButton(
                            isBookmarked: isBookmarked,
                            onPressed: () =>
                                ref.read(bookmarksProvider.notifier).toggle(article.id),
                            background: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 16, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            formatReadingTime(article.readingTimeMinutes),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Icon(Icons.visibility_rounded,
                              size: 16, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            formatViewCount(article.viewCount),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const Divider(height: AppSpacing.xxl),
                      Text(
                        article.content,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: (16.0) * textScale,
                              height: 1.6,
                            ),
                      ),
                      if (article.tags.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: article.tags
                              .map((tag) => Chip(label: Text('#$tag')))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _handleShare(context),
                              icon: const Icon(Icons.ios_share_rounded, size: 18),
                              label: const Text('Share'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _handleCopyLink(context),
                              icon: const Icon(Icons.link_rounded, size: 18),
                              label: const Text('Copy Link'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text('Related Articles',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    related.when(
                      loading: () => SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          itemCount: 3,
                          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (context, i) => const CompactCardSkeleton(),
                        ),
                      ),
                      error: (e, st) => const SizedBox.shrink(),
                      data: (articles) {
                        if (articles.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: Text(
                              'No related articles found.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        }
                        return SizedBox(
                          height: 230,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            itemCount: articles.length,
                            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final related = articles[index];
                              return NewsCard(
                                article: related,
                                variant: NewsCardVariant.compact,
                                onTap: () => context.pushReplacement(
                                  AppRoutes.articleDetailsPath(related.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: ReadingProgressBar(progress: progress),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 20),
          onPressed: onTap,
        ),
      ),
    );
  }
}
