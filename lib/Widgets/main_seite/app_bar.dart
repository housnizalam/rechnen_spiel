import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/game_notifier.dart';

class ApBar extends ConsumerWidget {
  const ApBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    return AppBar(
      title: Text(state.title,
          style: const TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      actions: [
        Center(
          child: Text(state.calcOperation!.operation,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.bold)),
        ),
        Center(
            child: IconButton(
          icon: const Icon(
            Icons.change_circle_sharp,
            color: Colors.black,
          ),
          onPressed: () {
            ref.read(gameNotifierProvider.notifier).chooseOperation();
          },
        ))
      ],
    );
  }
}
