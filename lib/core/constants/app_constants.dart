/// App-wide non-color, non-text constants: spacing scale, radii, animation
/// durations, storage keys, and pagination configuration. Centralizing these
/// avoids magic numbers scattered across widgets (DRY).
abstract class AppSpacing {
  AppSpacing._();
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

abstract class AppRadii {
  AppRadii._();
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

abstract class AppDurations {
  AppDurations._();
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 2200);
  static const Duration snackbar = Duration(milliseconds: 2600);
}

/// Keys used for local persistence via SharedPreferences.
abstract class StorageKeys {
  StorageKeys._();
  static const String onboardingComplete = 'onboarding_complete';
  static const String selectedCategories = 'selected_categories';
  static const String bookmarkedArticles = 'bookmarked_articles';
  static const String themeMode = 'theme_mode';
  static const String locale = 'app_locale';
  static const String recentSearches = 'recent_searches';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String breakingNewsAlertsEnabled = 'breaking_news_alerts';
  static const String textSizeScale = 'text_size_scale';
}

abstract class PaginationConfig {
  PaginationConfig._();
  static const int pageSize = 8;
  static const Duration simulatedNetworkDelay = Duration(milliseconds: 700);
  static const Duration simulatedRefreshDelay = Duration(milliseconds: 900);
}

abstract class AppInfo {
  AppInfo._();
  static const String appName = 'Bulletin';
  static const String tagline = 'Your world, well told.';
  static const String appVersion = '1.0.0';
}
