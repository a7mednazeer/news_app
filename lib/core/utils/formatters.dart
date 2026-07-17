/// Human-friendly relative time, e.g. "3h ago", "Just now", "2d ago".
String formatRelativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

String formatReadingTime(int minutes) => '$minutes min read';

String formatViewCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M views';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K views';
  return '$count views';
}
