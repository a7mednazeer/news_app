import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Renders a local asset image (per project requirements, no network image
/// URLs are used — assets like `assets/images/news_placeholder_1.png` are
/// meant to be swapped in later). Falls back to a branded placeholder icon
/// if the asset is missing, so the UI never shows Flutter's default red
/// "asset not found" error box.
class AppImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(isDark),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _placeholder(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.heroGradientDark
            : AppColors.heroGradientLight,
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_rounded,
        color: Colors.white.withValues(alpha: 0.55),
        size: (height ?? 120) * 0.28,
      ),
    );
  }
}
