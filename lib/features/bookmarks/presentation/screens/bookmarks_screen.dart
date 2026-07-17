import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/news_card.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../providers/bookmarks_provider.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedAsync = ref.watch(bookmarkedArticlesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Articles')),
      body: bookmarkedAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) => const NewsCardSkeleton(),
        ),
        error: (err, st) => ErrorStateView(
          onRetry: () => ref.invalidate(bookmarkedArticlesProvider),
        ),
        data: (articles) {
          if (articles.isEmpty) {
            return const EmptyStateView(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved articles yet',
              message: 'Tap the bookmark icon on any article to save it here for later.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: articles.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final article = articles[index];
              return Dismissible(
                key: ValueKey(article.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(bookmarksProvider.notifier).remove(article.id);
                  AppSnackbar.show(
                    context,
                    message: 'Removed from Saved',
                    type: SnackType.info,
                    actionLabel: 'Undo',
                    onAction: () => ref.read(bookmarksProvider.notifier).toggle(article.id),
                  );
                },
                child: NewsCard(
                  article: article,
                  onTap: () => context.push(AppRoutes.articleDetailsPath(article.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
