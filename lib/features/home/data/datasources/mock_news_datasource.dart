import 'dart:math';
import '../../../../core/constants/app_constants.dart';
import '../models/article_model.dart';
import 'mock_categories.dart';

/// Simulates a remote News API data source.
///
/// This is the ONLY file that should need to change when a real backend is
/// introduced: replace the body of these methods with `dio.get(...)` calls
/// that decode into [ArticleModel.fromJson], keep the method signatures
/// identical, and every repository/provider/screen above it keeps working.
class MockNewsDataSource {
  MockNewsDataSource._internal() {
    _articles = _generateArticles();
  }

  static final MockNewsDataSource instance = MockNewsDataSource._internal();

  late final List<ArticleModel> _articles;

  List<ArticleModel> get allArticles => _articles;

  Future<List<ArticleModel>> fetchArticles({
    required int page,
    int pageSize = PaginationConfig.pageSize,
    String? categoryId,
  }) async {
    await Future.delayed(PaginationConfig.simulatedNetworkDelay);
    final filtered = categoryId == null
        ? _articles
        : _articles.where((a) => a.categoryId == categoryId).toList();
    final start = page * pageSize;
    if (start >= filtered.length) return [];
    final end = min(start + pageSize, filtered.length);
    return filtered.sublist(start, end);
  }

  Future<List<ArticleModel>> fetchBreakingNews() async {
    await Future.delayed(PaginationConfig.simulatedNetworkDelay);
    return _articles.where((a) => a.isBreaking).take(6).toList();
  }

  Future<List<ArticleModel>> fetchTrending() async {
    await Future.delayed(PaginationConfig.simulatedNetworkDelay);
    final sorted = [..._articles]
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return sorted.take(10).toList();
  }

  Future<List<ArticleModel>> fetchRecommended() async {
    await Future.delayed(PaginationConfig.simulatedNetworkDelay);
    final list = [..._articles]..shuffle(Random(7));
    return list.take(8).toList();
  }

  Future<List<ArticleModel>> fetchPopular() async {
    await Future.delayed(PaginationConfig.simulatedNetworkDelay);
    final sorted = [..._articles]
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return sorted.skip(3).take(8).toList();
  }

  Future<ArticleModel?> fetchArticleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _articles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ArticleModel>> fetchRelated(String articleId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final source = _articles.firstWhere((a) => a.id == articleId);
    return _articles
        .where((a) => a.categoryId == source.categoryId && a.id != articleId)
        .take(4)
        .toList();
  }

  Future<List<ArticleModel>> fetchByIds(Set<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _articles.where((a) => ids.contains(a.id)).toList();
  }

  Future<List<ArticleModel>> search(String query, {int page = 0}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    final matches = _articles.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.summary.toLowerCase().contains(q) ||
          a.tags.any((t) => t.toLowerCase().contains(q)) ||
          categoryById(a.categoryId).name.toLowerCase().contains(q);
    }).toList();
    final start = page * PaginationConfig.pageSize;
    if (start >= matches.length) return [];
    final end = min(start + PaginationConfig.pageSize, matches.length);
    return matches.sublist(start, end);
  }

  // --------------------------------------------------------------------
  // Mock content generation
  // --------------------------------------------------------------------

  static const List<String> _sources = [
    'BBC News',
    'Reuters',
    'Associated Press',
    'Al Jazeera',
    'The Guardian',
    'Bloomberg',
    'AP News',
    'NPR',
  ];

  static const List<String> _authors = [
    'Amelia Brooks',
    'Daniel Osei',
    'Layla Haddad',
    'Marco Rinaldi',
    'Priya Sharma',
    'Noah Fitzgerald',
    'Sofia Alvarez',
    'James Whitfield',
  ];

  static final Map<String, List<String>> _headlinesByCategory = {
    'sports': [
      'Why are football\'s biggest clubs starting a new tournament?',
      'Underdog team stuns champions in extra-time thriller',
      'Star striker signs record-breaking transfer deal',
      'National team unveils new training facility ahead of finals',
      'Marathon record broken by three seconds in dramatic finish',
      'Young prodigy becomes youngest player to debut this season',
      'Coach faces pressure after string of disappointing results',
      'Fans divided over controversial new tournament format',
    ],
    'politics': [
      'Lawmakers debate sweeping reform bill into the night',
      'Coalition talks continue as deadline looms',
      'New policy aims to overhaul national infrastructure spending',
      'Opposition calls for inquiry into spending decisions',
      'Regional elections signal shifting voter priorities',
      'Diplomatic summit ends with cautious optimism',
      'Cabinet reshuffle brings fresh faces to key ministries',
      'Analysts weigh in on latest approval rating shifts',
    ],
    'health': [
      'New study links sleep patterns to long-term wellbeing',
      'Health officials outline winter preparedness plan',
      'Breakthrough treatment shows promise in early trials',
      'Experts urge caution amid seasonal illness uptick',
      'Nutrition guidelines updated for the first time in a decade',
      'Mental health support expands across community clinics',
      'Researchers identify new factor in chronic disease risk',
      'Hospitals adopt new technology to speed up diagnoses',
    ],
    'business': [
      'Markets rally as inflation figures beat expectations',
      'Startup raises major funding round to expand operations',
      'Central bank signals cautious approach to interest rates',
      'Retail giant reports strongest quarter in years',
      'Supply chain shifts reshape global manufacturing map',
      'Energy prices ease after weeks of volatility',
      'Tech firm announces restructuring amid competitive pressure',
      'Small businesses adapt to changing consumer habits',
    ],
    'environment': [
      'Coastal cities unveil plans to combat rising sea levels',
      'Conservationists celebrate rebound in endangered species',
      'New research maps impact of shifting rainfall patterns',
      'Renewable energy output hits record high this quarter',
      'Cities pilot green infrastructure to cut urban heat',
      'Ocean cleanup initiative removes record volume of debris',
      'Farmers adopt new techniques to conserve water',
      'Wildlife corridors proposed to protect migration routes',
    ],
    'science': [
      'Astronomers capture clearest image yet of distant galaxy',
      'Researchers unveil breakthrough in battery technology',
      'New fossil discovery reshapes understanding of early life',
      'Scientists develop faster method for detecting contaminants',
      'Mission returns with new data on planetary formation',
      'Study reveals surprising behavior in deep-sea creatures',
      'Quantum computing milestone brings practical use closer',
      'Researchers map previously unknown cave ecosystem',
    ],
    'technology': [
      'New chip architecture promises major efficiency gains',
      'Tech company unveils next generation of wearable devices',
      'Cybersecurity experts warn of rising sophisticated threats',
      'AI tool helps researchers accelerate scientific discovery',
      'Startup reimagines home automation with new platform',
      'Major update rolls out new privacy protections',
      'Robotics firm demonstrates warehouse automation advances',
      'Developers embrace new framework for cross-platform apps',
    ],
    'entertainment': [
      'Award-winning director announces highly anticipated new film',
      'Streaming series breaks viewership records in first week',
      'Music festival lineup revealed with surprise headliners',
      'Beloved franchise confirms next chapter in production',
      'Actor opens up about transformative role in new drama',
      'Gaming studio teases sequel at industry showcase',
      'Broadway revival earns rave reviews from critics',
      'Documentary sheds new light on cultural movement',
    ],
  };

  static const String _bodyParagraph =
      'Officials and analysts continue to assess the wider implications of '
      'this development, with reactions pouring in from across the sector. '
      'Early responses suggest the situation could evolve quickly over the '
      'coming days as more information becomes available. Community leaders '
      'and independent experts have both weighed in, offering a range of '
      'perspectives on what this could mean going forward. Meanwhile, those '
      'directly affected are being kept updated as the story develops, and '
      'further coverage is expected as new details emerge.';

  List<ArticleModel> _generateArticles() {
    final rand = Random(42);
    final now = DateTime.now();
    final List<ArticleModel> articles = [];
    int globalIndex = 0;

    for (final category in kMockCategories) {
      final headlines = _headlinesByCategory[category.id]!;
      for (var i = 0; i < headlines.length; i++) {
        final title = headlines[i];
        final publishedAt = now.subtract(
          Duration(hours: rand.nextInt(96) + (i * 3)),
        );
        final imageIndex = (globalIndex % 6) + 1;
        articles.add(
          ArticleModel(
            id: '${category.id}_$i',
            title: title,
            summary: '$title. Here\'s what you need to know about the '
                'story and why it matters right now.',
            content: List.generate(4, (_) => _bodyParagraph).join('\n\n'),
            source: _sources[rand.nextInt(_sources.length)],
            categoryId: category.id,
            imageAsset: 'assets/images/news_placeholder_$imageIndex.png',
            publishedAt: publishedAt,
            author: _authors[rand.nextInt(_authors.length)],
            readingTimeMinutes: 2 + rand.nextInt(6),
            isBreaking: i == 0 && rand.nextBool(),
            viewCount: 200 + rand.nextInt(15000),
            tags: [category.name, if (i.isEven) 'Trending', if (i == 0) 'Featured'],
          ),
        );
        globalIndex++;
      }
    }

    // Ensure a healthy number of breaking stories regardless of randomness.
    for (var i = 0; i < 5; i++) {
      articles[i * 7] = (articles[i * 7]).copyWith(isBreaking: true);
    }

    articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return articles;
  }
}
