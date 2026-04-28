import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

/// Single tappable answer option card.
///
/// On tap, it performs the standard flow:
/// submit answer -> prepare next question -> start next question.
class AnswerSheet extends ConsumerWidget {
  final int answer;
  final bool isActive;
  const AnswerSheet({
    super.key,
    required this.answer,
    this.compact = false,
    this.isActive = true,
  });

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);
    final canTap = isActive &&
        state.firstNumber != null &&
        state.secondNumber != null &&
        state.status != GameStatus.failed &&
        state.status != GameStatus.won;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            canTap ? () => gameNotifier.submitAnswerAndContinue(answer) : null,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Color.fromARGB(255, 78, 0, 0),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.red, width: 1.5),
          ),
          child: Center(
            child: Text(
              answer.toString(),
              style: TextStyle(
                fontSize: compact ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
