import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../user/domain/game_record.dart';
import '../../../user/presentation/widgets/game_statistics_dialog.dart';
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
        final records = List<GameRecord>.from(
          ref.read(gameNotifierProvider).player?.gameRecords ?? <GameRecord>[],
        );
        showDialog<void>(
          context: context,
          builder: (_) => GameStatisticsDialog(
            records: records,
            gameMode: GameModeKeys.normal,
          ),
        );
      },
    );
  }
}
