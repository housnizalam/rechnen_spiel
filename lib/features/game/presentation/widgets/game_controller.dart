import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

/// Main action button that starts gameplay, repeats stage, or advances stage.
class GameController extends ConsumerWidget {
  const GameController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          if (state.status == GameStatus.failed) {
            ref.read(gameNotifierProvider.notifier).repeatStage();
          } else if (state.status == GameStatus.won) {
            ref.read(gameNotifierProvider.notifier).winToNextStage();
          } else {
            ref.read(gameNotifierProvider.notifier).startGame();
          }
        },
        child: state.allAnswers == 0
            ? const Text(
                'Start the game',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )
            : state.status != GameStatus.won
                ? const Text(
                    'restart',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )
                : const Text(
                    'Next Stage',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
      ),
    );
  }
}
