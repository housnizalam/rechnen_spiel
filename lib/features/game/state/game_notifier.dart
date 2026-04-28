import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/game_constants.dart';
import '../../user/data/user_storage_service.dart';
import '../../user/domain/game_record.dart';
import '../../user/domain/user_profile.dart';
import '../../user/state/user_providers.dart';
import '../domain/game_engine.dart';
import '../domain/game_models.dart';

/// High-level lifecycle for a stage play session.
enum GameStatus { idle, playing, won, failed }

/// One-shot UI feedback events emitted from game state transitions.
enum GameFeedbackType { none, correct, wrong, stageSuccess, newRecord, loss }

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

  /// Actual operation used for the current exercise when calcOperation is Random.
  /// Otherwise, matches calcOperation.operation.
  final String actualOperation;

  /// Current unlocked stage index for addition.
  final int actualStageAddition;

  /// Current unlocked stage index for subtraction.
  final int actualStageSubtraction;

  /// Current unlocked stage index for multiplication.
  final int actualStageMultiplication;

  /// Current unlocked stage index for division.
  final int actualStageDivision;

  /// Current unlocked stage index for random operation.
  final int actualStageRandom;

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
  final double period;

  /// Current stage lifecycle status.
  final GameStatus status;

  /// Last game feedback event the UI should react to.
  final GameFeedbackType lastFeedbackType;

  /// Monotonic counter used to emit repeated feedback of the same type.
  final int feedbackVersion;

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
    this.actualOperation = '+',
    this.actualStageAddition = 0,
    this.actualStageSubtraction = 0,
    this.actualStageMultiplication = 0,
    this.actualStageDivision = 0,
    this.actualStageRandom = 0,
    this.firstNumber,
    this.secondNumber,
    this.correctAnswer = 0,
    this.answerOptions = const [],
    this.evaluationMessage = '',
    this.trueAnswers = 0,
    this.allAnswers = 0,
    this.period = 0.0,
    this.status = GameStatus.idle,
    this.lastFeedbackType = GameFeedbackType.none,
    this.feedbackVersion = 0,
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
    String Function()? actualOperation,
    int Function()? actualStageAddition,
    int Function()? actualStageSubtraction,
    int Function()? actualStageMultiplication,
    int Function()? actualStageDivision,
    int Function()? actualStageRandom,
    int? Function()? firstNumber,
    int? Function()? secondNumber,
    int Function()? correctAnswer,
    List<int> Function()? answerOptions,
    String Function()? evaluationMessage,
    int Function()? trueAnswers,
    int Function()? allAnswers,
    double Function()? period,
    GameStatus Function()? status,
    GameFeedbackType Function()? lastFeedbackType,
    int Function()? feedbackVersion,
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
      actualOperation:
          actualOperation == null ? this.actualOperation : actualOperation(),
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
      actualStageRandom: actualStageRandom == null
          ? this.actualStageRandom
          : actualStageRandom(),
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
      lastFeedbackType:
          lastFeedbackType == null ? this.lastFeedbackType : lastFeedbackType(),
      feedbackVersion:
          feedbackVersion == null ? this.feedbackVersion : feedbackVersion(),
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
  final UserStorageService userStorageService;

  GameNotifier(this.gameEngine, this.userStorageService)
      : super(const GameState());

  void _debugGenerationLog(String source, int stageIndex) {
    if (kDebugMode) {
      debugPrint(
        '[GameNotifier] generateQuestion source=$source operation=${state.calcOperation?.operation} stageIndex=$stageIndex status=${state.status}',
      );
    }
  }

  /// Cycles to the next arithmetic operation and resets round-local state.
  ///
  /// Call this from operation-switch UI actions. It keeps per-operation stage
  /// cycles through supported operations.
  /// If not playing, it changes the [operationIndex] and resets staging data.
  ///
  /// The new operation updates [calcOperation], clears stage-progress indices, but clears the current question, counters, and feedback.
  void chooseOperation() {
    if (state.status == GameStatus.playing) {
      if (kDebugMode) {
        debugPrint('[GameNotifier] chooseOperation ignored while playing');
      }
      return;
    }
    int operationIndex = state.operationIndex;
    if (operationIndex >= calcOperationsList.length - 1) {
      operationIndex = 0;
    } else {
      operationIndex++;
    }
    _applyOperationSelection(operationIndex);
  }

  /// Selects a concrete operation symbol from [calcOperationsList].
  void selectOperation(String operationSymbol) {
    if (state.status == GameStatus.playing) {
      if (kDebugMode) {
        debugPrint('[GameNotifier] selectOperation ignored while playing');
      }
      return;
    }
    final operationIndex = calcOperationsList.indexOf(operationSymbol);
    if (operationIndex < 0) {
      return;
    }
    _applyOperationSelection(operationIndex);
  }

  void _applyOperationSelection(int operationIndex) {
    final calcOperation = CalcOperation(calcOperationsList[operationIndex]);
    state = state.copyWith(
      operationIndex: () => operationIndex,
      calcOperation: () => calcOperation,
      actualOperation: () => calcOperationsList[operationIndex] == 'R'
          ? '+'
          : calcOperationsList[operationIndex],
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
      startTime: () => null,
      period: () => 0.0,
    );
  }

  void giveName(
    String name, {
    String? userId,
    DateTime? createdAt,
    List<GameRecord>? gameRecords,
  }) {
    final records = List<GameRecord>.from(gameRecords ?? <GameRecord>[]);
    final additionIndex = _nextPlayableStageIndexFromRecords(records, '+');
    final subtractionIndex = _nextPlayableStageIndexFromRecords(records, '-');
    final multiplicationIndex =
        _nextPlayableStageIndexFromRecords(records, '*');
    final divisionIndex = _nextPlayableStageIndexFromRecords(records, '/');
    final randomIndex = _nextPlayableStageIndexFromRecords(records, 'R');

    final player = Player(
      id: userId,
      name: name,
      createdAt: createdAt,
      gameRecords: records,
    );
    player.maxStageAdition = additionIndex;
    player.maxStageSubtruction = subtractionIndex;
    player.maxStageMultiplication = multiplicationIndex;
    player.maxStageSection = divisionIndex;
    player.maxStageRandom = randomIndex;

    final calcOperation = CalcOperation('+');
    state = state.copyWith(
      player: () => player,
      calcOperation: () => calcOperation,
      operationIndex: () => 0,
      actualOperation: () => '+',
      actualStageAddition: () => additionIndex,
      actualStageSubtraction: () => subtractionIndex,
      actualStageMultiplication: () => multiplicationIndex,
      actualStageDivision: () => divisionIndex,
      actualStageRandom: () => randomIndex,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      evaluationMessage: () => '',
      isQuestionGiven: () => false,
      isAnswerGiven: () => false,
      answer: () => null,
      startTime: () => null,
      period: () => 0.0,
      status: () => GameStatus.idle,
    );
  }

  void giveUserProfile(UserProfile profile) {
    giveName(
      profile.name,
      userId: profile.id,
      createdAt: profile.createdAt,
      gameRecords: profile.gameRecords,
    );
  }

  /// Moves to the next stage of the currently selected operation.
  ///
  /// This updates only the active operation stage index and resets the current
  /// stage attempt counters/question state.
  void nextStage() {
    if (state.status == GameStatus.playing) {
      return;
    }
    int actualStageAddition = state.actualStageAddition;
    int actualStageSubtraction = state.actualStageSubtraction;
    int actualStageMultiplication = state.actualStageMultiplication;
    int actualStageDivision = state.actualStageDivision;
    int actualStageRandom = state.actualStageRandom;
    if (state.calcOperation!.operation == '+') {
      actualStageAddition++;
    } else if (state.calcOperation!.operation == '-') {
      actualStageSubtraction++;
    } else if (state.calcOperation!.operation == '*') {
      actualStageMultiplication++;
    } else if (state.calcOperation!.operation == '/') {
      actualStageDivision++;
    } else if (state.calcOperation!.operation == 'R') {
      actualStageRandom++;
    }
    state = state.copyWith(
      actualStageAddition: () => actualStageAddition,
      actualStageSubtraction: () => actualStageSubtraction,
      actualStageMultiplication: () => actualStageMultiplication,
      actualStageDivision: () => actualStageDivision,
      actualStageRandom: () => actualStageRandom,
      isQuestionGiven: () => false,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      period: () => 0.0,
      startTime: () => null,
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
    if (state.status == GameStatus.won || state.status == GameStatus.failed) {
      return;
    }
    state = state.copyWith(
      isQuestionGiven: () => false,
      evaluationMessage: () =>
          'Progress: ${state.trueAnswers} of ${state.allAnswers}',
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      answer: () => null,
      isAnswerGiven: () => false,
      status: () => GameStatus.playing,
    );
  }

  /// Moves to the previous stage of the current operation.
  ///
  /// Intended for stage navigation controls. It resets question/counter state
  /// for a fresh attempt at the selected earlier stage.
  void previousStage() {
    if (state.status == GameStatus.playing) {
      return;
    }
    int actualStageAddition = state.actualStageAddition;
    int actualStageSubtraction = state.actualStageSubtraction;
    int actualStageMultiplication = state.actualStageMultiplication;
    int actualStageDivision = state.actualStageDivision;
    int actualStageRandom = state.actualStageRandom;
    if (state.calcOperation!.operation == '+') {
      actualStageAddition--;
    } else if (state.calcOperation!.operation == '-') {
      actualStageSubtraction--;
    } else if (state.calcOperation!.operation == '*') {
      actualStageMultiplication--;
    } else if (state.calcOperation!.operation == '/') {
      actualStageDivision--;
    } else if (state.calcOperation!.operation == 'R') {
      actualStageRandom--;
    }
    state = state.copyWith(
      actualStageAddition: () => actualStageAddition,
      actualStageSubtraction: () => actualStageSubtraction,
      actualStageMultiplication: () => actualStageMultiplication,
      actualStageDivision: () => actualStageDivision,
      actualStageRandom: () => actualStageRandom,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      period: () => 0.0,
      isQuestionGiven: () => false,
      startTime: () => null,
      evaluationMessage: () => '',
      status: () => GameStatus.idle,
    );
  }

  void repeatStage() {
    final stageIndex = _activeStageIndex();
    _debugGenerationLog('repeatStage', stageIndex);
    final generatedQuestion = gameEngine.generateQuestion(
      operation: state.calcOperation!.operation,
      stageIndex: stageIndex,
      calcOperation: state.calcOperation!,
    );
    state = state.copyWith(
      allAnswers: () => 0,
      trueAnswers: () => 0,
      evaluationMessage: () => '',
      period: () => 0.0,
      isQuestionGiven: () => true,
      firstNumber: () => generatedQuestion.firstNumber,
      secondNumber: () => generatedQuestion.secondNumber,
      actualOperation: () => generatedQuestion.actualOperation,
      correctAnswer: () => generatedQuestion.correctAnswer,
      answerOptions: () => generatedQuestion.answerOptions,
      answer: () => null,
      isAnswerGiven: () => false,
      startTime: () => DateTime.now(),
      status: () => GameStatus.playing,
    );
  }

  /// Stops the current stage attempt without counting as win or fail.
  ///
  /// Clears active question/answers and returns the UI to idle so the player
  /// can start again manually.
  void stopGame() {
    state = state.copyWith(
      isQuestionGiven: () => false,
      isAnswerGiven: () => false,
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      answer: () => null,
      evaluationMessage: () => '',
      startTime: () => null,
      period: () => 0.0,
      status: () => GameStatus.idle,
    );
  }

  /// Starts gameplay for the current stage by generating a question.
  ///
  /// Call this when entering a stage or after [nextQuestion]. The method keeps
  /// the same [startTime] during an ongoing stage attempt and sets status to
  /// [GameStatus.playing].
  void startGame() {
    if (state.status == GameStatus.won || state.status == GameStatus.failed) {
      return;
    }
    if (!state.isQuestionGiven) {
      final startTime = DateTime.now();
      final stageIndex = _activeStageIndex();

      _debugGenerationLog('startGame', stageIndex);
      final generatedQuestion = gameEngine.generateQuestion(
        operation: state.calcOperation!.operation,
        stageIndex: stageIndex,
        calcOperation: state.calcOperation!,
      );
      state = state.copyWith(
        firstNumber: () => generatedQuestion.firstNumber,
        secondNumber: () => generatedQuestion.secondNumber,
        actualOperation: () => generatedQuestion.actualOperation,
        correctAnswer: () => generatedQuestion.correctAnswer,
        answerOptions: () => generatedQuestion.answerOptions,
        isQuestionGiven: () => true,
        startTime: () => startTime,
        period: () => 0.0,
        isAnswerGiven: () => false,
        answer: () => null,
        evaluationMessage: () => '',
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
    GameFeedbackType feedbackType = GameFeedbackType.none;
    if (answer == state.correctAnswer) {
      trueAnswers++;
      allAnswers++;
      evaluationMessage = 'Correct: $trueAnswers of $allAnswers';
      if (trueAnswers <= 7) {
        feedbackType = GameFeedbackType.correct;
      }
    } else {
      allAnswers++;
      evaluationMessage = 'Wrong: $trueAnswers of $allAnswers';
      feedbackType = GameFeedbackType.wrong;
    }
    if (trueAnswers > 7) {
      final completedStageNumber = _activeStageIndex() + 1;
      final selectedOperation = state.calcOperation!.operation;
      final operationName = _operationName(selectedOperation);
      final player = Player(name: state.player?.name)
        ..id = state.player?.id
        ..createdAt = state.player?.createdAt
        ..gameRecords = List<GameRecord>.from(state.player?.gameRecords ?? [])
        ..maxStageAdition = state.player?.maxStageAdition ?? 0
        ..maxStageSubtruction = state.player?.maxStageSubtruction ?? 0
        ..maxStageMultiplication = state.player?.maxStageMultiplication ?? 0
        ..maxStageSection = state.player?.maxStageSection ?? 0
        ..maxStageRandom = state.player?.maxStageRandom ?? 0;
      if (selectedOperation == '+') {
        player.maxStageAdition++;
      } else if (selectedOperation == '-') {
        player.maxStageSubtruction++;
      } else if (selectedOperation == '*') {
        player.maxStageMultiplication++;
      } else if (selectedOperation == '/') {
        player.maxStageSection++;
      } else if (selectedOperation == 'R') {
        player.maxStageRandom++;
      }
      final period =
          DateTime.now().difference(state.startTime!).inMilliseconds / 1000.0;
      final existingStageRecords = player.gameRecords
          .where(
            (record) =>
                record.operation == selectedOperation &&
                record.stageNumber == completedStageNumber,
          )
          .toList();
      final bestPreviousDuration = existingStageRecords.isEmpty
          ? null
          : existingStageRecords
              .map((record) => record.durationSeconds)
              .reduce((best, value) => value < best ? value : best);
      final isNewRecord =
          bestPreviousDuration == null || period < bestPreviousDuration;
      final gameRecord = GameRecord.create(
        stageNumber: completedStageNumber,
        operation: selectedOperation,
        durationSeconds: period,
        gameMode: 'normal',
      );
      player.gameRecords = [...player.gameRecords, gameRecord];
      _applyUnlockedStagesToPlayer(player);
      feedbackType = isNewRecord
          ? GameFeedbackType.newRecord
          : GameFeedbackType.stageSuccess;
      evaluationMessage =
          '${state.player!.name} completed Stage $completedStageNumber in $operationName in ${period.toStringAsFixed(1)} Sec';
      state = state.copyWith(
        isQuestionGiven: () => false,
        isAnswerGiven: () => true,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        evaluationMessage: () => evaluationMessage,
        status: () => GameStatus.won,
        stage: () => state.stage + 1,
        period: () => period,
        startTime: () => null,
        lastFeedbackType: () => feedbackType,
        feedbackVersion: () => state.feedbackVersion + 1,
        player: () => player,
      );
      _persistPlayer(player);
    } else if (allAnswers - trueAnswers > 2) {
      feedbackType = GameFeedbackType.loss;
      evaluationMessage = '${state.player!.name} failed';
      state = state.copyWith(
        isQuestionGiven: () => false,
        isAnswerGiven: () => true,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        evaluationMessage: () => evaluationMessage,
        period: () => 0.0,
        startTime: () => null,
        status: () => GameStatus.failed,
        lastFeedbackType: () => feedbackType,
        feedbackVersion: () => state.feedbackVersion + 1,
      );
    } else {
      state = state.copyWith(
        isQuestionGiven: () => false,
        isAnswerGiven: () => true,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        evaluationMessage: () => evaluationMessage,
        status: () => GameStatus.playing,
        lastFeedbackType: () => feedbackType,
        feedbackVersion: () => state.feedbackVersion + 1,
      );
    }
  }

  /// Handles answer submission and advances to next question when still playing.
  void submitAnswerAndContinue(int answer) {
    submitAnswer(answer);
    if (state.status == GameStatus.playing) {
      nextQuestion();
      _generateNextQuestionInRun();
    }
  }

  void _generateNextQuestionInRun() {
    if (state.status != GameStatus.playing || state.isQuestionGiven) {
      return;
    }
    final stageIndex = _activeStageIndex();
    _debugGenerationLog('nextQuestion', stageIndex);
    final generatedQuestion = gameEngine.generateQuestion(
      operation: state.calcOperation!.operation,
      stageIndex: stageIndex,
      calcOperation: state.calcOperation!,
    );
    state = state.copyWith(
      firstNumber: () => generatedQuestion.firstNumber,
      secondNumber: () => generatedQuestion.secondNumber,
      actualOperation: () => generatedQuestion.actualOperation,
      correctAnswer: () => generatedQuestion.correctAnswer,
      answerOptions: () => generatedQuestion.answerOptions,
      isQuestionGiven: () => true,
      isAnswerGiven: () => false,
      answer: () => null,
      status: () => GameStatus.playing,
    );
  }

  void winToNextStage() {
    if (state.trueAnswers > 7) {
      state = state.copyWith(
        startTime: () => null,
        period: () => 0.0,
      );
      final player = Player()
        ..id = state.player!.id
        ..name = state.player!.name
        ..createdAt = state.player!.createdAt
        ..gameRecords = List<GameRecord>.from(state.player!.gameRecords)
        ..maxStageAdition = state.player!.maxStageAdition
        ..maxStageSubtruction = state.player!.maxStageSubtruction
        ..maxStageMultiplication = state.player!.maxStageMultiplication
        ..maxStageSection = state.player!.maxStageSection
        ..maxStageRandom = state.player!.maxStageRandom;
      int stageAdition = state.actualStageAddition;
      int stageSubtruction = state.actualStageSubtraction;
      int stageMultiplication = state.actualStageMultiplication;
      int stageSectioning = state.actualStageDivision;
      int stageRandom = state.actualStageRandom;
      if (state.calcOperation!.operation == '+' &&
          state.actualStageAddition + 1 < stages.length) {
        stageAdition++;
      } else if (state.calcOperation!.operation == '-' &&
          state.actualStageSubtraction + 1 < stages.length) {
        stageSubtruction++;
      } else if (state.calcOperation!.operation == '*' &&
          state.actualStageMultiplication + 1 < stages.length) {
        stageMultiplication++;
      } else if (state.calcOperation!.operation == '/' &&
          state.actualStageDivision + 1 < stages.length) {
        stageSectioning++;
      } else if (state.calcOperation!.operation == 'R' &&
          state.actualStageRandom + 1 < stages.length) {
        stageRandom++;
      }

      final nextStageIndex = state.calcOperation!.operation == '+'
          ? stageAdition
          : state.calcOperation!.operation == '-'
              ? stageSubtruction
              : state.calcOperation!.operation == '*'
                  ? stageMultiplication
                  : state.calcOperation!.operation == '/'
                      ? stageSectioning
                      : stageRandom;

      final generatedQuestion = gameEngine.generateQuestion(
        operation: state.calcOperation!.operation,
        stageIndex: nextStageIndex,
        calcOperation: state.calcOperation!,
      );
      _debugGenerationLog('winToNextStage', nextStageIndex);
      final nextRunStart = DateTime.now();

      state = state.copyWith(
        player: () => player,
        actualStageAddition: () => stageAdition,
        actualStageSubtraction: () => stageSubtruction,
        actualStageMultiplication: () => stageMultiplication,
        actualStageDivision: () => stageSectioning,
        actualStageRandom: () => stageRandom,
        allAnswers: () => 0,
        startTime: () => nextRunStart,
        trueAnswers: () => 0,
        period: () => 0.0,
        isAnswerGiven: () => false,
        isQuestionGiven: () => true,
        evaluationMessage: () => '',
        firstNumber: () => generatedQuestion.firstNumber,
        secondNumber: () => generatedQuestion.secondNumber,
        actualOperation: () => generatedQuestion.actualOperation,
        correctAnswer: () => generatedQuestion.correctAnswer,
        answerOptions: () => generatedQuestion.answerOptions,
        status: () => GameStatus.playing,
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
    if (state.calcOperation!.operation == '/') {
      return state.actualStageDivision.clamp(0, lastIndex);
    }
    if (state.calcOperation!.operation == 'R') {
      return state.actualStageRandom.clamp(0, lastIndex);
    }
    return 0;
  }

  List<GameRecord> getBestRecords(String operation, int stageNumber) {
    final records = List<GameRecord>.from(state.player?.gameRecords ?? [])
        .where(
          (record) =>
              record.operation == operation &&
              record.stageNumber == stageNumber,
        )
        .toList()
      ..sort((a, b) => a.durationSeconds.compareTo(b.durationSeconds));

    if (records.length <= 3) return records;
    return records.take(3).toList();
  }

  int getMaxUnlockedStage(String operation) {
    final records = (state.player?.gameRecords ?? <GameRecord>[])
        .where((record) => record.operation == operation)
        .toList();
    if (records.isEmpty) {
      return 0;
    }
    return records
        .map((record) => record.stageNumber)
        .reduce((max, value) => value > max ? value : max);
  }

  int getHighestCompletedStage(String operation) {
    final records = (state.player?.gameRecords ?? <GameRecord>[])
        .where((record) => record.operation == operation)
        .toList();
    if (records.isEmpty) {
      return 0;
    }
    return records
        .map((record) => record.stageNumber)
        .reduce((max, value) => value > max ? value : max);
  }

  int getNextPlayableStageIndex(String operation) {
    final highestCompletedStage = getHighestCompletedStage(operation);
    final nextPlayableIndex = highestCompletedStage;
    return nextPlayableIndex.clamp(0, stages.length - 1);
  }

  int getCurrentStageForOperation(String operation) {
    if (operation == '+') return state.actualStageAddition;
    if (operation == '-') return state.actualStageSubtraction;
    if (operation == '*') return state.actualStageMultiplication;
    if (operation == '/') return state.actualStageDivision;
    if (operation == 'R') return state.actualStageRandom;
    return state.actualStageDivision;
  }

  int _nextPlayableStageIndexFromRecords(
    List<GameRecord> records,
    String operation,
  ) {
    final operationRecords =
        records.where((record) => record.operation == operation).toList();
    if (operationRecords.isEmpty) {
      return 0;
    }
    final highestCompletedStage = operationRecords
        .map((record) => record.stageNumber)
        .reduce((max, value) => value > max ? value : max);
    final nextPlayableIndex = highestCompletedStage;
    return nextPlayableIndex.clamp(0, stages.length - 1);
  }

  void _applyUnlockedStagesToPlayer(Player player) {
    player.maxStageAdition =
        _nextPlayableStageIndexFromRecords(player.gameRecords, '+');
    player.maxStageSubtruction =
        _nextPlayableStageIndexFromRecords(player.gameRecords, '-');
    player.maxStageMultiplication =
        _nextPlayableStageIndexFromRecords(player.gameRecords, '*');
    player.maxStageSection =
        _nextPlayableStageIndexFromRecords(player.gameRecords, '/');
    player.maxStageRandom =
        _nextPlayableStageIndexFromRecords(player.gameRecords, 'R');
  }

  Future<void> _persistPlayer(Player player) async {
    if (player.id == null || player.name == null || player.createdAt == null) {
      return;
    }
    final profile = player.toUserProfile();
    await userStorageService.upsert(profile, validateDuplicateName: false);
  }

  String _operationName(String operation) {
    if (operation == '+') return 'Addition';
    if (operation == '-') return 'Subtraction';
    if (operation == '*') return 'Multiplication';
    if (operation == '/') return 'Division';
    if (operation == 'R') return 'Random';
    return 'Unknown';
  }
}

/// Global Riverpod provider exposing [GameNotifier] and [GameState].
final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  final engine = ref.read(gameEngineProvider);
  final userStorage = ref.read(userStorageServiceProvider);
  return GameNotifier(engine, userStorage);
});
