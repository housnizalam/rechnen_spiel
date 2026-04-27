import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/game_constants.dart';
import '../domain/game_engine.dart';
import '../domain/game_models.dart';

/// High-level lifecycle for a stage play session.
enum GameStatus { idle, playing, won, failed }

/// Immutable UI/game snapshot consumed by Riverpod widgets.
///
/// The state carries both transient round data (current numbers/options)
/// and persistent progression data (current operation stage and player records).
class GameState {
  /// Historical stage counter incremented on stage win.
  final int stage;

  /// Optional title text used by the top app bar.
  final String title;

  /// Timestamp at which the current stage attempt started.
  ///
  /// Used to compute [period] when the player wins the stage.
  final DateTime? startTime;

  /// Optional free-form answer text slot kept for compatibility.
  final String? answer;

  /// Whether a question is currently considered active/displayed.
  final bool isQuestionGiven;

  /// Whether the current question has already been answered.
  final bool isAnswerGiven;

  /// Active arithmetic operation for question generation and scoring.
  final CalcOperation? calcOperation;

  /// Index of [calcOperationsList] used when cycling operations.
  final int operationIndex;

  /// Current unlocked stage index for addition.
  final int actualStageAddition;

  /// Current unlocked stage index for subtraction.
  final int actualStageSubtraction;

  /// Current unlocked stage index for multiplication.
  final int actualStageMultiplication;

  /// Current unlocked stage index for division.
  final int actualStageDivision;

  /// Left-hand operand of the current exercise.
  final int? firstNumber;

  /// Right-hand operand of the current exercise.
  final int? secondNumber;

  /// Correct result for the currently displayed exercise.
  final int correctAnswer;

  /// Four answer choices shown to the player, including [correctAnswer].
  final List<int> answerOptions;

  /// Human-readable feedback or progress string shown in the UI.
  final String evaluationMessage;

  /// Number of correct answers in the current stage attempt.
  final int trueAnswers;

  /// Number of total submitted answers in the current stage attempt.
  final int allAnswers;

  /// Stage completion duration in seconds.
  ///
  /// Set when the player wins, reset on stage transitions/restarts.
  final int period;

  /// Current stage lifecycle status.
  final GameStatus status;

  /// Active player profile and unlocked stage progress.
  final Player? player;

  const GameState({
    this.stage = 0,
    this.title = '',
    this.startTime,
    this.answer,
    this.isQuestionGiven = false,
    this.isAnswerGiven = false,
    this.calcOperation,
    this.operationIndex = 0,
    this.actualStageAddition = 0,
    this.actualStageSubtraction = 0,
    this.actualStageMultiplication = 0,
    this.actualStageDivision = 0,
    this.firstNumber,
    this.secondNumber,
    this.correctAnswer = 0,
    this.answerOptions = const [],
    this.evaluationMessage = '',
    this.trueAnswers = 0,
    this.allAnswers = 0,
    this.period = 0,
    this.status = GameStatus.idle,
    this.player,
  });

  GameState copyWith({
    int Function()? stage,
    String Function()? title,
    DateTime? Function()? startTime,
    String? Function()? answer,
    bool Function()? isQuestionGiven,
    bool Function()? isAnswerGiven,
    CalcOperation? Function()? calcOperation,
    int Function()? operationIndex,
    int Function()? actualStageAddition,
    int Function()? actualStageSubtraction,
    int Function()? actualStageMultiplication,
    int Function()? actualStageDivision,
    int? Function()? firstNumber,
    int? Function()? secondNumber,
    int Function()? correctAnswer,
    List<int> Function()? answerOptions,
    String Function()? evaluationMessage,
    int Function()? trueAnswers,
    int Function()? allAnswers,
    int Function()? period,
    GameStatus Function()? status,
    Player? Function()? player,
  }) {
    return GameState(
      stage: stage == null ? this.stage : stage(),
      title: title == null ? this.title : title(),
      startTime: startTime == null ? this.startTime : startTime(),
      answer: answer == null ? this.answer : answer(),
      isQuestionGiven:
          isQuestionGiven == null ? this.isQuestionGiven : isQuestionGiven(),
      isAnswerGiven:
          isAnswerGiven == null ? this.isAnswerGiven : isAnswerGiven(),
      calcOperation:
          calcOperation == null ? this.calcOperation : calcOperation(),
      operationIndex:
          operationIndex == null ? this.operationIndex : operationIndex(),
      actualStageAddition: actualStageAddition == null
          ? this.actualStageAddition
          : actualStageAddition(),
      actualStageSubtraction: actualStageSubtraction == null
          ? this.actualStageSubtraction
          : actualStageSubtraction(),
      actualStageMultiplication: actualStageMultiplication == null
          ? this.actualStageMultiplication
          : actualStageMultiplication(),
      actualStageDivision: actualStageDivision == null
          ? this.actualStageDivision
          : actualStageDivision(),
      firstNumber: firstNumber == null ? this.firstNumber : firstNumber(),
      secondNumber: secondNumber == null ? this.secondNumber : secondNumber(),
      correctAnswer:
          correctAnswer == null ? this.correctAnswer : correctAnswer(),
      answerOptions:
          answerOptions == null ? this.answerOptions : answerOptions(),
      evaluationMessage: evaluationMessage == null
          ? this.evaluationMessage
          : evaluationMessage(),
      trueAnswers: trueAnswers == null ? this.trueAnswers : trueAnswers(),
      allAnswers: allAnswers == null ? this.allAnswers : allAnswers(),
      period: period == null ? this.period : period(),
      status: status == null ? this.status : status(),
      player: player == null ? this.player : player(),
    );
  }
}

/// Riverpod state controller that drives the complete game flow.
///
/// Core flow:
/// - [startGame] generates a question for the active operation and stage.
/// - [submitAnswer] evaluates it, updates counters, and checks win/loss.
/// - [nextQuestion] clears the previous task and prepares the next one.
///
/// Win/Lose rules:
/// - Win when correct answers are greater than 7 (8 correct answers).
/// - Fail when mistakes are greater than 2 (3 mistakes).
///
/// Timer handling:
/// - [startTime] is set on stage start/restart.
/// - [period] is computed in seconds on stage win.
///
/// Stages and operations:
/// - Each operation tracks its own stage index.
/// - Stage progression and unlocked max stage are updated per operation.
class GameNotifier extends StateNotifier<GameState> {
  /// Question generator containing operation-specific math rules.
  final GameEngine gameEngine;

  GameNotifier(this.gameEngine) : super(const GameState());

  /// Cycles to the next arithmetic operation and resets round-local state.
  ///
  /// Call this from operation-switch UI actions. It keeps per-operation stage
  /// indices, but clears the current question, counters, and feedback.
  void chooseOperation() {
    int operationIndex = state.operationIndex;
    if (operationIndex == 3) {
      operationIndex = 0;
    } else {
      operationIndex++;
    }
    final calcOperation = CalcOperation(calcOperationsList[operationIndex]);
    state = state.copyWith(
      operationIndex: () => operationIndex,
      calcOperation: () => calcOperation,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      answer: () => null,
      isQuestionGiven: () => false,
      isAnswerGiven: () => false,
      evaluationMessage: () => '',
      status: () => GameStatus.idle,
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      period: () => 0,
    );
  }

  void giveName(String name) {
    final player = Player(name: name);
    final calcOperation = CalcOperation('+');
    state = state.copyWith(
      player: () => player,
      calcOperation: () => calcOperation,
      status: () => GameStatus.idle,
    );
  }

  /// Moves to the next stage of the currently selected operation.
  ///
  /// This updates only the active operation stage index and resets the current
  /// stage attempt counters/question state.
  void nextStage() {
    int actualStageAddition = state.actualStageAddition;
    int actualStageSubtraction = state.actualStageSubtraction;
    int actualStageMultiplication = state.actualStageMultiplication;
    int actualStageDivision = state.actualStageDivision;
    if (state.calcOperation!.operation == '+') {
      actualStageAddition++;
    } else if (state.calcOperation!.operation == '-') {
      actualStageSubtraction++;
    } else if (state.calcOperation!.operation == '*') {
      actualStageMultiplication++;
    } else if (state.calcOperation!.operation == '/') {
      actualStageDivision++;
    }
    state = state.copyWith(
      actualStageAddition: () => actualStageAddition,
      actualStageSubtraction: () => actualStageSubtraction,
      actualStageMultiplication: () => actualStageMultiplication,
      actualStageDivision: () => actualStageDivision,
      isQuestionGiven: () => false,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      period: () => 0,
      startTime: () => DateTime.now(),
      evaluationMessage: () => '',
      status: () => GameStatus.idle,
    );
  }

  /// Prepares state for the next question after an answer was submitted.
  ///
  /// This should be called after [submitAnswer]. It clears question data,
  /// keeps accumulated counters, and unlocks [startGame] for new generation.
  void nextQuestion() {
    if (!state.isAnswerGiven) {
      return;
    }
    state = state.copyWith(
      isQuestionGiven: () => false,
      evaluationMessage: () => '${state.trueAnswers} / ${state.allAnswers}',
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      answer: () => null,
      isAnswerGiven: () => false,
      status: () => GameStatus.idle,
    );
  }

  /// Moves to the previous stage of the current operation.
  ///
  /// Intended for stage navigation controls. It resets question/counter state
  /// for a fresh attempt at the selected earlier stage.
  void previousStage() {
    int actualStageAddition = state.actualStageAddition;
    int actualStageSubtraction = state.actualStageSubtraction;
    int actualStageMultiplication = state.actualStageMultiplication;
    int actualStageDivision = state.actualStageDivision;
    if (state.calcOperation!.operation == '+') {
      actualStageAddition--;
    } else if (state.calcOperation!.operation == '-') {
      actualStageSubtraction--;
    } else if (state.calcOperation!.operation == '*') {
      actualStageMultiplication--;
    } else if (state.calcOperation!.operation == '/') {
      actualStageDivision--;
    }
    state = state.copyWith(
      actualStageAddition: () => actualStageAddition,
      actualStageSubtraction: () => actualStageSubtraction,
      actualStageMultiplication: () => actualStageMultiplication,
      actualStageDivision: () => actualStageDivision,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      period: () => 0,
      isQuestionGiven: () => false,
      startTime: () => DateTime.now(),
      evaluationMessage: () => '',
      status: () => GameStatus.idle,
    );
  }

  void repeatStage() {
    final generatedQuestion = gameEngine.generateQuestion(
      operation: state.calcOperation!.operation,
      stageIndex: _activeStageIndex(),
      calcOperation: state.calcOperation!,
    );
    state = state.copyWith(
      allAnswers: () => 0,
      trueAnswers: () => 0,
      evaluationMessage: () => '',
      period: () => 0,
      isQuestionGiven: () => true,
      firstNumber: () => generatedQuestion.firstNumber,
      secondNumber: () => generatedQuestion.secondNumber,
      correctAnswer: () => generatedQuestion.correctAnswer,
      answerOptions: () => generatedQuestion.answerOptions,
      answer: () => null,
      isAnswerGiven: () => false,
      startTime: () => DateTime.now(),
      status: () => GameStatus.playing,
    );
  }

  /// Starts gameplay for the current stage by generating a question.
  ///
  /// Call this when entering a stage or after [nextQuestion]. The method keeps
  /// the same [startTime] during an ongoing stage attempt and sets status to
  /// [GameStatus.playing].
  void startGame() {
    DateTime startTime;
    if (state.startTime == null) {
      startTime = DateTime.now();
    } else {
      startTime = state.startTime!;
    }
    if (!state.isQuestionGiven) {
      final generatedQuestion = gameEngine.generateQuestion(
        operation: state.calcOperation!.operation,
        stageIndex: _activeStageIndex(),
        calcOperation: state.calcOperation!,
      );
      state = state.copyWith(
        firstNumber: () => generatedQuestion.firstNumber,
        secondNumber: () => generatedQuestion.secondNumber,
        correctAnswer: () => generatedQuestion.correctAnswer,
        answerOptions: () => generatedQuestion.answerOptions,
        isQuestionGiven: () => true,
        startTime: () => startTime,
        status: () => GameStatus.playing,
      );
    }
  }

  /// Evaluates a selected answer and updates progress/status.
  ///
  /// Effects:
  /// - Increments [trueAnswers] on correct submissions.
  /// - Increments [allAnswers] on every submission.
  /// - Sets [status] to won at 8 correct answers.
  /// - Sets [status] to failed at 3 mistakes.
  /// - Computes [period] in seconds when the stage is won.
  void submitAnswer(int answer) {
    if (state.firstNumber == null || state.secondNumber == null) {
      return;
    }

    int trueAnswers = state.trueAnswers;
    int allAnswers = state.allAnswers;
    String evaluationMessage = '';
    if (answer == state.correctAnswer) {
      trueAnswers++;
      allAnswers++;
      evaluationMessage = 'True Answer $trueAnswers / $allAnswers';
    } else {
      allAnswers++;
      evaluationMessage = 'false Answer $trueAnswers / $allAnswers';
    }
    if (trueAnswers > 7) {
      final player = Player(name: state.player?.name)
        ..maxStageAdition = state.player?.maxStageAdition ?? 0
        ..maxStageSubtruction = state.player?.maxStageSubtruction ?? 0
        ..maxStageMultiplication = state.player?.maxStageMultiplication ?? 0
        ..maxStageSection = state.player?.maxStageSection ?? 0;
      if (state.calcOperation!.operation == '+') {
        player.maxStageAdition++;
      } else if (state.calcOperation!.operation == '-') {
        player.maxStageSubtruction++;
      } else if (state.calcOperation!.operation == '*') {
        player.maxStageMultiplication++;
      } else if (state.calcOperation!.operation == '/') {
        player.maxStageSection++;
      }
      evaluationMessage = '${state.player!.name} wins';
      final period = DateTime.now().difference(state.startTime!).inSeconds;
      state = state.copyWith(
        isQuestionGiven: () => false,
        isAnswerGiven: () => true,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        evaluationMessage: () => evaluationMessage,
        status: () => GameStatus.won,
        stage: () => state.stage + 1,
        period: () => period,
        player: () => player,
      );
    } else if (allAnswers - trueAnswers > 2) {
      evaluationMessage = '${state.player!.name} failed';
      state = state.copyWith(
        isQuestionGiven: () => false,
        isAnswerGiven: () => true,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        evaluationMessage: () => evaluationMessage,
        status: () => GameStatus.failed,
      );
    } else {
      state = state.copyWith(
        isQuestionGiven: () => false,
        isAnswerGiven: () => true,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        evaluationMessage: () => evaluationMessage,
        status: () => GameStatus.playing,
      );
    }
  }

  void winToNextStage() {
    if (state.trueAnswers > 7) {
      final player = Player()
        ..name = state.player!.name
        ..maxStageAdition = state.player!.maxStageAdition
        ..maxStageSubtruction = state.player!.maxStageSubtruction
        ..maxStageMultiplication = state.player!.maxStageMultiplication
        ..maxStageSection = state.player!.maxStageSection;
      int stageAdition = state.actualStageAddition;
      int stageSubtruction = state.actualStageSubtraction;
      int stageMultiplication = state.actualStageMultiplication;
      int stageSectioning = state.actualStageDivision;
      if (state.calcOperation!.operation == '+' &&
          state.actualStageAddition + 1 < stages.length) {
        stageAdition++;
        player.maxStageAdition++;
      } else if (state.calcOperation!.operation == '-' &&
          state.actualStageSubtraction + 1 < stages.length) {
        stageSubtruction++;
        player.maxStageSubtruction++;
      } else if (state.calcOperation!.operation == '*' &&
          state.actualStageMultiplication + 1 < stages.length) {
        stageMultiplication++;
        player.maxStageMultiplication++;
      } else if (state.calcOperation!.operation == '/' &&
          state.actualStageDivision + 1 < stages.length) {
        stageSectioning++;
        player.maxStageSection++;
      }
      state = state.copyWith(
        player: () => player,
        actualStageAddition: () => stageAdition,
        actualStageSubtraction: () => stageSubtruction,
        actualStageMultiplication: () => stageMultiplication,
        actualStageDivision: () => stageSectioning,
        allAnswers: () => 0,
        startTime: () => DateTime.now(),
        trueAnswers: () => 0,
        period: () => 0,
        isAnswerGiven: () => false,
        evaluationMessage: () => '',
        correctAnswer: () => 0,
        answerOptions: () => const [],
        status: () => GameStatus.idle,
      );
    }
  }

  int _activeStageIndex() {
    final lastIndex = stages.length - 1;
    if (state.calcOperation!.operation == '+') {
      return state.actualStageAddition.clamp(0, lastIndex);
    }
    if (state.calcOperation!.operation == '-') {
      return state.actualStageSubtraction.clamp(0, lastIndex);
    }
    if (state.calcOperation!.operation == '*') {
      return state.actualStageMultiplication.clamp(0, lastIndex);
    }
    return state.actualStageDivision.clamp(0, lastIndex);
  }
}

/// Global Riverpod provider exposing [GameNotifier] and [GameState].
final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  final engine = ref.read(gameEngineProvider);
  return GameNotifier(engine);
});
