import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rechnen_spiel/bloc/app_bloc.dart';

class GibBerechnung extends StatelessWidget {
  const GibBerechnung({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              if (state.valuation.contains('failed')) {
                BlocProvider.of<AppBloc>(context).add(RepeatStageEvent());
              } else if (state.valuation.contains('wins')) {
                BlocProvider.of<AppBloc>(context).add(WinToNextStageEvent());
              } else {
                BlocProvider.of<AppBloc>(context).add(StartGameEvent());
              }
            },
            child: state.allAnswers == 0
                ? const Text(
                    'Start the game',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  )
                : !state.valuation.contains('wins')
                    ? const Text(
                        'restart',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      )
                    : const Text(
                        'Next Stage',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
          ),
        );
      },
    );
  }
}
