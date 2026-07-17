import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

enum SnackType { info, success, error }

/// Single entry point for all snackbars in the app so styling, icons, and
/// timing stay consistent (bookmarked confirmations, link copied, errors).
class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackType type = SnackType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final (icon, color) = switch (type) {
      SnackType.success => (Icons.check_circle_rounded, AppColors.success),
      SnackType.error => (Icons.error_rounded, AppColors.error),
      SnackType.info => (Icons.info_rounded, AppColors.accent),
    };

    messenger.showSnackBar(
      SnackBar(
        duration: AppDurations.snackbar,
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: color,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }
}
