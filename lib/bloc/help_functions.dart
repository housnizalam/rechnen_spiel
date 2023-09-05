import 'dart:math';

import 'app_bloc.dart';
import 'global_variablen.dart';

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
  if ((state.calcOperation!.operation == '+' &&
          event.answer == state.firstNumber! + state.secondNumber!) ||
      (state.calcOperation!.operation == '-' &&
          event.answer == state.firstNumber! - state.secondNumber!) ||
      (state.calcOperation!.operation == '*' &&
          event.answer == state.firstNumber! * state.secondNumber!) ||
      (state.calcOperation!.operation == '/' &&
          event.answer == state.firstNumber! / state.secondNumber!)) {
    return true;
  }
  return false;
}

List<int> getAnswersList(int firstNumber, int secondNumber, AppState appstate) {
  int trueAnswer = appstate.calcOperation!.calculate(firstNumber, secondNumber);
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
  return result;
}

String numberToOperation(String operation, int number, AppState state) {
  String result = '';
  int firstnumber;
  int secondnumber;
  if (operation == '+') {
    secondnumber = Random().nextInt(stages[state.stage]);
    firstnumber = number - secondnumber;
    result = '$firstnumber+$secondnumber';
    return result;
  }
  if (operation == '-') {
    secondnumber = Random().nextInt(stages[state.stage]);
    firstnumber = number + secondnumber;
    result = '$firstnumber-$secondnumber';
    return result;
  }
  if (operation == '*') {
    List<int> sutable = [];
    for (int i = 1; i <= number; i++) {
      if (number % i == 0) {
        sutable.add(i);
      }
    }
    secondnumber = sutable[Random().nextInt(sutable.length)];
    firstnumber = number ~/ secondnumber;
    result = result = '$firstnumber*$secondnumber';
    return result;
  }
  return result;
}
