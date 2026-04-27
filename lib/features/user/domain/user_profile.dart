import 'package:uuid/uuid.dart';

import 'game_record.dart';

/// Represents a player profile stored locally via Hive.
///
/// Currently holds identity fields only. Future versions will add
/// achievements, unlocked stages, best completion times, and statistics.
class UserProfile {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<GameRecord> gameRecords;

  const UserProfile({
    required this.id,
    required this.name,
    required this.createdAt,
    this.gameRecords = const [],
  });

  /// Creates a new profile with a generated UUID and the current timestamp.
  factory UserProfile.create(String name) {
    return UserProfile(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      gameRecords: const [],
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<GameRecord>? gameRecords,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      gameRecords: gameRecords ?? this.gameRecords,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'gameRecords': gameRecords.map((record) => record.toMap()).toList(),
    };
  }

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    final dynamic recordsRaw = map['gameRecords'];
    final records = recordsRaw is List
        ? recordsRaw
            .map((item) => GameRecord.fromMap(item as Map<dynamic, dynamic>))
            .toList()
        : <GameRecord>[];

    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      gameRecords: records,
    );
  }

  @override
  bool operator ==(Object other) => other is UserProfile && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
