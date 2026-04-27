import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

class AufgabeDarstellung extends ConsumerWidget {
  const AufgabeDarstellung({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: state.status == GameStatus.failed ||
              state.status == GameStatus.won ||
              state.firstNumber == null
          ? Container()
          : Text(
              '${state.firstNumber} ${state.calcOperation!.operation} ${state.secondNumber}',
              style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
    );
  }
}
