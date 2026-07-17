import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/local_storage_service.dart';

class OnboardingRepository {
  final LocalStorageService _storage;
  OnboardingRepository(this._storage);

  bool isOnboardingComplete() =>
      _storage.getBool(StorageKeys.onboardingComplete);

  Future<void> completeOnboarding(List<String> selectedCategoryIds) async {
    await _storage.setStringList(
      StorageKeys.selectedCategories,
      selectedCategoryIds,
    );
    await _storage.setBool(StorageKeys.onboardingComplete, true);
  }

  List<String> getSelectedCategoryIds() =>
      _storage.getStringList(StorageKeys.selectedCategories);
}
