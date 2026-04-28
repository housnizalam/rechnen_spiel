import 'package:uuid/uuid.dart';

/// Immutable record of one successfully completed stage.
class GameRecord {
  final String id;
  final DateTime createdAt;
  final int stageNumber;
  final String operation;
  final double durationSeconds;
  final String gameMode;

  const GameRecord({
    required this.id,
    required this.createdAt,
    required this.stageNumber,
    required this.operation,
    required this.durationSeconds,
    required this.gameMode,
  });

  factory GameRecord.create({
    required int stageNumber,
    required String operation,
    required double durationSeconds,
    String gameMode = 'normal',
  }) {
    return GameRecord(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      stageNumber: stageNumber,
      operation: operation,
      durationSeconds: durationSeconds,
      gameMode: gameMode,
    );
  }

  GameRecord copyWith({
    String? id,
    DateTime? createdAt,
    int? stageNumber,
    String? operation,
    double? durationSeconds,
    String? gameMode,
  }) {
    return GameRecord(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      stageNumber: stageNumber ?? this.stageNumber,
      operation: operation ?? this.operation,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      gameMode: gameMode ?? this.gameMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'stageNumber': stageNumber,
      'operation': operation,
      'durationSeconds': durationSeconds,
      'gameMode': gameMode,
    };
  }

  factory GameRecord.fromMap(Map<dynamic, dynamic> map) {
    return GameRecord(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      stageNumber: (map['stageNumber'] as num).toInt(),
      operation: map['operation'] as String,
      durationSeconds: (map['durationSeconds'] as num).toDouble(),
      gameMode: map['gameMode'] as String? ?? 'normal',
    );
  }
}
