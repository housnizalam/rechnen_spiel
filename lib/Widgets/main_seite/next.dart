import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/app_bloc.dart';

class Naechst extends StatelessWidget {
  const Naechst({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: state.isAnswerGived
                            ? const MaterialStatePropertyAll(Colors.red)
                            : const MaterialStatePropertyAll(
                                Color.fromARGB(0, 158, 158, 158))),
                    onPressed: () {
                      state.trueAnswers < 8 && state.allAnswers < 10 ||
                              state.trueAnswers < 8 && state.allAnswers > 9
                          ? BlocProvider.of<AppBloc>(context)
                              .add(NextTaskEvent())
                          : BlocProvider.of<AppBloc>(context)
                              .add(WinToNextStageEvent());
                    },
                    child: state.trueAnswers < 8 && state.allAnswers > 9
                        ? const Text('Stufe Wiederholen',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))
                        : state.trueAnswers < 8
                            ? const Text('Nächste Aufgabe',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))
                            : const Text('Nächste Stufe',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<AppBloc>(context)
                          .add(WinToNextStageEvent());
                    },
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.black,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}
