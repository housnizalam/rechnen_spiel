import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

class NextButton extends ConsumerWidget {
  const NextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: state.isAnswerGiven
                        ? const WidgetStatePropertyAll(Colors.red)
                        : const WidgetStatePropertyAll(
                            Color.fromARGB(0, 158, 158, 158))),
                onPressed: () {
                  if (state.trueAnswers < 8 && state.allAnswers < 10 ||
                      state.trueAnswers < 8 && state.allAnswers > 9) {
                    ref.read(gameNotifierProvider.notifier).nextQuestion();
                  } else {
                    ref.read(gameNotifierProvider.notifier).winToNextStage();
                  }
                },
                child: state.trueAnswers < 8 && state.allAnswers > 9
                    ? const Text('Stufe Wiederholen',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold))
                    : state.trueAnswers < 8
                        ? const Text('Nächste Aufgabe',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))
                        : const Text('Nächste Stufe',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  ref.read(gameNotifierProvider.notifier).winToNextStage();
                },
                child: const Icon(
                  Icons.refresh,
                  color: Colors.black,
                )),
          ),
        ],
      ),
    );
  }
}
