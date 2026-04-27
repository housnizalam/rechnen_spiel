import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

final liveElapsedSecondsProvider = StreamProvider.autoDispose<double>((ref) {
  final state = ref.watch(gameNotifierProvider);

  if (state.status == GameStatus.won) {
    return Stream<double>.value(state.period);
  }

  if (state.status != GameStatus.playing || state.startTime == null) {
    return Stream<double>.value(0.0);
  }

  final start = state.startTime!;
  return Stream<double>.periodic(
    const Duration(milliseconds: 100),
    (_) => DateTime.now().difference(start).inMilliseconds / 1000.0,
  );
});

/// Shows the recorded stage duration in seconds.
class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsedAsync = ref.watch(liveElapsedSecondsProvider);
    final elapsed = elapsedAsync.maybeWhen(
      data: (value) => value,
      orElse: () => 0.0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.6)),
      ),
      child: Text(
        '${elapsed.toStringAsFixed(1)} Sec',
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
