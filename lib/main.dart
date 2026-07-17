import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/providers/core_providers.dart';
import 'core/utils/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Await local storage once at startup so every provider that depends on
  // [localStorageServiceProvider] can be synchronous from the very first
  // frame — see core/providers/core_providers.dart for details.
  final localStorageService = await LocalStorageService.create();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
      ],
      child: const BulletinApp(),
    ),
  );
}
