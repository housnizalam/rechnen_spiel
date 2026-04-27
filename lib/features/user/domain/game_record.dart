import 'package:uuid/uuid.dart';

/// Immutable record of one successfully completed stage.
class GameRecord {
  final String id;
  final DateTime createdAt;
  final int stageNumber;
  final String operation;
  final double durationSeconds;

  const GameRecord({
    required this.id,
    required this.createdAt,
    required this.stageNumber,
    required this.operation,
    required this.durationSeconds,
  });

  factory GameRecord.create({
    required int stageNumber,
    required String operation,
    required double durationSeconds,
  }) {
    return GameRecord(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      stageNumber: stageNumber,
      operation: operation,
      durationSeconds: durationSeconds,
    );
  }

  GameRecord copyWith({
    String? id,
    DateTime? createdAt,
    int? stageNumber,
    String? operation,
    double? durationSeconds,
  }) {
    return GameRecord(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      stageNumber: stageNumber ?? this.stageNumber,
      operation: operation ?? this.operation,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'stageNumber': stageNumber,
      'operation': operation,
      'durationSeconds': durationSeconds,
    };
  }

  factory GameRecord.fromMap(Map<dynamic, dynamic> map) {
    return GameRecord(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      stageNumber: (map['stageNumber'] as num).toInt(),
      operation: map['operation'] as String,
      durationSeconds: (map['durationSeconds'] as num).toDouble(),
    );
  }
}
