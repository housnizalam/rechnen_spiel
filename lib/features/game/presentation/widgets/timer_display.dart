import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

class RechnungsDauer extends ConsumerWidget {
  const RechnungsDauer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    final period = state.period;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text('$period Sec',
            style: const TextStyle(
                color: Colors.amber,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
