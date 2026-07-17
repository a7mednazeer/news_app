import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/news_card.dart';
import '../../domain/entities/article.dart';

/// Auto-advancing carousel of breaking stories with a subtle parallax page
/// transition and animated dot indicators. Pauses auto-advance while the
/// user is interacting with it.
class BreakingNewsCarousel extends StatefulWidget {
  final List<Article> articles;
  const BreakingNewsCarousel({super.key, required this.articles});

  @override
  State<BreakingNewsCarousel> createState() => _BreakingNewsCarouselState();
}

class _BreakingNewsCarouselState extends State<BreakingNewsCarousel> {
  late final PageController _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    if (widget.articles.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.articles.length;
      _controller.animateToPage(
        next,
        duration: AppDurations.slow,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.articles.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final article = widget.articles[index];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_controller.position.haveDimensions) {
                    final page = _controller.page ?? _page.toDouble();
                    scale = (1 - ((page - index).abs() * 0.06)).clamp(0.94, 1.0);
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: NewsCard(
                  article: article,
                  variant: NewsCardVariant.featured,
                  onTap: () => context.push(
                    AppRoutes.articleDetailsPath(article.id),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.articles.length,
            (i) => AnimatedContainer(
              duration: AppDurations.fast,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _page ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _page
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
