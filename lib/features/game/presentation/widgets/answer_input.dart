import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';
import 'answer_sheet.dart';

/// Renders the answer area with four selectable options.
///
/// The area is hidden once the round has reached win or fail thresholds.
class AnswerInput extends ConsumerWidget {
  const AnswerInput({Key? key, this.compact = false}) : super(key: key);

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);

    final List<int> answers =
        state.answerOptions.length == 4 ? state.answerOptions : const [];
    final hideAnswers =
        state.trueAnswers == 8 || state.allAnswers - state.trueAnswers > 2;

    if (hideAnswers || answers.length != 4) {
      return const SizedBox.expand();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = compact ? 8.0 : 12.0;
        final availableHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 320.0;
        final tileHeight = ((availableHeight - spacing) / 2)
            .clamp(compact ? 64.0 : 78.0, 180.0)
            .toDouble();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: answers.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: tileHeight,
          ),
          itemBuilder: (context, index) {
            return AnswerSheet(
              answer: answers[index],
              compact: compact,
            );
          },
        );
      },
    );
  }
}
