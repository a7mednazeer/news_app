import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../home/presentation/providers/news_repository_provider.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(interestSelectionProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Pick your interests',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose a few topics and we\'ll tailor your feed. '
                'You can always change this later in Settings.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selected.contains(category.id);
                    return _InterestTile(
                      name: category.name,
                      icon: category.icon,
                      color: category.color,
                      selected: isSelected,
                      onTap: () => ref
                          .read(interestSelectionProvider.notifier)
                          .toggle(category.id),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _finish(context, ref, skip: true),
                        child: const Text('Skip for now'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: selected.isEmpty
                            ? null
                            : () => _finish(context, ref, skip: false),
                        child: Text(
                          selected.isEmpty
                              ? 'Select at least one'
                              : 'Continue (${selected.length})',
                        ),
                      ),
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

  Future<void> _finish(BuildContext context, WidgetRef ref, {required bool skip}) async {
    final selected = ref.read(interestSelectionProvider);
    await ref.read(onboardingCompleteProvider.notifier).complete(
          skip ? const [] : selected.toList(),
        );
    if (context.mounted) context.go(AppRoutes.home);
  }
}

class _InterestTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _InterestTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 36,
                    color: selected ? Colors.white : color,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: selected ? Colors.white : color,
                        ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
