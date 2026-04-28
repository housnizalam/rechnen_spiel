import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

/// Displays feedback text for answer correctness and end-of-stage outcomes.
class Evaluation extends ConsumerWidget {
  const Evaluation({Key? key, this.compact = false}) : super(key: key);

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final hasMessage = state.evaluationMessage.isNotEmpty;

    final startsWithF = hasMessage && state.evaluationMessage[0] == 'F';
    final isFailed = state.evaluationMessage == 'durchgefallen';
    final isError = startsWithF || isFailed;
    final maxWidth =
        MediaQuery.of(context).size.width * (compact ? 0.92 : 0.86);

    final messageLength = state.evaluationMessage.length;
    final double textSize;
    if (compact || messageLength > 110) {
      textSize = 16;
    } else if (messageLength > 75) {
      textSize = 18;
    } else {
      textSize = 21;
    }

    return Opacity(
      opacity: hasMessage ? 1.0 : 0.0,
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minHeight: compact ? 80 : 96,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 16,
                vertical: compact ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.48),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isError ? Colors.red : Colors.amber,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  state.evaluationMessage,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isError ? Colors.red : Colors.amber,
                    fontSize: textSize,
                    fontWeight: FontWeight.bold,
                    height: 1.18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
