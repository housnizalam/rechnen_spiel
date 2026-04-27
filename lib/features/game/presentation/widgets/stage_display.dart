import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

/// Displays current stage and allows moving to previous/next unlocked stage.
class StageDisplay extends ConsumerWidget {
  const StageDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          child: Icon(
            Icons.arrow_drop_down,
            size: 60,
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
          onTap: () {
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
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: state.calcOperation!.operation == '+'
              ? Text('Stage ${state.actualStageAddition + 1}',
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 40,
                      fontWeight: FontWeight.bold))
              : state.calcOperation!.operation == '-'
                  ? Text('Stage ${state.actualStageSubtraction + 1}',
                      style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 40,
                          fontWeight: FontWeight.bold))
                  : state.calcOperation!.operation == '*'
                      ? Text('Stage ${state.actualStageMultiplication + 1}',
                          style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 40,
                              fontWeight: FontWeight.bold))
                      : Text(
                          'Stage ${state.actualStageDivision + 1}',
                          style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
        ),
        InkWell(
          child: Icon(
            Icons.arrow_drop_up,
            size: 60,
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
          onTap: () {
            if (state.calcOperation!.operation == '+' &&
                    state.actualStageAddition < state.player!.maxStageAdition ||
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
        )
      ],
    );
  }
}
