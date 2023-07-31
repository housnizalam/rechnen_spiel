import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rechnen_spiel/bloc/rechner_bloc.dart';

class StufeZeiger extends StatelessWidget {
  const StufeZeiger({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: Icon(
                Icons.arrow_drop_down,
                size: 60,
                color: state.calcOperation == '+' && state.actualStageAdition > 0 ||
                        state.calcOperation == '-' && state.actualStageSubtruction > 0 ||
                        state.calcOperation == '*' && state.actualStageMultiplication > 0 ||
                        state.calcOperation == '/' && state.actualStageSectioning > 0
                    ? Colors.amber
                    : Color.fromARGB(0, 158, 158, 158),
              ),
              onTap: () {
                if (state.calcOperation == '+' && state.actualStageAdition > 0 ||
                    state.calcOperation == '-' && state.actualStageSubtruction > 0 ||
                    state.calcOperation == '*' && state.actualStageMultiplication > 0 ||
                    state.calcOperation == '/' && state.actualStageSectioning > 0) {
                  BlocProvider.of<AppBloc>(context).add(PreviosStageEvent());
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: state.calcOperation == '+'
                  ? Text('Stage ${state.actualStageAdition + 1}',
                      style: const TextStyle(color: Colors.amber, fontSize: 40, fontWeight: FontWeight.bold))
                  : state.calcOperation == '-'
                      ? Text('Stage ${state.actualStageSubtruction + 1}',
                          style: const TextStyle(color: Colors.amber, fontSize: 40, fontWeight: FontWeight.bold))
                      : state.calcOperation == '*'
                          ? Text('Stage ${state.actualStageMultiplication + 1}',
                              style: const TextStyle(color: Colors.amber, fontSize: 40, fontWeight: FontWeight.bold))
                          : Text(
                              'Stage ${state.actualStageSectioning + 1}',
                              style: const TextStyle(color: Colors.amber, fontSize: 40, fontWeight: FontWeight.bold),
                            ),
            ),
            // : Text('Stufe',
            //     style: const TextStyle(color: Colors.amber, fontSize: 40, fontWeight: FontWeight.bold))),
            InkWell(
              child: Icon(
                Icons.arrow_drop_up,
                size: 60,
                color: state.calcOperation == '+' && state.actualStageAdition < state.player!.maxStageAdition ||
                        state.calcOperation == '-' &&
                            state.actualStageSubtruction < state.player!.maxStageSubtruction ||
                        state.calcOperation == '*' &&
                            state.actualStageMultiplication < state.player!.maxStageMultiplication ||
                        state.calcOperation == '/' && state.actualStageSectioning < state.player!.maxStageSection
                    ? Colors.amber
                    : Color.fromARGB(0, 158, 158, 158),
              ),
              onTap: () {
                if (state.calcOperation == '+' && state.actualStageAdition < state.player!.maxStageAdition ||
                    state.calcOperation == '-' && state.actualStageSubtruction < state.player!.maxStageSubtruction ||
                    state.calcOperation == '*' &&
                        state.actualStageMultiplication < state.player!.maxStageMultiplication ||
                    state.calcOperation == '/' && state.actualStageSectioning < state.player!.maxStageSection) {
                  BlocProvider.of<AppBloc>(context).add(NextStageEvent());
                }
              },
            )
          ],
        );
      },
    );
  }
}
