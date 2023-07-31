import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rechnen_spiel/bloc/bloc_classes.dart';
import 'package:rechnen_spiel/bloc/global_variablen.dart';
import 'package:rechnen_spiel/bloc/help_functions.dart';
part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
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
    String calcOperation = calcOperationsList[operationsIndex];
    print(calcOperation);
    final newState = state.copyWith(
      operationsIndex: () => operationsIndex,
      calcOperation: () => calcOperation,
      allAnswers: () => 0,
      trueAnswers: () => 0,
      answer: () => null,
      isAskGived: () => false,
      isAnswerGived: () => true,
      valuation: () => '',
      firstNumber: () => null,
      secondNumber: () => null,
      period: () => 0,
    );

    emit(newState);
  }

  giveName(GiveNameEvent event, emit) {
    final player = Player(name: event.name);
    final newState = state.copyWith(
      player: () => player,
    );
    print(newState.player!.name);
    emit(newState);
  }

  nextStage(NextStageEvent event, emit) {
    int actualStageAdition = state._actualStageAdition;
    int actualStageSubtraction = state._actualStageSubtruction;
    int actualStageMultiblication = state._actualStageMultiplication;
    int actualStageSectioning = state._actualStageSectioning;
    if (state.calcOperation == '+') {
      actualStageAdition++;
    } else if (state.calcOperation == '-') {
      actualStageSubtraction++;
    } else if (state.calcOperation == '*') {
      actualStageMultiblication++;
    } else if (state.calcOperation == '/') {
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
      period: () => 0,
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
        answer: () => null,
        startTime: () => null,
        isAnswerGived: () => false,
      );
      emit(newState);
    }
  }

  previosStage(PreviosStageEvent event, emit) {
    int actualStageAdition = state._actualStageAdition;
    int actualStageSubtraction = state._actualStageSubtruction;
    int actualStageMultiblication = state._actualStageMultiplication;
    int actualStageSectioning = state._actualStageSectioning;
    if (state.calcOperation == '+') {
      actualStageAdition--;
    } else if (state.calcOperation == '-') {
      actualStageSubtraction--;
    } else if (state.calcOperation == '*') {
      actualStageMultiblication--;
    } else if (state.calcOperation == '/') {
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
      period: () => 0,
      isAskGived: () => false,
    );
    emit(newState);
  }

  repeatStage(RepeatStageEvent event, emit) {
    int firstNumber = 0;
    int secondNumber = 0;

    if (state.calcOperation == '/') {
      firstNumber = gibUnBrimeNummer(state);
      secondNumber = gibPassendeTeilNummer(firstNumber, state.actualStageSectioning);
    } else if (state.calcOperation == '-') {
      firstNumber = Random().nextInt(stages[state.actualStageSubtruction]);
      secondNumber = Random().nextInt(stages[state.actualStageSubtruction]);
    } else if (state.calcOperation == '*') {
      firstNumber = Random().nextInt(stages[state.actualStageMultiplication]);
      secondNumber = Random().nextInt(stages[state.actualStageMultiplication]);
    } else {
      firstNumber = Random().nextInt(stages[state.actualStageAdition]);
      secondNumber = Random().nextInt(stages[state.actualStageAdition]);
    }
    final newState = state.copyWith(
      allAnswers: () => 0,
      trueAnswers: () => 0,
      valuation: () => '',
      period: () => 0,
      isAskGived: () => true,
      firstNumber: () => firstNumber,
      secondNumber: () => secondNumber,
      answer: () => null,
      isAnswerGived: () => false,
    );
    emit(newState);
  }

  startGameEvent(StartGameEvent event, emit) {
    int? firstNumber;
    int? secondNumber;
    if (!state.isAskGived) {
      if (state.calcOperation == '/') {
        firstNumber = gibUnBrimeNummer(state);
        secondNumber = gibPassendeTeilNummer(firstNumber, state.actualStageSectioning);
      } else if (state.calcOperation == '-') {
        firstNumber = Random().nextInt(stages[state.actualStageSubtruction]);
        secondNumber = Random().nextInt(stages[state.actualStageSubtruction]);
      } else if (state.calcOperation == '*') {
        firstNumber = Random().nextInt(stages[state.actualStageMultiplication]);
        secondNumber = Random().nextInt(stages[state.actualStageMultiplication]);
      } else {
        firstNumber = Random().nextInt(stages[state.actualStageAdition]);
        secondNumber = Random().nextInt(stages[state.actualStageAdition]);
      }
      final newState = state.copyWith(
        firstNumber: () => firstNumber,
        secondNumber: () => secondNumber,
        isAskGived: () => true,
      );

      emit(newState);
    }
  }

  testing(TestingEvent event, emit) {
    int trueAnswers = state.trueAnswers;
    int allAnswers = state.allAnswers;
    String valuation = '';

    if (event.answer == null) {
    } else if (answerValuation(state, event)) {
      trueAnswers++;
      allAnswers++;
      valuation = 'True Answer $trueAnswers / $allAnswers';
    } else {
      allAnswers++;
      valuation = 'false Answer $trueAnswers / $allAnswers';
    }
    if (trueAnswers > 7) {
      int stage = state.stage;
      valuation = '${state.player!.name} wins';
      final newState = state.copyWith(
        isAskGived: () => false,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        valuation: () => valuation,
        stage: () => stage++,
      );
      emit(newState);
    }
    if (allAnswers - trueAnswers < 3) {
      final newState = state.copyWith(
        isAskGived: () => false,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        valuation: () => valuation,
      );
      emit(newState);
    }
    if (allAnswers - trueAnswers > 2) {
      valuation = '${state.player!.name} failed';
      final newState = state.copyWith(
        isAskGived: () => false,
        allAnswers: () => allAnswers,
        trueAnswers: () => trueAnswers,
        valuation: () => valuation,
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
      if (state.actualStageAdition + 1 < stages.length) {
        if (state._calcOperation == '+') {
          // addiernStufen[stageAddieren].add(dauer);
          stageAdition++;
          player.maxStageAdition++;
        } else if (state.calcOperation == '-') {
          // subtrahiernStufen[stageSubtrahieren].add(dauer);

          stageSubtruction++;
          player.maxStageSubtruction++;
        } else if (state.calcOperation == '*') {
          // malenStufen[stageMalen].add(dauer);
          stageMultiplication++;
          player.maxStageMultiplication++;
        } else if (state.calcOperation == '/') {
          // teilenStufen[stageTeilen].add(dauer);

          stageSectioning++;
          player.maxStageSection++;
        }
      }
      final newState = state.copyWith(
        player: () => player,
        actualStageAdition: () => stageAdition,
        actualStageSubtruction: () => stageSubtruction,
        actualStageMultiplication: () => stageMultiplication,
        actualStageSectioning: () => stageSectioning,
        allAnswers: () => 0,
        trueAnswers: () => 0,
        period: () => 0,
        isAnswerGived: () => false,
        valuation: () => '',
      );
      emit(newState);
    }
  }
}
