import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../user/domain/game_record.dart';
import '../../../user/presentation/widgets/game_statistics_dialog.dart';
import '../../../user/state/user_providers.dart';

class ReversePlayerStatisticsButton extends ConsumerWidget {
  const ReversePlayerStatisticsButton({super.key, this.iconSize = 22});

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Statistics (Reverse)',
      iconSize: iconSize,
      color: AppColors.gold,
      icon: const Icon(Icons.bar_chart_rounded),
      onPressed: () {
        final records = List<GameRecord>.from(
          ref.read(currentUserProvider)?.gameRecords ?? <GameRecord>[],
        );
        showDialog<void>(
          context: context,
          builder: (_) => GameStatisticsDialog(
            records: records,
            gameMode: GameModeKeys.reverse,
            title: 'Best Records (Reverse)',
          ),
        );
      },
    );
  }
}
