import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Generic centered state view (icon + title + message + optional action)
/// used for empty and error states across every screen, so the app never
/// shows a bare "no data" text or an unhandled red error screen.
class AppStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const AppStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor ?? scheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    this.title = 'Nothing here yet',
    this.message = 'There\'s no content to show right now.',
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    this.message = 'Something went wrong. Please try again.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.cloud_off_rounded,
      title: 'Couldn\'t load content',
      message: message,
      actionLabel: 'Try Again',
      onAction: onRetry,
      iconColor: Theme.of(context).colorScheme.error,
    );
  }
}

class NoSearchResultsView extends StatelessWidget {
  final String query;
  const NoSearchResultsView({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.search_off_rounded,
      title: 'No results found',
      message: 'We couldn\'t find anything matching "$query".\nTry a different keyword.',
    );
  }
}
