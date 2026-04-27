import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/game_notifier.dart';
import '../widgets/answer_input.dart';
import '../widgets/evaluation.dart';
import '../widgets/exercise_display.dart';
import '../widgets/game_controller.dart';
import '../widgets/name_input.dart';
import '../widgets/stage_display.dart';
import '../widgets/timer_display.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(state.title,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        actions: [
          Center(
            child: state.calcOperation == null
                ? const SizedBox()
                : Text(state.calcOperation!.operation,
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
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.red,
              Color.fromARGB(255, 105, 5, 5),
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Color.fromARGB(255, 105, 5, 5),
              Color.fromARGB(255, 105, 5, 5),
              Colors.red,
              Colors.red,
            ],
          ),
        ),
        child: state.player == null
            ? const NameGeber()
            : Container(
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.red,
                      Color.fromARGB(255, 105, 5, 5),
                      Colors.black,
                      Colors.black,
                      Colors.black,
                      Colors.black,
                      Colors.black,
                      Colors.black,
                      Colors.black,
                      Color.fromARGB(255, 105, 5, 5),
                      Color.fromARGB(255, 105, 5, 5),
                      Colors.red,
                      Colors.red,
                    ],
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GibBerechnung(),
                    AufgabeDarstellung(),
                    AntwortEingabe(),
                    Bewertung(),
                    // Naechst(),
                    RechnungsDauer(),
                    StageDisplay()
                  ],
                ),
              ),
      ),
    );
  }
}
