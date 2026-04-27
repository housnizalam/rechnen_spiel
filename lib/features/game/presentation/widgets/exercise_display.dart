import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

/// Shows the active arithmetic expression while a round is in progress.
class ExerciseDisplay extends ConsumerWidget {
  const ExerciseDisplay({Key? key, this.compact = false}) : super(key: key);

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    if (state.status == GameStatus.failed ||
        state.status == GameStatus.won ||
        state.firstNumber == null) {
      return const SizedBox.shrink();
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '${state.firstNumber} ${state.calcOperation!.operation} ${state.secondNumber}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.amber,
          fontSize: compact ? 54 : 76,
          fontWeight: FontWeight.w900,
          letterSpacing: compact ? 0.8 : 1.5,
        ),
      ),
    );
  }
}
