import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/local_storage_service.dart';

enum AppThemeMode { light, dark, system }

class SettingsRepository {
  final LocalStorageService _storage;
  SettingsRepository(this._storage);

  AppThemeMode getThemeMode() {
    final value = _storage.getString(StorageKeys.themeMode);
    return AppThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      _storage.setString(StorageKeys.themeMode, mode.name);

  String getLocale() => _storage.getString(StorageKeys.locale) ?? 'en';

  Future<void> setLocale(String localeCode) =>
      _storage.setString(StorageKeys.locale, localeCode);

  bool getNotificationsEnabled() =>
      _storage.getBool(StorageKeys.notificationsEnabled, defaultValue: true);

  Future<void> setNotificationsEnabled(bool value) =>
      _storage.setBool(StorageKeys.notificationsEnabled, value);

  bool getBreakingNewsAlertsEnabled() => _storage.getBool(
        StorageKeys.breakingNewsAlertsEnabled,
        defaultValue: true,
      );

  Future<void> setBreakingNewsAlertsEnabled(bool value) =>
      _storage.setBool(StorageKeys.breakingNewsAlertsEnabled, value);

  double getTextSizeScale() =>
      _storage.getDouble(StorageKeys.textSizeScale, defaultValue: 1.0);

  Future<void> setTextSizeScale(double value) =>
      _storage.setDouble(StorageKeys.textSizeScale, value);
}
