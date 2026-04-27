import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

class AnswerSheet extends ConsumerWidget {
  final int answer;
  const AnswerSheet({
    super.key,
    required this.answer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);
    double width = MediaQuery.of(context).size.width;

    return state.firstNumber != null && state.secondNumber != null
        ? InkWell(
            child: SizedBox(
              width: width * 0.5,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    answer.toString(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ),
            onTap: () {
              if (state.status != GameStatus.failed &&
                  state.status != GameStatus.won) {
                gameNotifier.submitAnswer(answer);
                gameNotifier.nextQuestion();
                gameNotifier.startGame();
              }
            },
          )
        : Container();
  }
}
