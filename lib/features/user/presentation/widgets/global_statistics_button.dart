import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/game_record.dart';
import '../../domain/user_profile.dart';

class GlobalStatisticsButton extends StatelessWidget {
  const GlobalStatisticsButton({
    super.key,
    required this.savedUsers,
    this.iconSize = 22,
  });

  final List<UserProfile> savedUsers;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Global Statistics',
      iconSize: iconSize,
      color: AppColors.gold,
      icon: const Icon(Icons.bar_chart_rounded),
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (_) => _GlobalStatisticsDialog(savedUsers: savedUsers),
        );
      },
    );
  }
}

class _GlobalStatisticsDialog extends StatelessWidget {
  const _GlobalStatisticsDialog({required this.savedUsers});

  static const List<String> _operationOrder = ['+', '-', '*', '/', 'R'];

  final List<UserProfile> savedUsers;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupRecords(savedUsers);
    final hasData = grouped.isNotEmpty;
    final screen = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screen.width > 700 ? 640 : screen.width * 0.94,
          maxHeight: screen.height * 0.84,
        ),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.72)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(70, 255, 0, 0),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_rounded, color: AppColors.gold),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Global Best Records',
                      style: AppTextStyles.title,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: hasData
                    ? ListView.builder(
                        itemCount: _operationOrder.length,
                        itemBuilder: (context, index) {
                          final operation = _operationOrder[index];
                          final stageMap = grouped[operation];
                          if (stageMap == null || stageMap.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final stages = stageMap.keys.toList()..sort();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _OperationSection(
                              operationLabel: _operationLabel(operation),
                              stages: stages,
                              stageMap: stageMap,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No completed stages yet.',
                          style: AppTextStyles.subtitle,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Map<int, List<_NamedRecord>>> _groupRecords(
    List<UserProfile> users,
  ) {
    final grouped = <String, Map<int, List<_NamedRecord>>>{};

    for (final user in users) {
      for (final record in user.gameRecords) {
        // Filter to only include normal mode records
        if (record.gameMode != 'normal') {
          continue;
        }
        final byOperation = grouped.putIfAbsent(
          record.operation,
          () => <int, List<_NamedRecord>>{},
        );
        final byStage = byOperation.putIfAbsent(
          record.stageNumber,
          () => <_NamedRecord>[],
        );
        byStage.add(_NamedRecord(playerName: user.name, record: record));
      }
    }

    for (final operationEntry in grouped.entries) {
      for (final stageEntry in operationEntry.value.entries) {
        stageEntry.value.sort(
          (a, b) =>
              a.record.durationSeconds.compareTo(b.record.durationSeconds),
        );
        if (stageEntry.value.length > 3) {
          operationEntry.value[stageEntry.key] =
              stageEntry.value.take(3).toList();
        }
      }
    }

    return grouped;
  }

  String _operationLabel(String symbol) {
    if (symbol == '+') return 'Addition';
    if (symbol == '-') return 'Subtraction';
    if (symbol == '*') return 'Multiplication';
    if (symbol == '/') return 'Division';
    if (symbol == 'R') return 'Random';
    return 'Unknown';
  }
}

class _NamedRecord {
  const _NamedRecord({required this.playerName, required this.record});

  final String playerName;
  final GameRecord record;
}

class _OperationSection extends StatelessWidget {
  const _OperationSection({
    required this.operationLabel,
    required this.stages,
    required this.stageMap,
  });

  final String operationLabel;
  final List<int> stages;
  final Map<int, List<_NamedRecord>> stageMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            operationLabel,
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 8),
          ...stages.map((stageNumber) {
            final records = stageMap[stageNumber] ?? const <_NamedRecord>[];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StageRecordSection(
                stageNumber: stageNumber,
                records: records,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StageRecordSection extends StatelessWidget {
  const _StageRecordSection({
    required this.stageNumber,
    required this.records,
  });

  final int stageNumber;
  final List<_NamedRecord> records;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stage $stageNumber',
            style: AppTextStyles.body.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          ...List.generate(records.length, (index) {
            final entry = records[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${index + 1}-) ${entry.playerName} - ${entry.record.durationSeconds.toStringAsFixed(1)} Sec',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.goldMuted,
                  fontSize: 14,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
