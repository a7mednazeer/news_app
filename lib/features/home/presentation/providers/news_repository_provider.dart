import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/news_category.dart';
import '../../domain/repositories/news_repository.dart';

/// Single source of truth for the repository instance. Swapping mock data
/// for a real API means changing only [NewsRepositoryImpl]'s constructor
/// here — every screen and provider downstream is unaffected.
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl();
});

final categoriesProvider = Provider<List<NewsCategory>>((ref) {
  return ref.watch(newsRepositoryProvider).getCategories();
});
