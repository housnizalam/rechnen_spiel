import 'dart:math';

import 'package:rechnen_spiel/bloc/global_variablen.dart';
import 'package:rechnen_spiel/bloc/rechner_bloc.dart';

int gibUnBrimeNummer(AppState state) {
  List<int> listUnbrime = [];
  for (int i = 2; i < stages[state.actualStageSectioning]; i++) {
    int counter = 0;

    for (int j = 1; j < i; j++) {
      if (i % j == 0) {
        counter++;
      }
    }
    if (counter > 1) {
      listUnbrime.add(i);
    }
  }
  int listIndex = Random().nextInt(listUnbrime.length);
  int result = listUnbrime[listIndex];

  return result;
}

int gibPassendeTeilNummer(int firstNumber, int actualStageSectioning) {
  List<int> nummers = [];
  for (int i = 1; i < stages[actualStageSectioning]; i++) {
    if (firstNumber % i == 0) {
      nummers.add(i);
    }
  }
  int result = nummers[Random().nextInt(nummers.length)];
  return result;
}

bool answerValuation(AppState state, TestingEvent event) {
  if ((state.calcOperation == '+' && event.answer == state.firstNumber! + state.secondNumber!) ||
      (state.calcOperation == '-' && event.answer == state.firstNumber! - state.secondNumber!) ||
      (state.calcOperation == '*' && event.answer == state.firstNumber! * state.secondNumber!) ||
      (state.calcOperation == '/' && event.answer == state.firstNumber! / state.secondNumber!)) {
    return true;
  }
  return false;
}

List<int> getAnswersList(int firstNumber, int secondNumber) {
  int trueAnswer = firstNumber + secondNumber;
  List<int> wrongAnswers = [];
  List<int> result = [trueAnswer];
  int choosedNumber = 0;
  for (int i = 1; i < 11; i++) {
    wrongAnswers.add(trueAnswer + i);
    wrongAnswers.add(trueAnswer - i);
  }
  for (int i = 0; i < 3; i++) {
    choosedNumber = wrongAnswers[Random().nextInt(wrongAnswers.length)];
    result.add(choosedNumber);
    wrongAnswers.remove(choosedNumber);
  }
  result.sort();
  print(result);
  return result;
}
