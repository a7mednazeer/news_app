import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/local_storage_service.dart';

/// Overridden in `main.dart` with the real, awaited instance before
/// `runApp` — this lets every other provider `ref.watch` a synchronous,
/// ready-to-use [LocalStorageService] without threading `FutureProvider`
/// / `AsyncValue` unwrapping through the whole app.
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError(
    'localStorageServiceProvider must be overridden in main.dart',
  );
});
