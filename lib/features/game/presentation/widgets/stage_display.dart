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
    final stageText = state.calcOperation!.operation == '+'
        ? 'Stage ${state.actualStageAddition + 1}'
        : state.calcOperation!.operation == '-'
            ? 'Stage ${state.actualStageSubtraction + 1}'
            : state.calcOperation!.operation == '*'
                ? 'Stage ${state.actualStageMultiplication + 1}'
                : 'Stage ${state.actualStageDivision + 1}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: isLocked ? 0.4 : 1.0,
          child: InkWell(
            onTap: isLocked
                ? null
                : () {
                    if (state.calcOperation!.operation == '+' &&
                            state.actualStageAddition > 0 ||
                        state.calcOperation!.operation == '-' &&
                            state.actualStageSubtraction > 0 ||
                        state.calcOperation!.operation == '*' &&
                            state.actualStageMultiplication > 0 ||
                        state.calcOperation!.operation == '/' &&
                            state.actualStageDivision > 0) {
                      ref.read(gameNotifierProvider.notifier).previousStage();
                    }
                  },
            child: Icon(
              Icons.arrow_drop_down,
              size: 36,
              color: (state.calcOperation!.operation == '+' &&
                          state.actualStageAddition > 0) ||
                      (state.calcOperation!.operation == '-' &&
                          state.actualStageSubtraction > 0) ||
                      (state.calcOperation!.operation == '*' &&
                          state.actualStageMultiplication > 0) ||
                      (state.calcOperation!.operation == '/' &&
                          state.actualStageDivision > 0)
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
          opacity: isLocked ? 0.4 : 1.0,
          child: InkWell(
            onTap: isLocked
                ? null
                : () {
                    if (state.calcOperation!.operation == '+' &&
                            state.actualStageAddition <
                                state.player!.maxStageAdition ||
                        state.calcOperation!.operation == '-' &&
                            state.actualStageSubtraction <
                                state.player!.maxStageSubtruction ||
                        state.calcOperation!.operation == '*' &&
                            state.actualStageMultiplication <
                                state.player!.maxStageMultiplication ||
                        state.calcOperation!.operation == '/' &&
                            state.actualStageDivision <
                                state.player!.maxStageSection) {
                      ref.read(gameNotifierProvider.notifier).nextStage();
                    }
                  },
            child: Icon(
              Icons.arrow_drop_up,
              size: 36,
              color: state.calcOperation!.operation == '+' &&
                          state.actualStageAddition <
                              state.player!.maxStageAdition ||
                      state.calcOperation!.operation == '-' &&
                          state.actualStageSubtraction <
                              state.player!.maxStageSubtruction ||
                      state.calcOperation!.operation == '*' &&
                          state.actualStageMultiplication <
                              state.player!.maxStageMultiplication ||
                      state.calcOperation!.operation == '/' &&
                          state.actualStageDivision <
                              state.player!.maxStageSection
                  ? Colors.amber
                  : const Color.fromARGB(0, 158, 158, 158),
            ),
          ),
        )
      ],
    );
  }
}
