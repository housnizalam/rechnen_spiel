import 'package:hive_flutter/hive_flutter.dart';

import '../domain/user_profile.dart';

/// Name of the Hive box used to persist [UserProfile] data.
const String kUserProfilesBox = 'user_profiles';

/// Handles all local storage operations for [UserProfile] objects.
///
/// Profiles are stored as [Map] values inside a Hive box — no code generation
/// or type adapters required. Each entry key is the profile's [UserProfile.id].
class UserStorageService {
  late Box _box;

  bool get isOpen => _box.isOpen;

  /// Opens the underlying Hive box. Must be called once before any other
  /// method. Safe to call multiple times (no-op when already open).
  Future<void> init() async {
    if (Hive.isBoxOpen(kUserProfilesBox)) {
      _box = Hive.box(kUserProfilesBox);
    } else {
      _box = await Hive.openBox(kUserProfilesBox);
    }
  }

  /// Returns all stored profiles ordered by [UserProfile.createdAt] ascending.
  List<UserProfile> loadAll() {
    final profiles =
        _box.values.map((v) => UserProfile.fromMap(v as Map)).toList();
    profiles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return profiles;
  }

  /// Saves [profile] to the box, keyed by [UserProfile.id].
  ///
  /// Throws a [DuplicateNameException] when a profile with the same name
  /// already exists (case-insensitive comparison).
  Future<void> save(UserProfile profile) async {
    await upsert(profile, validateDuplicateName: true);
  }

  /// Inserts or replaces [profile] using [UserProfile.id] as the key.
  ///
  /// When [validateDuplicateName] is true, a duplicate-name check is applied
  /// against other user IDs (case-insensitive, trimmed).
  Future<void> upsert(
    UserProfile profile, {
    bool validateDuplicateName = true,
  }) async {
    final existing = loadAll();
    if (validateDuplicateName) {
      final duplicate = existing.any(
        (p) =>
            p.id != profile.id &&
            p.name.trim().toLowerCase() == profile.name.trim().toLowerCase(),
      );
      if (duplicate) {
        throw DuplicateNameException(profile.name);
      }
    }
    await _box.put(profile.id, profile.toMap());
  }

  /// Finds a profile by its [id]. Returns `null` if not found.
  UserProfile? findById(String id) {
    final value = _box.get(id);
    if (value == null) return null;
    return UserProfile.fromMap(value as Map);
  }

  /// Finds a profile by [name] using case-insensitive, trimmed matching.
  UserProfile? findByName(String name) {
    final normalized = name.trim().toLowerCase();
    for (final profile in loadAll()) {
      if (profile.name.trim().toLowerCase() == normalized) {
        return profile;
      }
    }
    return null;
  }

  /// Updates the name of an existing profile identified by [id].
  ///
  /// Preserves [UserProfile.createdAt] and [UserProfile.id].
  /// Throws [DuplicateNameException] if another profile already uses [newName]
  /// (case-insensitive, trimmed). Allows keeping the same name for the same user.
  Future<void> updateName(String id, String newName) async {
    final trimmed = newName.trim();
    final existing = loadAll();
    final duplicate = existing.any(
      (p) => p.id != id && p.name.trim().toLowerCase() == trimmed.toLowerCase(),
    );
    if (duplicate) {
      throw DuplicateNameException(trimmed);
    }
    final current = findById(id);
    if (current == null) return;
    final updated = current.copyWith(name: trimmed);
    await upsert(updated, validateDuplicateName: true);
  }

  /// Deletes the profile with [id] from the box.
  Future<void> deleteById(String id) async {
    await _box.delete(id);
  }
}

/// Thrown when trying to save a [UserProfile] whose name already exists.
class DuplicateNameException implements Exception {
  final String name;
  const DuplicateNameException(this.name);

  String get message => 'The name "$name" is already taken.';

  @override
  String toString() => message;
}
