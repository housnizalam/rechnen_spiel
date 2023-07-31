import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rechnen_spiel/Widgets/main_seite/giving-answer/antwort_einagabe.dart';
import 'package:rechnen_spiel/Widgets/main_seite/exercise_desplay.dart';
import 'package:rechnen_spiel/Widgets/main_seite/evaluation.dart';
import 'package:rechnen_spiel/Widgets/main_seite/periode_desplay.dart';
import 'package:rechnen_spiel/Widgets/main_seite/game_controller.dart';
import 'package:rechnen_spiel/Widgets/main_seite/next.dart';
import 'package:rechnen_spiel/Widgets/main_seite/name.dart';
import 'package:rechnen_spiel/Widgets/main_seite/stage_display.dart';
import 'package:rechnen_spiel/bloc/app_bloc.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocProvider<AppBloc>(
      create: (BuildContext context) => AppBloc(),
      child: BlocConsumer<AppBloc, AppState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.title,
                  style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
              actions: [
                Center(
                  child: Text(state.calcOperation,
                      style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold)),
                ),
                Center(
                    child: IconButton(
                  icon: const Icon(
                    Icons.change_circle_sharp,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    BlocProvider.of<AppBloc>(context).add(ChooseOperationEvent());
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
                          StufeZeiger()
                        ],
                      ),
                    ),
            ),
          );
        },
        listener: (context, state) {},
      ),
    );
  }
}
