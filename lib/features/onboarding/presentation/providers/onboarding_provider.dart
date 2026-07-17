import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.watch(localStorageServiceProvider));
});

/// Drives GoRouter's redirect logic: while `false`, the user is routed to
/// `/onboarding` instead of `/home`.
class OnboardingCompleteNotifier extends StateNotifier<bool> {
  final OnboardingRepository _repository;
  OnboardingCompleteNotifier(this._repository)
      : super(_repository.isOnboardingComplete());

  Future<void> complete(List<String> selectedCategoryIds) async {
    await _repository.completeOnboarding(selectedCategoryIds);
    state = true;
  }
}

final onboardingCompleteProvider =
    StateNotifierProvider<OnboardingCompleteNotifier, bool>((ref) {
  return OnboardingCompleteNotifier(ref.watch(onboardingRepositoryProvider));
});

/// Transient in-memory selection state while the user is picking interests
/// on the onboarding screen (persisted only once they confirm).
class InterestSelectionNotifier extends StateNotifier<Set<String>> {
  InterestSelectionNotifier() : super({});

  void toggle(String categoryId) {
    final next = {...state};
    if (next.contains(categoryId)) {
      next.remove(categoryId);
    } else {
      next.add(categoryId);
    }
    state = next;
  }
}

final interestSelectionProvider =
    StateNotifierProvider<InterestSelectionNotifier, Set<String>>((ref) {
  return InterestSelectionNotifier();
});
