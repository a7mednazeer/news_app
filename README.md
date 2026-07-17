# Bulletin — Premium Flutter News App

A production-ready, Clean Architecture Flutter news application built with
Riverpod, GoRouter, and Material 3. Redesigned from the original mockup into
a more editorial "Midnight Ink" visual identity (deep indigo + warm coral),
with premium features layered on top: breaking news carousel, trending &
recommended rails, reading progress, share/copy link, bookmarks, shimmer
loading, offline awareness, and full dark mode.

## Getting Started

```bash
flutter pub get
flutter run
```

Requires Flutter 3.22+ / Dart 3.4+ (Material 3, `Colors.withValues`, and
`SliverList.builder`/`.separated` all need a reasonably current stable
channel — run `flutter upgrade` first if you hit analyzer errors on these).

## Architecture

Feature-first Clean Architecture:

```
lib/
  core/                     # Cross-cutting: theme, router, shared widgets, utils
    constants/              # Colors, text styles, spacing/radii/durations, storage keys
    network/                # Result<T>/Failure (error handling), PaginatedState<T>
    providers/              # App-wide providers (local storage, connectivity)
    router/                 # GoRouter config + route path constants
    theme/                  # Material 3 ThemeData (light/dark)
    utils/                  # Formatters, LocalStorageService (SharedPreferences wrapper)
    widgets/                # NewsCard, shimmer skeletons, state views, snackbar, etc.

  features/
    splash/
    onboarding/
    home/
    categories/
    category_details/
    search/
    article_details/
    bookmarks/
    settings/
      data/
        datasources/        # Mock (or future remote) data sources
        models/              # JSON-serializable models extending domain entities
        repositories/        # Concrete repository implementations
      domain/
        entities/            # Framework-agnostic business objects
        repositories/         # Abstract repository contracts
      presentation/
        providers/           # Riverpod providers / StateNotifiers
        screens/              # Full-page widgets, wired to routes
        widgets/              # Feature-local reusable widgets
```

Each feature depends only on the layer below it (`presentation → domain ← data`),
and the UI only ever talks to `domain` contracts (e.g. `NewsRepository`), never
to `NewsRepositoryImpl` or `MockNewsDataSource` directly.

## Swapping Mock Data for a Real API

This is the one thing the whole project is organized around. To connect a
real News API:

1. Create `lib/features/home/data/datasources/news_remote_datasource.dart`
   with the **same method signatures** as `MockNewsDataSource`
   (`fetchArticles`, `fetchBreakingNews`, `search`, etc.), backed by
   `dio`/`http` and decoding into `ArticleModel.fromJson`.
2. In `NewsRepositoryImpl`, swap the `MockNewsDataSource` field for your new
   `NewsRemoteDataSource`, and map `DioException` → `NetworkFailure` /
   `ServerFailure` in the existing try/catch blocks.
3. That's it — every provider, screen, and widget above the repository is
   unaffected, because they only depend on the abstract `NewsRepository`
   interface and the plain `Article` / `NewsCategory` entities.

The same pattern applies to `BookmarksRepository`, `SettingsRepository`,
`OnboardingRepository`, and `RecentSearchesRepository` if you later want to
sync any of those to a backend instead of `SharedPreferences`.

## State Management

Riverpod throughout:
- `Provider` for stateless services/repositories.
- `StateNotifierProvider` for mutable state (bookmarks, settings, feeds).
- `FutureProvider` / `FutureProvider.family` for one-shot async reads
  (breaking news, trending, single article lookups).
- `StateNotifierProvider.family` for per-category paginated feeds.

`PaginatedState<T>` (in `core/network/paginated_state.dart`) is a single
reusable shape for every infinite-scroll + pull-to-refresh list in the app
(Home feed, Category feed, Search results), so pagination logic isn't
duplicated three times.

## Navigation

GoRouter with a `StatefulShellRoute.indexedStack` for the four bottom-nav
tabs (Home, Categories, Saved, Settings), each keeping its own navigation
stack. Article Details, Category Details, and Search are pushed as
root-level routes with custom fade/slide transitions. Onboarding gating is
handled entirely in the router's `redirect` callback, driven by
`onboardingCompleteProvider`.

## Images

Per project requirements, **no network image URLs are used anywhere**. All
article imagery renders from local assets (`assets/images/news_placeholder_1.png`
… `_6.png`, cycled per article) via the `AppImage` widget, which also
gracefully falls back to a branded gradient placeholder if an asset is ever
missing — the UI never shows Flutter's default red "asset not found" box.
Swap the files in `assets/images/` with real photography whenever you're
ready; no code changes needed.

## What's Implemented

- **Splash** — animated logo, auto-routes to onboarding or home.
- **Onboarding** — animated multi-select interest grid, persisted locally.
- **Home** — breaking news carousel (auto-advancing, parallax scale),
  category filter chips, Trending / Recommended horizontal rails, infinite-
  scroll "Latest" feed, pull-to-refresh, full loading/empty/error states.
- **Categories** — gradient category grid.
- **Category Details** — collapsing colored app bar, infinite-scroll feed
  scoped to that category.
- **Search** — debounced live search, recent searches (persisted, removable,
  clearable), infinite scroll results, empty/error states.
- **Article Details** — hero image transition, scroll-based reading progress
  bar, estimated reading time, view count, tags, share sheet, copy-link,
  bookmark toggle with micro-interaction, related articles rail.
- **Bookmarks** — swipe-to-remove with undo snackbar, resolved from
  persisted IDs via the repository.
- **Settings** — theme mode (light/dark/system), text size scaling
  (applied app-wide via `TextScaler`), language selector (persisted, ready
  for `flutter_localizations`/ARB wiring), notification toggles, manage-
  interests bottom sheet, about section.
- **Cross-cutting** — shimmer skeleton loading everywhere data is fetched,
  consistent empty/error states with retry, themed snackbars, offline
  banner (via `connectivity_plus`), full dark mode, Hero + slide/fade page
  transitions, reusable `NewsCard` in 4 layout variants used consistently
  across every screen.

## Known Scaffolding Notes

- Language switching persists a preference and is fully wired through
  Settings, but in-app strings are still English-only; plug in
  `flutter_localizations` + ARB files keyed off `localeProvider` to finish
  i18n.
- Push notification *toggles* are implemented and persisted; wiring them to
  actual FCM/APNs delivery is out of scope for a mock-data app and would be
  the next step once a backend exists.
- `assets/images/news_placeholder_*.png` and `assets/icons/app_icon.png` are
  simple generated placeholders — replace with real assets before shipping.
