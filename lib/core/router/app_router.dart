import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/article_details/presentation/screens/article_details_screen.dart';
import '../../features/bookmarks/presentation/screens/bookmarks_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/category_details/presentation/screens/category_details_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../widgets/main_shell.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// The single [GoRouter] instance for the app.
///
/// Structure:
/// - `/splash` — one-time animated splash, then redirects.
/// - `/onboarding` — interest picker, shown only before completion.
/// - A [StatefulShellRoute] hosting Home / Categories / Bookmarks / Settings
///   behind a persistent bottom navigation bar ([MainShell]), each branch
///   keeping its own navigation stack so back-swiping between tabs feels
///   native.
/// - Full-screen pushed routes for Article Details, Category Details, and
///   Search, which slide in above the shell.
final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final isSplash = path == AppRoutes.splash;
      final isOnboarding = path == AppRoutes.onboarding;

      if (isSplash) return null; // splash screen handles its own timing

      if (!onboardingComplete && !isOnboarding) {
        return AppRoutes.onboarding;
      }
      if (onboardingComplete && isOnboarding) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SearchScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.articleDetails,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final articleId = state.pathParameters['articleId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ArticleDetailsScreen(articleId: articleId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween(begin: const Offset(0, 0.05), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: animation.drive(tween), child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.categoryDetails,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CategoryDetailsScreen(categoryId: categoryId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.bookmarks,
                builder: (context, state) => const BookmarksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
