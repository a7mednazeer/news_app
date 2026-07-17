import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Wraps [Shimmer.fromColors] with theme-aware base/highlight colors so
/// every skeleton in the app looks consistent in both light and dark mode.
class AppShimmer extends StatelessWidget {
  final Widget child;
  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      highlightColor: isDark ? AppColors.darkBorder : Colors.white,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

class _Block extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const _Block({this.width, required this.height, this.radius = AppRadii.sm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Skeleton matching [NewsCardVariant.standard].
class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Block(height: 180, radius: 0, width: double.infinity),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Block(width: 120, height: 12),
                  SizedBox(height: 10),
                  _Block(width: double.infinity, height: 16),
                  SizedBox(height: 6),
                  _Block(width: 180, height: 16),
                  SizedBox(height: 10),
                  _Block(width: 90, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompactCardSkeleton extends StatelessWidget {
  const CompactCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        width: 220,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Block(height: 120, radius: 0, width: double.infinity),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _Block(width: double.infinity, height: 13),
                    SizedBox(height: 6),
                    _Block(width: 100, height: 13),
                    SizedBox(height: 8),
                    _Block(width: 80, height: 11),
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

class HorizontalCardSkeleton extends StatelessWidget {
  const HorizontalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            const _Block(width: 92, height: 92),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Block(width: 100, height: 12),
                  SizedBox(height: 8),
                  _Block(width: double.infinity, height: 14),
                  SizedBox(height: 6),
                  _Block(width: 150, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedCardSkeleton extends StatelessWidget {
  const FeaturedCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: const _Block(height: 220, width: double.infinity, radius: 0),
      ),
    );
  }
}

/// Convenience list of skeletons for a vertical feed loading state.
class NewsListSkeleton extends StatelessWidget {
  final int count;
  const NewsListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: NewsCardSkeleton(),
        ),
      ),
    );
  }
}
