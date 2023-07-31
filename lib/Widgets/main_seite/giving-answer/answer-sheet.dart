import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rechnen_spiel/bloc/rechner_bloc.dart';

class AnswerSheet extends StatelessWidget {
  final int answer;
  const AnswerSheet({
    super.key,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        double width = MediaQuery.of(context).size.width;

        return state.firstNumber != null && state.secondNumber != null
            ? InkWell(
                child: SizedBox(
                  width: width * 0.5,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        answer.toString(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                    ),
                  ),
                ),
                onTap: () {
                  if (!state.valuation.contains('failed') && !state.valuation.contains('wins')) {
                    BlocProvider.of<AppBloc>(context).add(TestingEvent(answer: answer));
                    BlocProvider.of<AppBloc>(context).add(NextTaskEvent());
                    BlocProvider.of<AppBloc>(context).add(StartGameEvent());
                  }
                },
              )
            : Container();
      },
    );
  }
}
