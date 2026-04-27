import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/game_constants.dart';
import '../domain/game_engine.dart';
import '../domain/game_models.dart';

enum GameStatus { idle, playing, won, failed }

class GameState {
  final int stage;
  final String title;
  final DateTime? startTime;
  final String? answer;
  final bool isAskGived;
  final bool isAnswerGived;
  final CalcOperation? calcOperation;
  final int operationenIndex;
  final int actualStageAdition;
  final int actualStageSubtruction;
  final int actualStageMultiplication;
  final int actualStageSectioning;
  final int? firstNumber;
  final int? secondNumber;
  final int correctAnswer;
  final List<int> answerOptions;
  final String valuation;
  final int trueAnswers;
  final int allAnswers;
  final int period;
  final GameStatus status;
  final Player? player;

  const GameState({
    this.stage = 0,
    this.title = '',
    this.startTime,
    this.answer,
    this.isAskGived = false,
    this.isAnswerGived = false,
    this.calcOperation,
    this.operationenIndex = 0,
    this.actualStageAdition = 0,
    this.actualStageSubtruction = 0,
    this.actualStageMultiplication = 0,
    this.actualStageSectioning = 0,
    this.firstNumber,
    this.secondNumber,
    this.correctAnswer = 0,
    this.answerOptions = const [],
    this.valuation = '',
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
    bool Function()? isAskGived,
    bool Function()? isAnswerGived,
    CalcOperation? Function()? calcOperation,
    int Function()? operationsIndex,
    int Function()? actualStageAdition,
    int Function()? actualStageSubtruction,
    int Function()? actualStageMultiplication,
    int Function()? actualStageSectioning,
    int? Function()? firstNumber,
    int? Function()? secondNumber,
    int Function()? correctAnswer,
    List<int> Function()? answerOptions,
    String Function()? valuation,
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
      isAskGived: isAskGived == null ? this.isAskGived : isAskGived(),
      isAnswerGived:
          isAnswerGived == null ? this.isAnswerGived : isAnswerGived(),
      calcOperation:
          calcOperation == null ? this.calcOperation : calcOperation(),
      operationenIndex:
          operationsIndex == null ? operationenIndex : operationsIndex(),
      actualStageAdition: actualStageAdition == null
          ? this.actualStageAdition
          : actualStageAdition(),
      actualStageSubtruction: actualStageSubtruction == null
          ? this.actualStageSubtruction
          : actualStageSubtruction(),
      actualStageMultiplication: actualStageMultiplication == null
          ? this.actualStageMultiplication
          : actualStageMultiplication(),
      actualStageSectioning: actualStageSectioning == null
          ? this.actualStageSectioning
          : actualStageSectioning(),
      firstNumber: firstNumber == null ? this.firstNumber : firstNumber(),
      secondNumber: secondNumber == null ? this.secondNumber : secondNumber(),
      correctAnswer:
          correctAnswer == null ? this.correctAnswer : correctAnswer(),
      answerOptions:
          answerOptions == null ? this.answerOptions : answerOptions(),
      valuation: valuation == null ? this.valuation : valuation(),
      trueAnswers: trueAnswers == null ? this.trueAnswers : trueAnswers(),
      allAnswers: allAnswers == null ? this.allAnswers : allAnswers(),
      period: period == null ? this.period : period(),
      status: status == null ? this.status : status(),
      player: player == null ? this.player : player(),
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final GameEngine gameEngine;

  GameNotifier(this.gameEngine) : super(const GameState());

  void chooseOperation() {
    int operationsIndex = state.operationenIndex;
    if (operationsIndex == 3) {
      operationsIndex = 0;
    } else {
      operationsIndex++;
    }
    final calcOperation = CalcOperation(calcOperationsList[operationsIndex]);
    state = state.copyWith(
      operationsIndex: () => operationsIndex,
      calcOperation: () => calcOperation,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      answer: () => null,
      isAskGived: () => false,
      isAnswerGived: () => false,
      valuation: () => '',
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

  void nextStage() {
    int actualStageAdition = state.actualStageAdition;
    int actualStageSubtraction = state.actualStageSubtruction;
    int actualStageMultiplication = state.actualStageMultiplication;
    int actualStageSectioning = state.actualStageSectioning;
    if (state.calcOperation!.operation == '+') {
      actualStageAdition++;
    } else if (state.calcOperation!.operation == '-') {
      actualStageSubtraction++;
    } else if (state.calcOperation!.operation == '*') {
      actualStageMultiplication++;
    } else if (state.calcOperation!.operation == '/') {
      actualStageSectioning++;
    }
    state = state.copyWith(
      actualStageAdition: () => actualStageAdition,
      actualStageSubtruction: () => actualStageSubtraction,
      actualStageMultiplication: () => actualStageMultiplication,
      actualStageSectioning: () => actualStageSectioning,
      isAskGived: () => false,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      period: () => 0,
      startTime: () => DateTime.now(),
      valuation: () => '',
      status: () => GameStatus.idle,
    );
  }

  void nextQuestion() {
    if (!state.isAnswerGived) {
      return;
    }
    state = state.copyWith(
      isAskGived: () => false,
      valuation: () => '${state.trueAnswers} / ${state.allAnswers}',
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      answer: () => null,
      isAnswerGived: () => false,
      status: () => GameStatus.idle,
    );
  }

  void previosStage() {
    int actualStageAdition = state.actualStageAdition;
    int actualStageSubtraction = state.actualStageSubtruction;
    int actualStageMultiplication = state.actualStageMultiplication;
    int actualStageSectioning = state.actualStageSectioning;
    if (state.calcOperation!.operation == '+') {
      actualStageAdition--;
    } else if (state.calcOperation!.operation == '-') {
      actualStageSubtraction--;
    } else if (state.calcOperation!.operation == '*') {
      actualStageMultiplication--;
    } else if (state.calcOperation!.operation == '/') {
      actualStageSectioning--;
    }
    state = state.copyWith(
      actualStageAdition: () => actualStageAdition,
      actualStageSubtruction: () => actualStageSubtraction,
      actualStageMultiplication: () => actualStageMultiplication,
      actualStageSectioning: () => actualStageSectioning,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      period: () => 0,
      isAskGived: () => false,
      startTime: () => DateTime.now(),
      valuation: () => '',
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
      valuation: () => '',
      period: () => 0,
      isAskGived: () => true,
      firstNumber: () => generatedQuestion.firstNumber,
      secondNumber: () => generatedQuestion.secondNumber,
      correctAnswer: () => generatedQuestion.correctAnswer,
      answerOptions: () => generatedQuestion.answerOptions,
      answer: () => null,
      isAnswerGived: () => false,
      startTime: () => DateTime.now(),
      status: () => GameStatus.playing,
    );
  }

  void startGame() {
    DateTime startTime;
    if (state.startTime == null) {
      startTime = DateTime.now();
    } else {
      startTime = state.startTime!;
    }
    if (!state.isAskGived) {
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
        isAskGived: () => true,
        startTime: () => startTime,
        status: () => GameStatus.playing,
      );
    }
  }

  void submitAnswer(int answer) {
    if (state.firstNumber == null || state.secondNumber == null) {
      return;
    }

    int trueAnswers = state.trueAnswers;
    int allAnswers = state.allAnswers;
    String valuation = '';
    if (answer == state.correctAnswer) {
      trueAnswers++;
      allAnswers++;
      valuation = 'True Answer $trueAnswers / $allAnswers';
    } else {
      allAnswers++;
      valuation = 'false Answer $trueAnswers / $allAnswers';
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
      valuation = '${state.player!.name} wins';
      final period = DateTime.now().difference(state.startTime!).inSeconds;
      state = state.copyWith(
        isAskGived: () => false,
        isAnswerGived: () => true,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        valuation: () => valuation,
        status: () => GameStatus.won,
        stage: () => state.stage + 1,
        period: () => period,
        player: () => player,
      );
    } else if (allAnswers - trueAnswers > 2) {
      valuation = '${state.player!.name} failed';
      state = state.copyWith(
        isAskGived: () => false,
        isAnswerGived: () => true,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        valuation: () => valuation,
        status: () => GameStatus.failed,
      );
    } else {
      state = state.copyWith(
        isAskGived: () => false,
        isAnswerGived: () => true,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        valuation: () => valuation,
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
      int stageAdition = state.actualStageAdition;
      int stageSubtruction = state.actualStageSubtruction;
      int stageMultiplication = state.actualStageMultiplication;
      int stageSectioning = state.actualStageSectioning;
      if (state.calcOperation!.operation == '+' &&
          state.actualStageAdition + 1 < stages.length) {
        stageAdition++;
        player.maxStageAdition++;
      } else if (state.calcOperation!.operation == '-' &&
          state.actualStageSubtruction + 1 < stages.length) {
        stageSubtruction++;
        player.maxStageSubtruction++;
      } else if (state.calcOperation!.operation == '*' &&
          state.actualStageMultiplication + 1 < stages.length) {
        stageMultiplication++;
        player.maxStageMultiplication++;
      } else if (state.calcOperation!.operation == '/' &&
          state.actualStageSectioning + 1 < stages.length) {
        stageSectioning++;
        player.maxStageSection++;
      }
      state = state.copyWith(
        player: () => player,
        actualStageAdition: () => stageAdition,
        actualStageSubtruction: () => stageSubtruction,
        actualStageMultiplication: () => stageMultiplication,
        actualStageSectioning: () => stageSectioning,
        allAnswers: () => 0,
        startTime: () => DateTime.now(),
        trueAnswers: () => 0,
        period: () => 0,
        isAnswerGived: () => false,
        valuation: () => '',
        correctAnswer: () => 0,
        answerOptions: () => const [],
        status: () => GameStatus.idle,
      );
    }
  }

  int _activeStageIndex() {
    final lastIndex = stages.length - 1;
    if (state.calcOperation!.operation == '+') {
      return state.actualStageAdition.clamp(0, lastIndex);
    }
    if (state.calcOperation!.operation == '-') {
      return state.actualStageSubtruction.clamp(0, lastIndex);
    }
    if (state.calcOperation!.operation == '*') {
      return state.actualStageMultiplication.clamp(0, lastIndex);
    }
    return state.actualStageSectioning.clamp(0, lastIndex);
  }
}

final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) {
  final engine = ref.read(gameEngineProvider);
  return GameNotifier(engine);
});
