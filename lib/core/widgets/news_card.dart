import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/bookmarks/presentation/providers/bookmarks_provider.dart';
import '../../features/home/data/datasources/mock_categories.dart';
import '../../features/home/domain/entities/article.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';
import 'app_image.dart';
import 'bookmark_button.dart';

enum NewsCardVariant { featured, standard, compact, horizontal }

/// A single, configurable news card used throughout the app so every list
/// (home feed, category feed, search results, bookmarks, related articles)
/// renders with 100% visual consistency.
class NewsCard extends ConsumerWidget {
  final Article article;
  final NewsCardVariant variant;
  final VoidCallback onTap;
  final bool showCategory;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    this.variant = NewsCardVariant.standard,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(
      bookmarksProvider.select((ids) => ids.contains(article.id)),
    );
    Future<void> toggleBookmark() =>
        ref.read(bookmarksProvider.notifier).toggle(article.id);

    switch (variant) {
      case NewsCardVariant.featured:
        return _FeaturedCard(
          article: article,
          onTap: onTap,
          isBookmarked: isBookmarked,
          onBookmarkToggle: toggleBookmark,
        );
      case NewsCardVariant.compact:
        return _CompactCard(article: article, onTap: onTap);
      case NewsCardVariant.horizontal:
        return _HorizontalCard(
          article: article,
          onTap: onTap,
          isBookmarked: isBookmarked,
          onBookmarkToggle: toggleBookmark,
        );
      case NewsCardVariant.standard:
        return _StandardCard(
          article: article,
          onTap: onTap,
          isBookmarked: isBookmarked,
          onBookmarkToggle: toggleBookmark,
          showCategory: showCategory,
        );
    }
  }
}

class _CategoryPill extends StatelessWidget {
  final String categoryId;
  const _CategoryPill({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final category = categoryById(categoryId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        category.name.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Article article;
  final Color? color;
  const _MetaRow({required this.article, this.color});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        );
    return Row(
      children: [
        Flexible(
          child: Text(
            article.source,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        Text('  •  ', style: style),
        Text(formatRelativeTime(article.publishedAt), style: style),
      ],
    );
  }
}

/// Big hero-style card for breaking news carousels.
class _FeaturedCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  const _FeaturedCard({
    required this.article,
    required this.onTap,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'article_image_${article.id}',
              child: AppImage(assetPath: article.imageAsset),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: Row(
                children: [
                  if (article.isBreaking)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                  _CategoryPill(categoryId: article.categoryId),
                ],
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: BookmarkButton(
                isBookmarked: isBookmarked,
                onPressed: onBookmarkToggle,
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _MetaRow(
                    article: article,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Default vertical card used in feed lists.
class _StandardCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final bool showCategory;

  const _StandardCard({
    required this.article,
    required this.onTap,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.showCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'article_image_${article.id}',
                    child: AppImage(
                      assetPath: article.imageAsset,
                      height: 180,
                      width: double.infinity,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadii.lg),
                      ),
                    ),
                  ),
                  if (showCategory)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: _CategoryPill(categoryId: article.categoryId),
                    ),
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: BookmarkButton(
                      isBookmarked: isBookmarked,
                      onPressed: onBookmarkToggle,
                      size: 36,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetaRow(article: article),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline),
                        const SizedBox(width: 4),
                        Text(
                          formatReadingTime(article.readingTimeMinutes),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small square-thumbnail card for trending/recommended horizontal rails.
class _CompactCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _CompactCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Material(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'article_image_${article.id}',
                  child: AppImage(
                    assetPath: article.imageAsset,
                    height: 120,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadii.md),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      _MetaRow(article: article),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thumbnail-left, text-right row card — used in Search results.
class _HorizontalCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  const _HorizontalCard({
    required this.article,
    required this.onTap,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'article_image_${article.id}',
                child: AppImage(
                  assetPath: article.imageAsset,
                  width: 92,
                  height: 92,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetaRow(article: article),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              BookmarkButton(
                isBookmarked: isBookmarked,
                onPressed: onBookmarkToggle,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
