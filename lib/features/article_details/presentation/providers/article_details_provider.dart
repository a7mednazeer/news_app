import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/result.dart';
import '../../../home/domain/entities/article.dart';
import '../../../home/presentation/providers/news_repository_provider.dart';

final articleByIdProvider =
    FutureProvider.family<Result<Article>, String>((ref, articleId) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getArticleById(articleId);
});

final relatedArticlesProvider =
    FutureProvider.family<List<Article>, String>((ref, articleId) async {
  final repo = ref.watch(newsRepositoryProvider);
  final result = await repo.getRelatedArticles(articleId);
  return result.when(success: (a) => a, failure: (_) => const []);
});
