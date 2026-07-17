import 'package:flutter/material.dart';

/// Slim progress bar reflecting scroll position through an article,
/// pinned beneath the app bar on the Article Details screen.
class ReadingProgressBar extends StatelessWidget implements PreferredSizeWidget {
  final double progress; // 0.0 - 1.0

  const ReadingProgressBar({super.key, required this.progress});

  @override
  Size get preferredSize => const Size.fromHeight(3);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: 3,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}
