import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';

/// Name entry field shown before gameplay starts.
class NameInput extends ConsumerWidget {
  const NameInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController name = TextEditingController();

    return TextFormField(
      onTap: () {
        if (name.text.isNotEmpty) {
          ref.read(gameNotifierProvider.notifier).giveName(name.text);
        }
      },
      style: const TextStyle(
          color: Colors.red, fontSize: 40, fontWeight: FontWeight.bold),
      controller: name,
      decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          labelText: '  Deine Name',
          labelStyle: TextStyle(
              color: Colors.red, fontSize: 30, fontWeight: FontWeight.bold)),
    );
  }
}
