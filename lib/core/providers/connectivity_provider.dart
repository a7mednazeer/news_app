import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streams whether the device currently has *some* network interface up
/// (wifi/mobile/ethernet). This is a connectivity check, not a true
/// internet-reachability check — sufficient to drive an "You're offline"
/// banner without adding a ping dependency.
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
});
