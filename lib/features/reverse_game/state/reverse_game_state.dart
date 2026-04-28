// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../domain/reverse_game_models.dart';

/// Lifecycle status for a Reverse Operation game session.
enum ReverseGameStatus { idle, playing, won, failed }

/// One-shot UI feedback events emitted from reverse game state transitions.
enum ReverseFeedbackType { none, correct, wrong, stageSuccess, newRecord, loss }

/// Immutable state snapshot consumed by Riverpod widgets in Reverse mode.
class ReverseGameState {
  /// Current stage index (0-based).
  final int stageIndex;

  /// Highest stage unlocked during the current reverse-mode session.
  final int maxUnlockedStageIndex;

  /// Current selected stage for addition reverse mode.
  final int stageAddition;

  /// Current selected stage for subtraction reverse mode.
  final int stageSubtraction;

  /// Current selected stage for multiplication reverse mode.
  final int stageMultiplication;

  /// Current selected stage for division reverse mode.
  final int stageDivision;

  /// Current selected stage for random reverse mode.
  final int stageRandom;

  /// Highest unlocked stage for addition reverse mode.
  final int maxStageAddition;

  /// Highest unlocked stage for subtraction reverse mode.
  final int maxStageSubtraction;

  /// Highest unlocked stage for multiplication reverse mode.
  final int maxStageMultiplication;

  /// Highest unlocked stage for division reverse mode.
  final int maxStageDivision;

  /// Highest unlocked stage for random reverse mode.
  final int maxStageRandom;

  /// Selected arithmetic operation symbol: `+`, `-`, `*`, or `R` (random).
  final String selectedOperation;

  /// Current session lifecycle status.
  final ReverseGameStatus status;

  /// Number of correct answers in the current session.
  final int correctAnswers;

  /// Number of total submitted answers in the current session.
  final int totalAnswers;

  /// When the current stage started (for elapsed-time tracking).
  final DateTime? startTime;

  /// Elapsed game time since [startTime].
  final Duration elapsed;

  /// Final stage duration in seconds, preserved after win/fail.
  final double period;

  /// Current active question round.
  final ReverseRound? currentRound;

  /// Whether a question is currently displayed.
  final bool isQuestionGiven;

  /// Whether the current question has been answered.
  final bool isAnswerGiven;

  /// End-of-stage or status message shown in the UI.
  final String evaluationMessage;

  /// Optional player name shown in the app bar.
  final String? playerName;

  /// Last game feedback event the UI should react to.
  final ReverseFeedbackType lastFeedbackType;

  /// Monotonic counter used to emit repeated feedback of the same type.
  final int feedbackVersion;

  const ReverseGameState({
    this.stageIndex = 0,
    this.maxUnlockedStageIndex = 0,
    this.stageAddition = 0,
    this.stageSubtraction = 0,
    this.stageMultiplication = 0,
    this.stageDivision = 0,
    this.stageRandom = 0,
    this.maxStageAddition = 0,
    this.maxStageSubtraction = 0,
    this.maxStageMultiplication = 0,
    this.maxStageDivision = 0,
    this.maxStageRandom = 0,
    this.selectedOperation = '+',
    this.status = ReverseGameStatus.idle,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.startTime,
    this.elapsed = Duration.zero,
    this.period = 0.0,
    this.currentRound,
    this.isQuestionGiven = false,
    this.isAnswerGiven = false,
    this.evaluationMessage = '',
    this.playerName,
    this.lastFeedbackType = ReverseFeedbackType.none,
    this.feedbackVersion = 0,
  });

  ReverseGameState copyWith({
    int Function()? stageIndex,
    int Function()? maxUnlockedStageIndex,
    int Function()? stageAddition,
    int Function()? stageSubtraction,
    int Function()? stageMultiplication,
    int Function()? stageDivision,
    int Function()? stageRandom,
    int Function()? maxStageAddition,
    int Function()? maxStageSubtraction,
    int Function()? maxStageMultiplication,
    int Function()? maxStageDivision,
    int Function()? maxStageRandom,
    String Function()? selectedOperation,
    ReverseGameStatus Function()? status,
    int Function()? correctAnswers,
    int Function()? totalAnswers,
    DateTime? Function()? startTime,
    Duration Function()? elapsed,
    double Function()? period,
    ReverseRound? Function()? currentRound,
    bool Function()? isQuestionGiven,
    bool Function()? isAnswerGiven,
    String Function()? evaluationMessage,
    String? Function()? playerName,
    ReverseFeedbackType Function()? lastFeedbackType,
    int Function()? feedbackVersion,
  }) {
    return ReverseGameState(
      stageIndex: stageIndex == null ? this.stageIndex : stageIndex(),
      maxUnlockedStageIndex: maxUnlockedStageIndex == null
          ? this.maxUnlockedStageIndex
          : maxUnlockedStageIndex(),
      stageAddition:
          stageAddition == null ? this.stageAddition : stageAddition(),
      stageSubtraction:
          stageSubtraction == null ? this.stageSubtraction : stageSubtraction(),
      stageMultiplication: stageMultiplication == null
          ? this.stageMultiplication
          : stageMultiplication(),
      stageDivision:
          stageDivision == null ? this.stageDivision : stageDivision(),
      stageRandom: stageRandom == null ? this.stageRandom : stageRandom(),
      maxStageAddition:
          maxStageAddition == null ? this.maxStageAddition : maxStageAddition(),
      maxStageSubtraction: maxStageSubtraction == null
          ? this.maxStageSubtraction
          : maxStageSubtraction(),
      maxStageMultiplication: maxStageMultiplication == null
          ? this.maxStageMultiplication
          : maxStageMultiplication(),
      maxStageDivision:
          maxStageDivision == null ? this.maxStageDivision : maxStageDivision(),
      maxStageRandom:
          maxStageRandom == null ? this.maxStageRandom : maxStageRandom(),
      selectedOperation: selectedOperation == null
          ? this.selectedOperation
          : selectedOperation(),
      status: status == null ? this.status : status(),
      correctAnswers:
          correctAnswers == null ? this.correctAnswers : correctAnswers(),
      totalAnswers: totalAnswers == null ? this.totalAnswers : totalAnswers(),
      startTime: startTime == null ? this.startTime : startTime(),
      elapsed: elapsed == null ? this.elapsed : elapsed(),
      period: period == null ? this.period : period(),
      currentRound: currentRound == null ? this.currentRound : currentRound(),
      isQuestionGiven:
          isQuestionGiven == null ? this.isQuestionGiven : isQuestionGiven(),
      isAnswerGiven:
          isAnswerGiven == null ? this.isAnswerGiven : isAnswerGiven(),
      evaluationMessage: evaluationMessage == null
          ? this.evaluationMessage
          : evaluationMessage(),
      playerName: playerName == null ? this.playerName : playerName(),
      lastFeedbackType:
          lastFeedbackType == null ? this.lastFeedbackType : lastFeedbackType(),
      feedbackVersion:
          feedbackVersion == null ? this.feedbackVersion : feedbackVersion(),
    );
  }
}
