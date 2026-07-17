import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../../features/home/domain/entities/news_category.dart';

/// Animated pill chip used for category selection (onboarding, home filter
/// bar, categories screen). Smoothly animates color/scale on selection.
class CategoryChip extends StatelessWidget {
  final NewsCategory category;
  final bool selected;
  final VoidCallback onTap;
  final bool showIcon;

  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? category.color : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: selected ? category.color : scheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                category.icon,
                size: 16,
                color: selected ? Colors.white : scheme.onSurface,
              ),
              const SizedBox(width: 6),
            ],
            AnimatedDefaultTextStyle(
              duration: AppDurations.fast,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: selected ? Colors.white : scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
              child: Text(category.name),
            ),
          ],
        ),
      ),
    );
  }
}
