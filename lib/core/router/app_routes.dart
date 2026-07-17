/// Centralized route path + name constants consumed by [AppRouter] and by
/// every `context.go` / `context.push` call, avoiding hardcoded path
/// strings scattered across the codebase.
abstract class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // Shell (bottom nav) branches
  static const String home = '/home';
  static const String categories = '/categories';
  static const String bookmarks = '/bookmarks';
  static const String settings = '/settings';

  // Pushed routes
  static const String categoryDetails = '/categories/:categoryId';
  static const String articleDetails = '/article/:articleId';
  static const String search = '/search';

  static String categoryDetailsPath(String categoryId) =>
      '/categories/$categoryId';

  static String articleDetailsPath(String articleId) =>
      '/article/$articleId';
}
