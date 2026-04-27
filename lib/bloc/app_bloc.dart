import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/game_engine.dart';

import 'bloc_classes.dart';
import 'global_variablen.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final GameEngine _gameEngine = GameEngine();

  AppBloc() : super(const AppState()) {
    on<ChooseOperationEvent>(chooseOperation);
    on<GiveNameEvent>(giveName);
    on<StartGameEvent>(startGameEvent);
    on<NextStageEvent>(nextStage);
    on<NextTaskEvent>(nextTask);
    on<PreviosStageEvent>(previosStage);
    on<RepeatStageEvent>(repeatStage);
    on<TestingEvent>(testing);
    // on<WinNewStageEvent>(winNewStage);
    on<WinToNextStageEvent>(winToNextStage);
    //###############################################################################
  }
  chooseOperation(ChooseOperationEvent event, emit) {
    int operationsIndex = state.operationenIndex;
    if (operationsIndex == 3) {
      operationsIndex = 0;
    } else {
      operationsIndex++;
    }
    CalcOperation calcOperation =
        CalcOperation(calcOperationsList[operationsIndex]);
    final newState = state.copyWith(
      operationsIndex: () => operationsIndex,
      calcOperation: () => calcOperation,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      answer: () => null,
      isAskGived: () => false,
      isAnswerGived: () => true,
      valuation: () => '',
      status: () => GameStatus.idle,
      firstNumber: () => null,
      secondNumber: () => null,
      correctAnswer: () => 0,
      answerOptions: () => const [],
      period: () => 0,
    );

    emit(newState);
  }

  giveName(GiveNameEvent event, emit) {
    final player = Player(name: event.name);
    final calcOperation = CalcOperation('+');
    final newState = state.copyWith(
      player: () => player,
      calcOperation: () => calcOperation,
      status: () => GameStatus.idle,
    );
    emit(newState);
  }

  nextStage(NextStageEvent event, emit) {
    int actualStageAdition = state._actualStageAdition;
    int actualStageSubtraction = state._actualStageSubtruction;
    int actualStageMultiblication = state._actualStageMultiplication;
    int actualStageSectioning = state._actualStageSectioning;
    if (state.calcOperation!.operation == '+') {
      actualStageAdition++;
    } else if (state.calcOperation!.operation == '-') {
      actualStageSubtraction++;
    } else if (state.calcOperation!.operation == '*') {
      actualStageMultiblication++;
    } else if (state.calcOperation!.operation == '/') {
      actualStageSectioning++;
    }
    final newState = state.copyWith(
      actualStageAdition: () => actualStageAdition,
      actualStageSubtruction: () => actualStageSubtraction,
      actualStageMultiplication: () => actualStageMultiblication,
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
    emit(newState);
  }

  nextTask(NextTaskEvent event, emit) {
    if (!state.isAnswerGived) {
    } else {
      final newState = state.copyWith(
        isAskGived: () => true,
        valuation: () => '${state.trueAnswers} / ${state.allAnswers}',
        firstNumber: () => null,
        secondNumber: () => null,
        correctAnswer: () => 0,
        answerOptions: () => const [],
        answer: () => null,
        isAnswerGived: () => false,
        status: () => GameStatus.playing,
      );
      emit(newState);
    }
  }

  previosStage(PreviosStageEvent event, emit) {
    int actualStageAdition = state._actualStageAdition;
    int actualStageSubtraction = state._actualStageSubtruction;
    int actualStageMultiblication = state._actualStageMultiplication;
    int actualStageSectioning = state._actualStageSectioning;
    if (state.calcOperation!.operation == '+') {
      actualStageAdition--;
    } else if (state.calcOperation!.operation == '-') {
      actualStageSubtraction--;
    } else if (state.calcOperation!.operation == '*') {
      actualStageMultiblication--;
    } else if (state.calcOperation!.operation == '/') {
      actualStageSectioning--;
    }
    final newState = state.copyWith(
      actualStageAdition: () => actualStageAdition,
      actualStageSubtruction: () => actualStageSubtraction,
      actualStageMultiplication: () => actualStageMultiblication,
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
    emit(newState);
  }

  repeatStage(RepeatStageEvent event, emit) {
    final generatedQuestion = _gameEngine.generateQuestion(
      operation: state.calcOperation!.operation,
      stageIndex: _activeStageIndex(),
      calcOperation: state.calcOperation!,
    );
    final newState = state.copyWith(
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
    emit(newState);
  }

  startGameEvent(StartGameEvent event, emit) {
    DateTime startTime;
    if (state.startTime == null) {
      startTime = DateTime.now();
    } else {
      startTime = state.startTime!;
    }
    if (!state.isAskGived) {
      final generatedQuestion = _gameEngine.generateQuestion(
        operation: state.calcOperation!.operation,
        stageIndex: _activeStageIndex(),
        calcOperation: state.calcOperation!,
      );
      final newState = state.copyWith(
        firstNumber: () => generatedQuestion.firstNumber,
        secondNumber: () => generatedQuestion.secondNumber,
        correctAnswer: () => generatedQuestion.correctAnswer,
        answerOptions: () => generatedQuestion.answerOptions,
        isAskGived: () => true,
        startTime: () => startTime,
        status: () => GameStatus.playing,
      );

      emit(newState);
    }
  }

  testing(TestingEvent event, emit) {
    int trueAnswers = state.trueAnswers;
    int allAnswers = state.allAnswers;
    String valuation = '';
    if (event.answer == null) {
    } else if (event.answer == state.correctAnswer) {
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
      final newState = state.copyWith(
        isAskGived: () => false,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        valuation: () => valuation,
        status: () => GameStatus.won,
        stage: () => state.stage + 1,
        period: () => period,
        player: () => player,
      );
      emit(newState);
    } else if (allAnswers - trueAnswers > 2) {
      valuation = '${state.player!.name} failed';
      final newState = state.copyWith(
        isAskGived: () => false,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        valuation: () => valuation,
        status: () => GameStatus.failed,
      );
      emit(newState);
    } else {
      final newState = state.copyWith(
        isAskGived: () => false,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        valuation: () => valuation,
        status: () => GameStatus.playing,
      );
      emit(newState);
    }
  }

  // winNewStage(WinNewStageEvent event, emit) {
  //   if (state.richtigeAntworten > 7) {
  //     if (state.stageAddieren + 1 < state.stages.length) {
  //       if (state.rechengang == '+') {
  //         // addiernStufen[stageAddieren].add(dauer);
  //         state.stageAddieren++;
  //         state.player.maxStageAddieren++;
  //       } else if (state.rechengang == '-') {
  //         // subtrahiernStufen[stageSubtrahieren].add(dauer);

  //         state.stageSubtrahieren++;
  //         state.player.maxStageSubtrahieren++;
  //       } else if (state.rechengang == '*') {
  //         // malenStufen[stageMalen].add(dauer);
  //         state.stageMalen++;
  //         state.player.maxStageMalen++;
  //       } else if (state.rechengang == '/') {
  //         // teilenStufen[stageTeilen].add(dauer);

  //         state.stageTeilen++;
  //         state.player.maxStageTeilen++;
  //       }
  //     }
  //     state.alleAntworten = 0;
  //     state.richtigeAntworten = 0;

  //     state.dauer = 0;
  //   }
  //   emit(state);
  // }

  winToNextStage(WinToNextStageEvent event, emit) {
    if (state.trueAnswers > 7) {
      Player? player = Player();
      player.name = state.player!.name;
      player.maxStageAdition = state.player!.maxStageAdition;
      player.maxStageSubtruction = state.player!.maxStageSubtruction;
      player.maxStageMultiplication = state.player!.maxStageMultiplication;
      player.maxStageSection = state.player!.maxStageSection;
      int stageAdition = state.actualStageAdition;
      int stageSubtruction = state.actualStageSubtruction;
      int stageMultiplication = state._actualStageMultiplication;
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
      final newState = state.copyWith(
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
      emit(newState);
    }
  }

  int _activeStageIndex() {
    if (state.calcOperation!.operation == '+') {
      return state.actualStageAdition;
    }
    if (state.calcOperation!.operation == '-') {
      return state.actualStageSubtruction;
    }
    if (state.calcOperation!.operation == '*') {
      return state.actualStageMultiplication;
    }
    return state.actualStageSectioning;
  }
}
