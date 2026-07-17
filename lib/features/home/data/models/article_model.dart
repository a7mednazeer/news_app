import '../../domain/entities/article.dart';

/// Data-layer representation of [Article].
///
/// Adds `fromJson` / `toJson` so that once a real News API is wired up,
/// only [NewsRemoteDataSource] needs to change — repositories, providers,
/// and UI keep working against the plain [Article] entity untouched.
class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.summary,
    required super.content,
    required super.source,
    required super.categoryId,
    required super.imageAsset,
    required super.publishedAt,
    required super.author,
    required super.readingTimeMinutes,
    super.isBreaking,
    super.viewCount,
    super.tags,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      source: json['source'] as String,
      categoryId: json['categoryId'] as String,
      imageAsset: json['imageAsset'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      author: json['author'] as String,
      readingTimeMinutes: json['readingTimeMinutes'] as int,
      isBreaking: json['isBreaking'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'source': source,
      'categoryId': categoryId,
      'imageAsset': imageAsset,
      'publishedAt': publishedAt.toIso8601String(),
      'author': author,
      'readingTimeMinutes': readingTimeMinutes,
      'isBreaking': isBreaking,
      'viewCount': viewCount,
      'tags': tags,
    };
  }

  @override
  ArticleModel copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? source,
    String? categoryId,
    String? imageAsset,
    DateTime? publishedAt,
    String? author,
    int? readingTimeMinutes,
    bool? isBreaking,
    int? viewCount,
    List<String>? tags,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      source: source ?? this.source,
      categoryId: categoryId ?? this.categoryId,
      imageAsset: imageAsset ?? this.imageAsset,
      publishedAt: publishedAt ?? this.publishedAt,
      author: author ?? this.author,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      isBreaking: isBreaking ?? this.isBreaking,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
    );
  }

  factory ArticleModel.fromEntity(Article article) => ArticleModel(
        id: article.id,
        title: article.title,
        summary: article.summary,
        content: article.content,
        source: article.source,
        categoryId: article.categoryId,
        imageAsset: article.imageAsset,
        publishedAt: article.publishedAt,
        author: article.author,
        readingTimeMinutes: article.readingTimeMinutes,
        isBreaking: article.isBreaking,
        viewCount: article.viewCount,
        tags: article.tags,
      );
}
