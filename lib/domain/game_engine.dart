import 'dart:math';

import '../bloc/bloc_classes.dart';
import '../bloc/global_variablen.dart';

class GeneratedQuestion {
  final int firstNumber;
  final int secondNumber;
  final int correctAnswer;
  final List<int> answerOptions;

  const GeneratedQuestion({
    required this.firstNumber,
    required this.secondNumber,
    required this.correctAnswer,
    required this.answerOptions,
  });
}

class GameEngine {
  GeneratedQuestion generateQuestion({
    required String operation,
    required int stageIndex,
    required CalcOperation calcOperation,
  }) {
    int firstNumber;
    int secondNumber;

    if (operation == '/') {
      firstNumber = _generateCompositeNumber(stageIndex);
      secondNumber = _generateDivisor(firstNumber, stageIndex);
    } else {
      final maxNumber = stages[stageIndex];
      firstNumber = Random().nextInt(maxNumber);
      secondNumber = Random().nextInt(maxNumber);
    }

    final correctAnswer = calcOperation.calculate(firstNumber, secondNumber);
    final answerOptions = generateAnswerOptions(correctAnswer);

    return GeneratedQuestion(
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      correctAnswer: correctAnswer,
      answerOptions: answerOptions,
    );
  }

  List<int> generateAnswerOptions(int correctAnswer) {
    final wrongAnswers = <int>[];
    final result = <int>[correctAnswer];

    for (int i = 1; i < 11; i++) {
      wrongAnswers.add(correctAnswer + i);
      wrongAnswers.add(correctAnswer - i);
    }

    for (int i = 0; i < 3; i++) {
      final chosenNumber = wrongAnswers[Random().nextInt(wrongAnswers.length)];
      result.add(chosenNumber);
      wrongAnswers.remove(chosenNumber);
    }

    result.sort();
    return result;
  }

  int _generateCompositeNumber(int stageIndex) {
    final nonPrimeNumbers = <int>[];
    for (int i = 2; i < stages[stageIndex]; i++) {
      int counter = 0;
      for (int j = 1; j < i; j++) {
        if (i % j == 0) {
          counter++;
        }
      }
      if (counter > 1) {
        nonPrimeNumbers.add(i);
      }
    }
    return nonPrimeNumbers[Random().nextInt(nonPrimeNumbers.length)];
  }

  int _generateDivisor(int firstNumber, int stageIndex) {
    final divisors = <int>[];
    for (int i = 1; i < stages[stageIndex]; i++) {
      if (firstNumber % i == 0) {
        divisors.add(i);
      }
    }
    return divisors[Random().nextInt(divisors.length)];
  }
}
