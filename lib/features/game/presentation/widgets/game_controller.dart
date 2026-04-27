import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

/// Main action button that starts gameplay, repeats stage, or advances stage.
class GameController extends ConsumerWidget {
  const GameController({Key? key, this.compact = false}) : super(key: key);

  final bool compact;

  static const _buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  ButtonStyle _buttonStyle({required Color background, bool dense = false}) {
    final minHeight = dense || compact ? 44.0 : 52.0;
    final fontSize = dense || compact ? 15.0 : 18.0;
    return ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: Colors.amber,
      minimumSize: Size(double.infinity, minHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      side: const BorderSide(color: Colors.amber, width: 1.2),
      textStyle: _buttonTextStyle.copyWith(fontSize: fontSize),
      padding: EdgeInsets.symmetric(vertical: dense || compact ? 8 : 12),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final notifier = ref.read(gameNotifierProvider.notifier);

    if (state.status == GameStatus.playing) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: _buttonStyle(
                background: const Color.fromARGB(255, 120, 0, 0),
                dense: true,
              ),
              onPressed: notifier.repeatStage,
              child: const Text('Repeat Stage'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: _buttonStyle(background: Colors.red, dense: true),
              onPressed: notifier.stopGame,
              child: const Text('Stop Game'),
            ),
          ),
        ],
      );
    }

    if (state.status == GameStatus.won) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: _buttonStyle(background: Colors.red),
              onPressed: notifier.winToNextStage,
              child: const Text('Next Stage'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: _buttonStyle(
                  background: const Color.fromARGB(255, 120, 0, 0)),
              onPressed: notifier.repeatStage,
              child: const Text('Repeat Stage'),
            ),
          ),
        ],
      );
    }

    if (state.status == GameStatus.failed) {
      return ElevatedButton(
        style: _buttonStyle(background: Colors.red),
        onPressed: notifier.repeatStage,
        child: const Text('Repeat Stage'),
      );
    }

    if (state.status == GameStatus.idle) {
      return ElevatedButton(
        style: _buttonStyle(background: Colors.red),
        onPressed: notifier.startGame,
        child: const Text('Start Game'),
      );
    }

    return Padding(
      padding: EdgeInsets.zero,
      child: ElevatedButton(
        style: _buttonStyle(background: Colors.red),
        onPressed: notifier.startGame,
        child: const Text('Start Game'),
      ),
    );
  }
}
