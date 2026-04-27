import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/app_bloc.dart';
import 'answer_sheet.dart';

class AntwortEingabe extends StatelessWidget {
  const AntwortEingabe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final List<int> answers = state.answerOptions.length == 4
            ? state.answerOptions
            : const [0, 0, 0, 0];

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
