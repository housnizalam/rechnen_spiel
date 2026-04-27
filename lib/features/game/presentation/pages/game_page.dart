import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';
import '../widgets/answer_input.dart';
import '../widgets/evaluation.dart';
import '../widgets/exercise_display.dart';
import '../widgets/game_controller.dart';
import '../widgets/stage_display.dart';
import '../widgets/timer_display.dart';

/// Responsive game screen split into header, game area, and answer area.
class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  static const BoxDecoration _backgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black,
        Colors.black,
        Color.fromARGB(255, 64, 0, 0),
        Color.fromARGB(255, 128, 0, 0),
        Colors.black,
      ],
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final showBottomAction = state.status == GameStatus.idle ||
        state.status == GameStatus.playing ||
        state.status == GameStatus.won ||
        state.status == GameStatus.failed;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.black,
        title: Text(
          state.player?.name ?? state.title,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: _backgroundDecoration,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact =
                  constraints.maxHeight < 680 || constraints.maxWidth < 430;
              final outerPadding = isCompact ? 12.0 : 16.0;
              final sectionGap = isCompact ? 10.0 : 16.0;

              return Padding(
                padding: EdgeInsets.all(outerPadding),
                child: Column(
                  children: [
                    _Header(
                      isCompact: isCompact,
                      operation: state.calcOperation?.operation ?? '+',
                      isLocked: state.status == GameStatus.playing,
                      onOperationPressed: state.status == GameStatus.playing
                          ? null
                          : () {
                              ref
                                  .read(gameNotifierProvider.notifier)
                                  .chooseOperation();
                            },
                    ),
                    SizedBox(height: sectionGap),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            flex: isCompact ? 4 : 5,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 8 : 16,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ExerciseDisplay(compact: isCompact),
                                    SizedBox(height: isCompact ? 12 : 18),
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: Evaluation(compact: isCompact),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          Expanded(
                            flex: isCompact ? 5 : 4,
                            child: AnswerInput(compact: isCompact),
                          ),
                        ],
                      ),
                    ),
                    if (showBottomAction) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 2 : 4,
                        ),
                        child: GameController(compact: isCompact),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isCompact,
    required this.operation,
    required this.isLocked,
    required this.onOperationPressed,
  });

  final bool isCompact;
  final String operation;
  final bool isLocked;
  final VoidCallback? onOperationPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Opacity(
              opacity: isLocked ? 0.4 : 1.0,
              child: _OperationSelector(
                operation: operation,
                compact: isCompact,
                onPressed: onOperationPressed,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: StageDisplay(),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TimerDisplay(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationSelector extends StatelessWidget {
  const _OperationSelector({
    required this.operation,
    required this.compact,
    required this.onPressed,
  });

  final String operation;
  final bool compact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.amber,
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.8)),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      icon: Text(
        operation,
        style: TextStyle(
          fontSize: compact ? 18 : 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      label: Icon(Icons.swap_horiz_rounded, size: compact ? 18 : 20),
    );
  }
}
