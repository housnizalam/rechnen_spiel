import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_notifier.dart';

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
                        state.actualStageAdition > 0) ||
                    (state.calcOperation!.operation == '-' &&
                        state.actualStageSubtruction > 0) ||
                    (state.calcOperation!.operation == '*' &&
                        state.actualStageMultiplication > 0) ||
                    (state.calcOperation!.operation == '/' &&
                        state.actualStageSectioning > 0)
                ? Colors.amber
                : const Color.fromARGB(0, 158, 158, 158),
          ),
          onTap: () {
            if (state.calcOperation!.operation == '+' &&
                    state.actualStageAdition > 0 ||
                state.calcOperation!.operation == '-' &&
                    state.actualStageSubtruction > 0 ||
                state.calcOperation!.operation == '*' &&
                    state.actualStageMultiplication > 0 ||
                state.calcOperation!.operation == '/' &&
                    state.actualStageSectioning > 0) {
              ref.read(gameNotifierProvider.notifier).previosStage();
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: state.calcOperation!.operation == '+'
              ? Text('Stage ${state.actualStageAdition + 1}',
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 40,
                      fontWeight: FontWeight.bold))
              : state.calcOperation!.operation == '-'
                  ? Text('Stage ${state.actualStageSubtruction + 1}',
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
                          'Stage ${state.actualStageSectioning + 1}',
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
                        state.actualStageAdition <
                            state.player!.maxStageAdition ||
                    state.calcOperation!.operation == '-' &&
                        state.actualStageSubtruction <
                            state.player!.maxStageSubtruction ||
                    state.calcOperation!.operation == '*' &&
                        state.actualStageMultiplication <
                            state.player!.maxStageMultiplication ||
                    state.calcOperation!.operation == '/' &&
                        state.actualStageSectioning <
                            state.player!.maxStageSection
                ? Colors.amber
                : const Color.fromARGB(0, 158, 158, 158),
          ),
          onTap: () {
            if (state.calcOperation!.operation == '+' &&
                    state.actualStageAdition < state.player!.maxStageAdition ||
                state.calcOperation!.operation == '-' &&
                    state.actualStageSubtruction <
                        state.player!.maxStageSubtruction ||
                state.calcOperation!.operation == '*' &&
                    state.actualStageMultiplication <
                        state.player!.maxStageMultiplication ||
                state.calcOperation!.operation == '/' &&
                    state.actualStageSectioning <
                        state.player!.maxStageSection) {
              ref.read(gameNotifierProvider.notifier).nextStage();
            }
          },
        )
      ],
    );
  }
}
