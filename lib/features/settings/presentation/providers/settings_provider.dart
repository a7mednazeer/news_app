import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(localStorageServiceProvider));
});

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  final SettingsRepository _repository;
  ThemeModeNotifier(this._repository) : super(_repository.getThemeMode());

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    await _repository.setThemeMode(mode);
  }

  ThemeMode get flutterThemeMode => switch (state) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      };
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(settingsRepositoryProvider));
});

class LocaleNotifier extends StateNotifier<String> {
  final SettingsRepository _repository;
  LocaleNotifier(this._repository) : super(_repository.getLocale());

  Future<void> setLocale(String code) async {
    state = code;
    await _repository.setLocale(code);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier(ref.watch(settingsRepositoryProvider));
});

class NotificationsNotifier extends StateNotifier<bool> {
  final SettingsRepository _repository;
  NotificationsNotifier(this._repository)
      : super(_repository.getNotificationsEnabled());

  Future<void> toggle(bool value) async {
    state = value;
    await _repository.setNotificationsEnabled(value);
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  return NotificationsNotifier(ref.watch(settingsRepositoryProvider));
});

class BreakingAlertsNotifier extends StateNotifier<bool> {
  final SettingsRepository _repository;
  BreakingAlertsNotifier(this._repository)
      : super(_repository.getBreakingNewsAlertsEnabled());

  Future<void> toggle(bool value) async {
    state = value;
    await _repository.setBreakingNewsAlertsEnabled(value);
  }
}

final breakingAlertsEnabledProvider =
    StateNotifierProvider<BreakingAlertsNotifier, bool>((ref) {
  return BreakingAlertsNotifier(ref.watch(settingsRepositoryProvider));
});

class TextScaleNotifier extends StateNotifier<double> {
  final SettingsRepository _repository;
  TextScaleNotifier(this._repository)
      : super(_repository.getTextSizeScale());

  Future<void> setScale(double value) async {
    state = value;
    await _repository.setTextSizeScale(value);
  }
}

final textScaleProvider =
    StateNotifierProvider<TextScaleNotifier, double>((ref) {
  return TextScaleNotifier(ref.watch(settingsRepositoryProvider));
});

/// Supported in-app languages (mock i18n — strings themselves aren't
/// re-translated in this scaffold, but the preference is fully wired and
/// ready for `flutter_localizations` / ARB files to plug into).
const Map<String, String> kSupportedLocales = {
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'ar': 'العربية',
};
