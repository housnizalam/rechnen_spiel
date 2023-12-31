import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/app_bloc.dart';
import '../../../bloc/help_functions.dart';
import 'answer-sheet.dart';

class AntwortEingabe extends StatelessWidget {
  const AntwortEingabe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listener: (context, state) {},
      builder: (context, state) {
        List<int> answers = [0, 0, 0, 0];
        if (state.firstNumber != null && state.secondNumber != null) {
          answers =
              getAnswersList(state.firstNumber!, state.secondNumber!, state);
        }

        return state.trueAnswers == 8 ||
                state.allAnswers - state.trueAnswers > 2
            ? Expanded(
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    Expanded(child: Container()),
                    Expanded(child: Container()),
                    Expanded(child: Container()),
                  ],
                ),
              )
            : Expanded(
                child: Column(
                  children: [
                    Expanded(child: AnswerSheet(answer: answers[0])),
                    Expanded(child: AnswerSheet(answer: answers[1])),
                    Expanded(child: AnswerSheet(answer: answers[2])),
                    Expanded(child: AnswerSheet(answer: answers[3])),
                  ],
                ),
              );
      },
    );
  }
}
