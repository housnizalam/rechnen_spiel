import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

/// Displays current stage and allows moving to previous/next unlocked stage.
class StageDisplay extends ConsumerWidget {
  const StageDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final isLocked = state.status == GameStatus.playing;

    final String stageText;
    final bool canGoDown;
    final bool canGoUp;

    if (state.calcOperation!.operation == '+') {
      stageText = 'Stage ${state.actualStageAddition + 1}';
      canGoDown = state.actualStageAddition > 0;
      canGoUp = state.actualStageAddition < state.player!.maxStageAdition;
    } else if (state.calcOperation!.operation == '-') {
      stageText = 'Stage ${state.actualStageSubtraction + 1}';
      canGoDown = state.actualStageSubtraction > 0;
      canGoUp =
          state.actualStageSubtraction < state.player!.maxStageSubtruction;
    } else if (state.calcOperation!.operation == '*') {
      stageText = 'Stage ${state.actualStageMultiplication + 1}';
      canGoDown = state.actualStageMultiplication > 0;
      canGoUp = state.actualStageMultiplication <
          state.player!.maxStageMultiplication;
    } else if (state.calcOperation!.operation == '/') {
      stageText = 'Stage ${state.actualStageDivision + 1}';
      canGoDown = state.actualStageDivision > 0;
      canGoUp = state.actualStageDivision < state.player!.maxStageSection;
    } else {
      // Random operation
      stageText = 'Stage ${state.actualStageRandom + 1}';
      canGoDown = state.actualStageRandom > 0;
      canGoUp = state.actualStageRandom < state.player!.maxStageRandom;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: (isLocked || !canGoDown) ? 0.4 : 1.0,
          child: InkWell(
            onTap: (isLocked || !canGoDown)
                ? null
                : () {
                    ref.read(gameNotifierProvider.notifier).previousStage();
                  },
            child: Icon(
              Icons.arrow_drop_down,
              size: 36,
              color: canGoDown && !isLocked
                  ? Colors.amber
                  : const Color.fromARGB(0, 158, 158, 158),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            stageText,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Opacity(
          opacity: (isLocked || !canGoUp) ? 0.4 : 1.0,
          child: InkWell(
            onTap: (isLocked || !canGoUp)
                ? null
                : () {
                    ref.read(gameNotifierProvider.notifier).nextStage();
                  },
            child: Icon(
              Icons.arrow_drop_up,
              size: 36,
              color: canGoUp && !isLocked
                  ? Colors.amber
                  : const Color.fromARGB(0, 158, 158, 158),
            ),
          ),
        )
      ],
    );
  }
}
