import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../../../features/game/domain/game_models.dart';
import '../../../features/user/domain/game_record.dart';
import '../../../features/user/state/user_providers.dart';
import '../domain/reverse_game_models.dart';
import '../domain/reverse_game_engine.dart';
import 'reverse_game_state.dart';

/// Helper class to hold stage initialization values computed from records
class _ReverseStageValues {
  final int stageAddition;
  final int stageSubtraction;
  final int stageMultiplication;
  final int stageDivision;
  final int stageRandom;
  final int maxAddition;
  final int maxSubtraction;
  final int maxMultiplication;
  final int maxDivision;
  final int maxRandom;

  _ReverseStageValues({
    required this.stageAddition,
    required this.stageSubtraction,
    required this.stageMultiplication,
    required this.stageDivision,
    required this.stageRandom,
    required this.maxAddition,
    required this.maxSubtraction,
    required this.maxMultiplication,
    required this.maxDivision,
    required this.maxRandom,
  });
}

/// Riverpod provider for [ReverseGameNotifier].
final reverseGameNotifierProvider =
    NotifierProvider<ReverseGameNotifier, ReverseGameState>(
  ReverseGameNotifier.new,
);

/// Manages the state lifecycle for Reverse Operation mode.
///
/// Full game logic is intentionally deferred; this notifier only provides
/// the structural foundation required for navigation and placeholder UI.
class ReverseGameNotifier extends Notifier<ReverseGameState> {
  final _engine = ReverseGameEngine();
  Timer? _ticker;

  @override
  ReverseGameState build() {
    // Seed from currentUserProvider once when this notifier is created.
    // Using read avoids reactive rebuilds that can reset in-session stage state.
    final currentUser = ref.read(currentUserProvider);
    final playerName = currentUser?.name;
    debugPrint(
        '[DEBUG] ReverseGameNotifier.build() called: userId=${currentUser?.id}, playerName=$playerName');

    ref.onDispose(() {
      _ticker?.cancel();
    });

    // Initialize progress from saved reverse mode records
    final stages =
        _computeUnlockedStagesFromRecords(currentUser?.gameRecords ?? []);

    return ReverseGameState(
      playerName: playerName,
      stageIndex: stages.stageAddition,
      maxUnlockedStageIndex: stages.maxAddition,
      stageAddition: stages.stageAddition,
      stageSubtraction: stages.stageSubtraction,
      stageMultiplication: stages.stageMultiplication,
      stageDivision: stages.stageDivision,
      stageRandom: stages.stageRandom,
      maxStageAddition: stages.maxAddition,
      maxStageSubtraction: stages.maxSubtraction,
      maxStageMultiplication: stages.maxMultiplication,
      maxStageDivision: stages.maxDivision,
      maxStageRandom: stages.maxRandom,
    );
  }

  /// Selects the arithmetic operation for question generation.
  void selectOperation(String operation) {
    if (state.status == ReverseGameStatus.playing) {
      return;
    }
    state = state.copyWith(
      selectedOperation: () => operation,
      stageIndex: () => currentStageForOperation(operation),
      maxUnlockedStageIndex: () => maxUnlockedStageForOperation(operation),
      status: () => ReverseGameStatus.idle,
      isAnswerGiven: () => false,
      isQuestionGiven: () => false,
      startTime: () => null,
      elapsed: () => Duration.zero,
      period: () => 0.0,
      correctAnswers: () => 0,
      totalAnswers: () => 0,
      evaluationMessage: () => '',
      currentRound: () => null,
    );
  }

  /// Move to the next stage when not actively playing.
  void nextStage() {
    if (state.status == ReverseGameStatus.playing) {
      return;
    }
    final currentOperation = state.selectedOperation;
    final currentStage = currentStageForOperation(currentOperation);
    final maxUnlocked = maxUnlockedStageForOperation(currentOperation);
    final nextStage =
        currentStage >= maxUnlocked ? maxUnlocked : currentStage + 1;
    _setIdleState(stageIndex: nextStage);
  }

  /// Move to the previous stage when not actively playing.
  void previousStage() {
    if (state.status == ReverseGameStatus.playing) {
      return;
    }
    final currentOperation = state.selectedOperation;
    final currentStage = currentStageForOperation(currentOperation);
    final nextStage = currentStage <= 0 ? 0 : currentStage - 1;
    _setIdleState(stageIndex: nextStage);
  }

  /// Starts a new stage session.
  void startGame() {
    final now = DateTime.now();
    final operation = state.selectedOperation;
    final selectedStageIndex = currentStageForOperation(operation);
    final selectedMaxUnlocked = maxUnlockedStageForOperation(operation);
    final round = _engine.generateRound(
      operation: operation,
      stage: selectedStageIndex,
    );

    debugPrint(
        '[DEBUG] startGame: operation=$operation, selectedStageIndex=$selectedStageIndex, previousStageIndex=${state.stageIndex}');

    state = state.copyWith(
      status: () => ReverseGameStatus.playing,
      stageIndex: () => selectedStageIndex,
      maxUnlockedStageIndex: () => selectedMaxUnlocked,
      correctAnswers: () => 0,
      totalAnswers: () => 0,
      startTime: () => now,
      elapsed: () => Duration.zero,
      period: () => 0.0,
      currentRound: () => round,
      isQuestionGiven: () => true,
      isAnswerGiven: () => false,
      evaluationMessage: () => '',
    );
    _startTicker();
  }

  /// Repeats the current session from scratch.
  void repeatGame() {
    startGame();
  }

  /// Stops the current session and returns to idle state.
  void stopGame() {
    _ticker?.cancel();
    state = state.copyWith(
      status: () => ReverseGameStatus.idle,
      currentRound: () => null,
      isQuestionGiven: () => false,
      isAnswerGiven: () => false,
      startTime: () => null,
      elapsed: () => Duration.zero,
      period: () => 0.0,
      evaluationMessage: () => '',
      lastFeedbackType: () => ReverseFeedbackType.none,
      feedbackVersion: () => 0,
    );
  }

  /// Advances to the next question.
  void nextQuestion() {
    if (state.status != ReverseGameStatus.playing) {
      return;
    }

    final round = _nextRound();
    state = state.copyWith(
      currentRound: () => round,
      isQuestionGiven: () => true,
      isAnswerGiven: () => false,
    );
  }

  /// Starts the next stage session after a win.
  void startNextStage() {
    final currentOperation = state.selectedOperation;
    final currentStageBefore = currentStageForOperation(currentOperation);
    final maxUnlocked = maxUnlockedStageForOperation(currentOperation);

    debugPrint(
        '[DEBUG] startNextStage: operation=$currentOperation, currentStageBefore=$currentStageBefore, maxUnlocked=$maxUnlocked');

    if (state.status != ReverseGameStatus.won ||
        currentStageBefore >= maxUnlocked) {
      debugPrint(
          '[DEBUG] startNextStage: early return - status=${state.status}, canAdvance=${currentStageBefore < maxUnlocked}');
      return;
    }

    final nextStageIndex = currentStageBefore + 1;
    // Clamp to max unlocked stage
    final clampedStageIndex =
        nextStageIndex > maxUnlocked ? maxUnlocked : nextStageIndex;

    debugPrint(
        '[DEBUG] startNextStage: nextStageIndex=$nextStageIndex, clampedStageIndex=$clampedStageIndex');

    // Update operation-specific stage field
    updateCurrentStageForOperation(currentOperation, clampedStageIndex);

    // CRITICAL FIX: Update stageIndex in state, as _nextRound() reads state.stageIndex
    state = state.copyWith(stageIndex: () => clampedStageIndex);

    final currentStageAfter = currentStageForOperation(currentOperation);
    debugPrint(
        '[DEBUG] startNextStage: currentStageAfter=$currentStageAfter, about to call startGame()');

    startGame();
  }

  /// Submits the player's chosen answer option.
  Future<void> submitAnswer(ReverseAnswerOption option) async {
    if (state.status != ReverseGameStatus.playing || !state.isQuestionGiven) {
      return;
    }

    final round = state.currentRound;
    if (round == null) {
      return;
    }

    final correctOption = round.options[round.correctIndex];
    final isCorrect = option.firstNumber == correctOption.firstNumber &&
        option.secondNumber == correctOption.secondNumber &&
        option.operation == correctOption.operation &&
        option.result == correctOption.result;

    final nextCorrect = state.correctAnswers + (isCorrect ? 1 : 0);
    final nextTotal = state.totalAnswers + 1;
    final wrongAnswers = nextTotal - nextCorrect;

    var feedbackType = ReverseFeedbackType.none;

    if (nextCorrect >= 8) {
      // Winner - determine if new record
      _ticker?.cancel();
      final period = _currentElapsedSeconds();
      final operation = state.selectedOperation;
      final winningStageIndex = currentStageForOperation(operation);
      final stageNumber = winningStageIndex + 1;
      final nextUnlocked = unlockNextStageForOperation(operation);
      final message = _winMessage(stageNumber);

      debugPrint(
          '[DEBUG] win: operation=$operation, opStageIndex=$winningStageIndex, stateStageIndex=${state.stageIndex}, winningStageNumber=$stageNumber, evaluationMessage=$message');

      // Determine if this is a new record before saving
      final isNewRecord = _isNewRecord(operation, stageNumber, period);
      feedbackType = isNewRecord
          ? ReverseFeedbackType.newRecord
          : ReverseFeedbackType.stageSuccess;

      // Create and save GameRecord for reverse mode
      await _saveReverseGameRecord(
        operation: operation,
        stageNumber: stageNumber,
        durationSeconds: period,
      );

      state = state.copyWith(
        status: () => ReverseGameStatus.won,
        stageIndex: () => winningStageIndex,
        period: () => period,
        elapsed: () => Duration(milliseconds: (period * 1000).round()),
        maxUnlockedStageIndex: () => nextUnlocked,
        evaluationMessage: () => message,
        lastFeedbackType: () => feedbackType,
        feedbackVersion: () => state.feedbackVersion + 1,
      );
      return;
    }

    if (wrongAnswers >= 3) {
      // Loser
      _ticker?.cancel();
      final period = _currentElapsedSeconds();
      feedbackType = ReverseFeedbackType.loss;
      state = state.copyWith(
        status: () => ReverseGameStatus.failed,
        period: () => period,
        elapsed: () => Duration(milliseconds: (period * 1000).round()),
        evaluationMessage: () => 'You lost this stage',
        lastFeedbackType: () => feedbackType,
        feedbackVersion: () => state.feedbackVersion + 1,
      );
      return;
    }

    // Still playing - set correct/wrong feedback for this answer
    feedbackType =
        isCorrect ? ReverseFeedbackType.correct : ReverseFeedbackType.wrong;
    state = state.copyWith(
      correctAnswers: () => nextCorrect,
      totalAnswers: () => nextTotal,
      isAnswerGiven: () => true,
      lastFeedbackType: () => feedbackType,
      feedbackVersion: () => state.feedbackVersion + 1,
    );

    nextQuestion();
  }

  ReverseRound _nextRound() {
    return _engine.generateRound(
      operation: state.selectedOperation,
      stage: state.stageIndex,
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final startedAt = state.startTime;
      if (startedAt == null || state.status != ReverseGameStatus.playing) {
        return;
      }
      state = state.copyWith(
        elapsed: () => DateTime.now().difference(startedAt),
      );
    });
  }

  void _setIdleState({required int stageIndex}) {
    updateCurrentStageForOperation(state.selectedOperation, stageIndex);
    state = state.copyWith(
      stageIndex: () => currentStageForOperation(state.selectedOperation),
      maxUnlockedStageIndex: () =>
          maxUnlockedStageForOperation(state.selectedOperation),
      status: () => ReverseGameStatus.idle,
      currentRound: () => null,
      isQuestionGiven: () => false,
      isAnswerGiven: () => false,
      startTime: () => null,
      elapsed: () => Duration.zero,
      period: () => 0.0,
      correctAnswers: () => 0,
      totalAnswers: () => 0,
      evaluationMessage: () => '',
      lastFeedbackType: () => ReverseFeedbackType.none,
      feedbackVersion: () => 0,
    );
  }

  int currentStageForOperation(String operation) {
    switch (operation) {
      case '+':
        return state.stageAddition;
      case '-':
        return state.stageSubtraction;
      case '*':
        return state.stageMultiplication;
      case '/':
        return state.stageDivision;
      case 'R':
        return state.stageRandom;
      default:
        return 0;
    }
  }

  int maxUnlockedStageForOperation(String operation) {
    switch (operation) {
      case '+':
        return state.maxStageAddition;
      case '-':
        return state.maxStageSubtraction;
      case '*':
        return state.maxStageMultiplication;
      case '/':
        return state.maxStageDivision;
      case 'R':
        return state.maxStageRandom;
      default:
        return 0;
    }
  }

  void updateCurrentStageForOperation(String operation, int stageIndex) {
    switch (operation) {
      case '+':
        state = state.copyWith(stageAddition: () => stageIndex);
        break;
      case '-':
        state = state.copyWith(stageSubtraction: () => stageIndex);
        break;
      case '*':
        state = state.copyWith(stageMultiplication: () => stageIndex);
        break;
      case '/':
        state = state.copyWith(stageDivision: () => stageIndex);
        break;
      case 'R':
        state = state.copyWith(stageRandom: () => stageIndex);
        break;
    }
  }

  int unlockNextStageForOperation(String operation) {
    final nextUnlocked = currentStageForOperation(operation) + 1;
    switch (operation) {
      case '+':
        final unlocked = nextUnlocked > state.maxStageAddition
            ? nextUnlocked
            : state.maxStageAddition;
        state = state.copyWith(maxStageAddition: () => unlocked);
        return unlocked;
      case '-':
        final unlocked = nextUnlocked > state.maxStageSubtraction
            ? nextUnlocked
            : state.maxStageSubtraction;
        state = state.copyWith(maxStageSubtraction: () => unlocked);
        return unlocked;
      case '*':
        final unlocked = nextUnlocked > state.maxStageMultiplication
            ? nextUnlocked
            : state.maxStageMultiplication;
        state = state.copyWith(maxStageMultiplication: () => unlocked);
        return unlocked;
      case '/':
        final unlocked = nextUnlocked > state.maxStageDivision
            ? nextUnlocked
            : state.maxStageDivision;
        state = state.copyWith(maxStageDivision: () => unlocked);
        return unlocked;
      case 'R':
        final unlocked = nextUnlocked > state.maxStageRandom
            ? nextUnlocked
            : state.maxStageRandom;
        state = state.copyWith(maxStageRandom: () => unlocked);
        return unlocked;
      default:
        return 0;
    }
  }

  double _currentElapsedSeconds() {
    final startedAt = state.startTime;
    if (startedAt == null) {
      return state.period;
    }
    return DateTime.now().difference(startedAt).inMilliseconds / 1000.0;
  }

  String _winMessage(int stageNumber) {
    final playerName = state.playerName;
    if (playerName == null || playerName.isEmpty) {
      return 'You won Stage $stageNumber';
    }
    return '$playerName won Stage $stageNumber';
  }

  /// Determines if this completion is a new reverse record.
  ///
  /// A new record means either:
  /// 1. No previous completion for this (operation, stageNumber) pair, OR
  /// 2. This completion is faster than the previous best (lower durationSeconds)
  ///
  /// Only filters GameRecords by:
  /// - gameMode == reverse
  /// - Same operation
  /// - Same stageNumber
  bool _isNewRecord(String operation, int stageNumber, double durationSeconds) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      return true; // No player yet, so definitely a new record
    }

    // Find all reverse mode records matching this operation and stage
    final matchingRecords = currentUser.gameRecords
        .where((record) =>
            record.gameMode == GameModeKeys.reverse &&
            record.operation == operation &&
            record.stageNumber == stageNumber)
        .toList();

    if (matchingRecords.isEmpty) {
      debugPrint(
          '[DEBUG] _isNewRecord: no previous records - NEW RECORD operation=$operation, stageNumber=$stageNumber');
      return true;
    }

    // Find the best (fastest) previous time
    final bestPreviousDuration = matchingRecords
        .map((record) => record.durationSeconds)
        .reduce((best, value) => value < best ? value : best);

    final isNew = durationSeconds < bestPreviousDuration;
    debugPrint(
        '[DEBUG] _isNewRecord: operation=$operation, stageNumber=$stageNumber, currentTime=$durationSeconds, bestPrevious=$bestPreviousDuration, isNew=$isNew');

    return isNew;
  }

  /// Computes current and unlocked stages for each operation based on saved reverse mode records.
  ///
  /// Filters GameRecords to only include reverse mode records (gameMode == "reverse"),
  /// then for each operation, finds the highest completed stage.
  ///
  /// If completed stage is N:
  /// - Current stage (0-based index) = N - 1 (so they're at the last completed stage)
  /// - Max playable (0-based index) = N (so they can replay and access N+1)
  ///
  /// If no records exist for an operation:
  /// - Current stage = 0 (Stage 1)
  /// - Max playable = 0 (only Stage 1 available)
  ///
  /// Returns [_ReverseStageValues] containing stage initialization data for all operations.
  _ReverseStageValues _computeUnlockedStagesFromRecords(
      List<GameRecord> allRecords) {
    final currentUser = ref.read(currentUserProvider);
    debugPrint(
        '[DEBUG] _computeUnlockedStagesFromRecords: userId=${currentUser?.id}, name=${currentUser?.name}, total records=${allRecords.length}');

    // Filter to only reverse mode records
    final reverseRecords = allRecords
        .where((record) => record.gameMode == GameModeKeys.reverse)
        .toList();

    debugPrint(
        '[DEBUG] _computeUnlockedStagesFromRecords: reverse mode records=${reverseRecords.length}');
    for (final record in reverseRecords) {
      debugPrint(
          '[DEBUG] _computeUnlockedStagesFromRecords: reverse record operation=${record.operation}, stageNumber=${record.stageNumber}');
    }

    // Helper to compute stage indices for an operation
    Map<String, int> getStagesForOperation(String operation) {
      final opRecords = reverseRecords
          .where((record) => record.operation == operation)
          .toList();

      if (opRecords.isEmpty) {
        // No records: start at Stage 1 (index 0), max playable is 0
        return {'current': 0, 'max': 0};
      }

      final highestStageNumber = opRecords
          .map((record) => record.stageNumber)
          .reduce((max, value) => value > max ? value : max);

      // Current stage: highest completed (as 0-based index)
      final currentIndex = highestStageNumber - 1;
      // Max playable: same as highest stage number
      // This allows replaying the highest stage and accessing the next one
      final maxPlayable = highestStageNumber;

      return {'current': currentIndex, 'max': maxPlayable};
    }

    // Compute stages for each operation
    final addStages = getStagesForOperation('+');
    final subStages = getStagesForOperation('-');
    final mulStages = getStagesForOperation('*');
    final divStages = getStagesForOperation('/');
    final randStages = getStagesForOperation('R');

    debugPrint(
        '[DEBUG] _computeUnlockedStagesFromRecords: Addition - current=${addStages['current']}, max=${addStages['max']}');
    debugPrint(
        '[DEBUG] _computeUnlockedStagesFromRecords: Subtraction - current=${subStages['current']}, max=${subStages['max']}');
    debugPrint(
        '[DEBUG] _computeUnlockedStagesFromRecords: Multiplication - current=${mulStages['current']}, max=${mulStages['max']}');
    debugPrint(
        '[DEBUG] _computeUnlockedStagesFromRecords: Division - current=${divStages['current']}, max=${divStages['max']}');
    debugPrint(
        '[DEBUG] _computeUnlockedStagesFromRecords: Random - current=${randStages['current']}, max=${randStages['max']}');

    return _ReverseStageValues(
      stageAddition: addStages['current']!,
      stageSubtraction: subStages['current']!,
      stageMultiplication: mulStages['current']!,
      stageDivision: divStages['current']!,
      stageRandom: randStages['current']!,
      maxAddition: addStages['max']!,
      maxSubtraction: subStages['max']!,
      maxMultiplication: mulStages['max']!,
      maxDivision: divStages['max']!,
      maxRandom: randStages['max']!,
    );
  }

  Future<void> _saveReverseGameRecord({
    required String operation,
    required int stageNumber,
    required double durationSeconds,
  }) async {
    try {
      // === PHASE 1: Read all dependencies FIRST (before any mutations) ===
      final currentPlayer = ref.read(currentUserProvider);
      if (currentPlayer == null) {
        debugPrint(
            '[DEBUG] _saveReverseGameRecord: currentPlayer is null, cannot save');
        return;
      }

      final userStorage = ref.read(userStorageServiceProvider);

      final recordsCountBefore = currentPlayer.gameRecords.length;
      debugPrint(
          '[DEBUG] _saveReverseGameRecord: userId=${currentPlayer.id}, name=${currentPlayer.name}');
      debugPrint(
          '[DEBUG] _saveReverseGameRecord: operation=$operation, stageNumber=$stageNumber, durationSeconds=$durationSeconds');
      debugPrint(
          '[DEBUG] _saveReverseGameRecord: records count before=$recordsCountBefore');

      // === PHASE 2: Create new data (no ref calls) ===
      final gameRecord = GameRecord.create(
        stageNumber: stageNumber,
        operation: operation,
        durationSeconds: durationSeconds,
        gameMode: GameModeKeys.reverse,
      );

      debugPrint(
          '[DEBUG] _saveReverseGameRecord: created GameRecord with gameMode=${gameRecord.gameMode}');

      // Create updated player profile with new record
      final updatedPlayer = Player(
        id: currentPlayer.id,
        name: currentPlayer.name,
        createdAt: currentPlayer.createdAt,
        gameRecords: [...currentPlayer.gameRecords, gameRecord],
      );
      updatedPlayer.maxStageAdition = currentPlayer.maxStageAdition;
      updatedPlayer.maxStageSubtruction = currentPlayer.maxStageSubtruction;
      updatedPlayer.maxStageMultiplication =
          currentPlayer.maxStageMultiplication;
      updatedPlayer.maxStageSection = currentPlayer.maxStageSection;
      updatedPlayer.maxStageRandom = currentPlayer.maxStageRandom;

      final recordsCountAfter = updatedPlayer.gameRecords.length;

      // === PHASE 3: Persist to storage BEFORE updating provider ===
      final userProfile = updatedPlayer.toUserProfile();
      await userStorage.upsert(userProfile, validateDuplicateName: false);
      debugPrint(
          '[DEBUG] _saveReverseGameRecord: records count after=$recordsCountAfter');
      debugPrint(
          '[DEBUG] _saveReverseGameRecord: storage save awaited success');

      // === PHASE 4: Update currentUserProvider AFTER storage persistence ===
      ref.read(currentUserProvider.notifier).state = updatedPlayer;
      debugPrint(
          '[DEBUG] _saveReverseGameRecord: currentUserProvider updated count=${updatedPlayer.gameRecords.length}');
    } catch (e) {
      debugPrint('[DEBUG] _saveReverseGameRecord: ERROR - $e');
      // Silently handle errors to not disrupt gameplay
    }
  }
}
