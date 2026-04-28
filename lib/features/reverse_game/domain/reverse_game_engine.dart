import 'dart:math';

import 'reverse_game_models.dart';

/// Generates questions and answer options for Reverse Operation mode.
///
/// In Reverse mode the player is shown a *result* number and must identify
/// the expression that produces that result from four choices.
///
/// This engine is intentionally minimal for the foundation step.
class ReverseGameEngine {
  static final Random _random = Random();

  static const List<String> _operations = ['+', '-', '*', '/'];

  /// Generates a target result and four [ReverseAnswerOption]s, exactly one
  /// of which is correct, and returns a [ReverseRound] containing all data.
  ReverseRound generateRound({
    required String operation,
    required int stage,
  }) {
    final op = (operation == 'R')
        ? _operations[_random.nextInt(_operations.length)]
        : operation;

    final maxValue = _stageMax(stage);

    // Generate the correct expression first.
    final correct = _generateOption(op, maxValue);
    final result = correct.result;

    // Generate three wrong distractors whose results differ from `result`.
    final options = <ReverseAnswerOption>[correct];
    int attempts = 0;
    while (options.length < 4 && attempts < 300) {
      attempts++;
      final dOp = operation == 'R'
          ? _operations[_random.nextInt(_operations.length)]
          : op;
      final distractor = _generateOption(dOp, maxValue);
      if (distractor.result == result) continue;
      if (_matchesAny(options, distractor)) continue;
      options.add(distractor);
    }

    // Absolute safety: if random generation did not fill all distractors,
    // add deterministic fallbacks that still respect the selected operation.
    int seed = 2;
    while (options.length < 4) {
      final fallbackOp = operation == 'R' ? _operations[seed % 4] : op;
      final fallback = _fallbackOption(
        operation: fallbackOp,
        maxValue: maxValue,
        seed: seed,
      );
      if (fallback.result != result && !_matchesAny(options, fallback)) {
        options.add(fallback);
      }
      seed++;
    }

    options.shuffle(_random);
    final correctIndex = options.indexWhere(
      (o) =>
          o.firstNumber == correct.firstNumber &&
          o.secondNumber == correct.secondNumber &&
          o.operation == correct.operation &&
          o.result == correct.result,
    );

    return ReverseRound(
      targetResult: result,
      options: options,
      correctIndex: correctIndex,
    );
  }

  bool _matchesAny(
    List<ReverseAnswerOption> options,
    ReverseAnswerOption candidate,
  ) {
    return options.any(
      (option) =>
          option.firstNumber == candidate.firstNumber &&
          option.secondNumber == candidate.secondNumber &&
          option.operation == candidate.operation &&
          option.result == candidate.result,
    );
  }

  ReverseAnswerOption _fallbackOption({
    required String operation,
    required int maxValue,
    required int seed,
  }) {
    final safeValue = max(2, maxValue);

    switch (operation) {
      case '+':
        return ReverseAnswerOption(
          firstNumber: safeValue,
          secondNumber: seed,
          operation: '+',
          result: safeValue + seed,
        );
      case '-':
        return ReverseAnswerOption(
          firstNumber: safeValue + seed,
          secondNumber: seed,
          operation: '-',
          result: safeValue,
        );
      case '*':
        return ReverseAnswerOption(
          firstNumber: max(2, seed),
          secondNumber: max(2, safeValue ~/ 2),
          operation: '*',
          result: max(2, seed) * max(2, safeValue ~/ 2),
        );
      case '/':
        final divisor = max(1, min(seed, 9));
        final quotient = max(2, safeValue ~/ 2);
        return ReverseAnswerOption(
          firstNumber: divisor * quotient,
          secondNumber: divisor,
          operation: '/',
          result: quotient,
        );
      default:
        return ReverseAnswerOption(
          firstNumber: safeValue,
          secondNumber: seed,
          operation: '+',
          result: safeValue + seed,
        );
    }
  }

  ReverseAnswerOption _generateOption(String operation, int maxValue) {
    if (operation == '/') {
      final divisor = _random.nextInt(max(2, maxValue ~/ 2)) + 1;
      final quotient = _random.nextInt(maxValue) + 1;
      final dividend = divisor * quotient;
      return ReverseAnswerOption(
        firstNumber: dividend,
        secondNumber: divisor,
        operation: '/',
        result: quotient,
      );
    }

    if (operation == '-') {
      final a = _random.nextInt(maxValue) + 1;
      final b = _random.nextInt(a) + 1;
      return ReverseAnswerOption(
        firstNumber: a,
        secondNumber: b,
        operation: operation,
        result: _compute(a, b, operation),
      );
    }

    final a = _random.nextInt(maxValue) + 1;
    final b = _random.nextInt(maxValue) + 1;
    return ReverseAnswerOption(
      firstNumber: a,
      secondNumber: b,
      operation: operation,
      result: _compute(a, b, operation),
    );
  }

  int _compute(int a, int b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return b == 0 ? 0 : a ~/ b;
      default:
        return a + b;
    }
  }

  int _stageMax(int stage) {
    if (stage <= 0) return 10; // Stage 1 => 1..10
    if (stage == 1) return 20; // Stage 2 => 1..20
    return 20 + ((stage - 1) * 10); // Stage 3+ grows gradually
  }
}
