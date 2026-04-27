import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_notifier.dart';

class Bewertung extends ConsumerWidget {
  const Bewertung({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    return Container(
        child: state.answer != null && state.valuation[0] == 'R'
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(state.valuation,
                    style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 40,
                        fontWeight: FontWeight.bold)),
              )
            : state.answer != null && state.valuation[0] == 'F'
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(state.valuation,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                  )
                : state.answer != null && state.valuation == 'Bestanden'
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(state.valuation,
                            style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 40,
                                fontWeight: FontWeight.bold)),
                      )
                    : state.answer != null && state.valuation == 'durchgefallen'
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(state.valuation,
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold)),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(state.valuation,
                                style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold)),
                          ));
  }
}
