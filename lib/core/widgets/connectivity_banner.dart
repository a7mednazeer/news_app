import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../providers/connectivity_provider.dart';

/// Slides a persistent "You're offline" banner in/out from the top of the
/// shell whenever [connectivityStatusProvider] reports no connection.
/// Cached/mock content keeps working underneath — this is purely an
/// informational affordance, matching the app's offline-ready design.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(connectivityStatusProvider);
    final isOffline = isOnlineAsync.maybeWhen(
      data: (isOnline) => !isOnline,
      orElse: () => false,
    );

    return AnimatedSize(
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
      child: isOffline
          ? Container(
              width: double.infinity,
              color: AppColors.warning,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: const SafeArea(
                bottom: false,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'You\'re offline — showing saved content',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );
  }
}
