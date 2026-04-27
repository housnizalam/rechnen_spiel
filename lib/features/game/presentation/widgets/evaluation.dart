import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

/// Displays feedback text for answer correctness and end-of-stage outcomes.
class Evaluation extends ConsumerWidget {
  const Evaluation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    return Container(
        child: state.answer != null && state.evaluationMessage[0] == 'R'
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(state.evaluationMessage,
                    style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 40,
                        fontWeight: FontWeight.bold)),
              )
            : state.answer != null && state.evaluationMessage[0] == 'F'
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(state.evaluationMessage,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                  )
                : state.answer != null && state.evaluationMessage == 'Bestanden'
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(state.evaluationMessage,
                            style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 40,
                                fontWeight: FontWeight.bold)),
                      )
                    : state.answer != null && state.evaluationMessage == 'durchgefallen'
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(state.evaluationMessage,
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold)),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(state.evaluationMessage,
                                style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold)),
                          ));
  }
}
