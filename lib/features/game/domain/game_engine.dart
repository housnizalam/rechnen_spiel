import 'dart:math';

import '../../../core/constants/game_constants.dart';
import 'game_models.dart';

/// Value object representing one generated exercise and its answer choices.
class GeneratedQuestion {
  /// Left-hand operand.
  final int firstNumber;

  /// Right-hand operand.
  final int secondNumber;

  /// Expected result for this exercise.
  final int correctAnswer;

  /// Four options shown to the player, including [correctAnswer].
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

/// Pure domain service that creates arithmetic exercises.
///
/// Operation behavior:
/// - `+`: random addends within stage bounds.
/// - `-`: operands are ordered to keep non-negative results.
/// - `*`: random factors within stage bounds.
/// - `/`: numbers are constructed so division is always exact.
class GameEngine {
  final Random _random = Random();

  /// Generates one question for the provided operation and stage.
  ///
  /// The stage index is clamped to valid bounds before generating numbers.
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

  /// Builds four unique answer options around the correct value.
  ///
  /// The result always contains [correctAnswer] and is shuffled for display.
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

  /// Generates a division tuple where `firstNumber / secondNumber` is integer.
  ///
  /// Guarantees:
  /// - `secondNumber` is never zero.
  /// - `firstNumber` is divisible by `secondNumber`.
  /// - `correctAnswer` is an integer quotient.
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
