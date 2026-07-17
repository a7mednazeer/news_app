import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// A bookmark toggle with a playful scale + color pop animation whenever
/// the state changes — used on cards and the article details screen.
class BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onPressed;
  final double size;
  final Color? background;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onPressed,
    this.size = 40,
    this.background,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.fast,
    lowerBound: 0.0,
    upperBound: 0.25,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 + _controller.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.background ??
                Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: AppDurations.fast,
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              widget.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              key: ValueKey(widget.isBookmarked),
              color: widget.isBookmarked ? scheme.secondary : Colors.white,
              size: widget.size * 0.52,
            ),
          ),
        ),
      ),
    );
  }
}
