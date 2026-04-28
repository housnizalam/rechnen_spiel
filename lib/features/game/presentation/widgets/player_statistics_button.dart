import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../user/domain/game_record.dart';
import '../../state/game_notifier.dart';

class PlayerStatisticsButton extends ConsumerWidget {
  const PlayerStatisticsButton({super.key, this.iconSize = 22});

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Statistics',
      iconSize: iconSize,
      color: AppColors.gold,
      icon: const Icon(Icons.bar_chart_rounded),
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (_) => const _PlayerStatisticsDialog(),
        );
      },
    );
  }
}

class _PlayerStatisticsDialog extends ConsumerWidget {
  const _PlayerStatisticsDialog();

  static const List<String> _operationOrder = ['+', '-', '*', '/', 'R'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = List<GameRecord>.from(
      ref.watch(gameNotifierProvider).player?.gameRecords ?? <GameRecord>[],
    );
    final grouped = _groupRecords(records);
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
                      'Best Records',
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

  Map<String, Map<int, List<GameRecord>>> _groupRecords(
    List<GameRecord> records,
  ) {
    final grouped = <String, Map<int, List<GameRecord>>>{};
    for (final record in records) {
      final byOperation = grouped.putIfAbsent(
        record.operation,
        () => <int, List<GameRecord>>{},
      );
      final byStage = byOperation.putIfAbsent(
        record.stageNumber,
        () => <GameRecord>[],
      );
      byStage.add(record);
    }

    for (final operationEntry in grouped.entries) {
      for (final stageEntry in operationEntry.value.entries) {
        stageEntry.value.sort(
          (a, b) => a.durationSeconds.compareTo(b.durationSeconds),
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

class _OperationSection extends StatelessWidget {
  const _OperationSection({
    required this.operationLabel,
    required this.stages,
    required this.stageMap,
  });

  final String operationLabel;
  final List<int> stages;
  final Map<int, List<GameRecord>> stageMap;

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
            final records = stageMap[stageNumber] ?? const <GameRecord>[];
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
  final List<GameRecord> records;

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
            final record = records[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${index + 1}-) ${record.durationSeconds.toStringAsFixed(1)} Sec',
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
