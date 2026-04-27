import 'dart:math';

import '../../../core/constants/game_constants.dart';
import 'game_models.dart';

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

class _DivisionQuestion {
  final int firstNumber;
  final int secondNumber;
  final int correctAnswer;

  const _DivisionQuestion({
    required this.firstNumber,
    required this.secondNumber,
    required this.correctAnswer,
  });
}

class GameEngine {
  final Random _random = Random();

  GeneratedQuestion generateQuestion({
    required String operation,
    required int stageIndex,
    required CalcOperation calcOperation,
  }) {
    final safeStageIndex = stageIndex.clamp(0, stages.length - 1);
    final maxNumber = stages[safeStageIndex];
    int firstNumber;
    int secondNumber;
    int correctAnswer;

    switch (operation) {
      case '+':
        firstNumber = _random.nextInt(maxNumber);
        secondNumber = _random.nextInt(maxNumber);
        correctAnswer = firstNumber + secondNumber;
        break;
      case '-':
        firstNumber = _random.nextInt(maxNumber);
        secondNumber = _random.nextInt(maxNumber);
        if (secondNumber > firstNumber) {
          final temp = firstNumber;
          firstNumber = secondNumber;
          secondNumber = temp;
        }
        correctAnswer = firstNumber - secondNumber;
        break;
      case '*':
        firstNumber = _random.nextInt(maxNumber);
        secondNumber = _random.nextInt(maxNumber);
        correctAnswer = firstNumber * secondNumber;
        break;
      case '/':
        final generatedDivision = _generateDivisionQuestion(maxNumber);
        firstNumber = generatedDivision.firstNumber;
        secondNumber = generatedDivision.secondNumber;
        correctAnswer = generatedDivision.correctAnswer;
        break;
      default:
        firstNumber = _random.nextInt(maxNumber);
        secondNumber = _random.nextInt(maxNumber);
        correctAnswer = calcOperation.calculate(firstNumber, secondNumber);
    }

    final answerOptions = generateAnswerOptions(correctAnswer);

    return GeneratedQuestion(
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      correctAnswer: correctAnswer,
      answerOptions: answerOptions,
    );
  }

  List<int> generateAnswerOptions(int correctAnswer) {
    final options = <int>{correctAnswer};
    int delta = 1;

    while (options.length < 4) {
      options.add(correctAnswer + delta);
      if (options.length < 4) {
        options.add(correctAnswer - delta);
      }
      delta++;
    }

    final result = options.toList()..shuffle(_random);
    return result;
  }

  _DivisionQuestion _generateDivisionQuestion(int maxNumber) {
    final safeMax = max(maxNumber, 2);

    while (true) {
      final secondNumber = _random.nextInt(safeMax - 1) + 1;
      final maxQuotient = (safeMax - 1) ~/ secondNumber;
      if (maxQuotient < 1) {
        continue;
      }

      final correctAnswer = _random.nextInt(maxQuotient) + 1;
      final firstNumber = secondNumber * correctAnswer;
      return _DivisionQuestion(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: correctAnswer,
      );
    }
  }
}
