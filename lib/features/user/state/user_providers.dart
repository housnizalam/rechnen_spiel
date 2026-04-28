import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_storage_service.dart';
import '../domain/user_profile.dart';
import '../../game/domain/game_models.dart';

/// Provides the singleton [UserStorageService].
///
/// The service must already be initialised (box opened) before this provider
/// is used. Initialisation is performed in `main()` before `runApp()`.
final userStorageServiceProvider = Provider<UserStorageService>((ref) {
  return UserStorageService();
});

/// Provides the list of all persisted [UserProfile]s.
///
/// Returns an empty list while data is loading or if the box is empty.
final savedUsersProvider = FutureProvider<List<UserProfile>>((ref) async {
  final service = ref.watch(userStorageServiceProvider);
  return service.loadAll();
});

/// Holds the currently selected [Player] throughout the app session.
///
/// This provider is set when a user selects or creates a profile from [StartPage].
/// Both [GameNotifier] (normal mode) and [ReverseGameNotifier] (reverse mode)
/// read from this provider, eliminating tight coupling between game modes.
///
/// When records are saved, they update this provider's player data and persist
/// via [UserStorageService].
final currentUserProvider = StateProvider<Player?>((ref) {
  return null;
});
