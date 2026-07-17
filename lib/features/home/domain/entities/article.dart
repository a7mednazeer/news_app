import 'package:equatable/equatable.dart';

/// Core, framework-agnostic representation of a news article.
///
/// This is the "domain" entity — it has no knowledge of JSON, Dio, or any
/// data source. [ArticleModel] (in the data layer) extends this and adds
/// serialization, so swapping mock data for a real API later only touches
/// the data layer, never the UI or providers.
class Article extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String source;
  final String categoryId;
  final String imageAsset;
  final DateTime publishedAt;
  final String author;
  final int readingTimeMinutes;
  final bool isBreaking;
  final int viewCount;
  final List<String> tags;

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.source,
    required this.categoryId,
    required this.imageAsset,
    required this.publishedAt,
    required this.author,
    required this.readingTimeMinutes,
    this.isBreaking = false,
    this.viewCount = 0,
    this.tags = const [],
  });

  Article copyWith({
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
    return Article(
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

  @override
  List<Object?> get props => [
        id,
        title,
        summary,
        content,
        source,
        categoryId,
        imageAsset,
        publishedAt,
        author,
        readingTimeMinutes,
        isBreaking,
        viewCount,
        tags,
      ];
}
