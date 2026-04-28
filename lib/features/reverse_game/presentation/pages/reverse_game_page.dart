import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/reverse_game_models.dart';
import '../../state/reverse_game_notifier.dart';
import '../../state/reverse_game_state.dart';
import '../widgets/reverse_player_statistics_button.dart';

const List<String> _reverseOperations = ['+', '-', '*', '/', 'R'];

String _formatSeconds(double seconds) {
  return '${seconds.toStringAsFixed(1)} Sec';
}

/// Game screen for Reverse Operation mode with audio and visual feedback.
///
/// Mirrors [GamePage] structure with animations and audio effects for:
/// - Correct/wrong answers during play
/// - Stage success and new record on win
/// - Loss feedback on failure
class ReverseGamePage extends ConsumerStatefulWidget {
  const ReverseGamePage({super.key});

  @override
  ConsumerState<ReverseGamePage> createState() => _ReverseGamePageState();
}

class _ReverseGamePageState extends ConsumerState<ReverseGamePage>
    with TickerProviderStateMixin {
  static const BoxDecoration _backgroundDecoration = BoxDecoration(
    gradient: AppGradients.mainBackgroundGradient,
  );

  static const _wrongShakeDuration = Duration(milliseconds: 220);
  static const _lossShakeDuration = Duration(milliseconds: 280);
  static const _pulseDuration = Duration(milliseconds: 240);

  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: _wrongShakeDuration,
  );
  late final Animation<double> _shakeAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 8, end: -5), weight: 1.5),
    TweenSequenceItem(tween: Tween(begin: -5, end: 5), weight: 1.2),
    TweenSequenceItem(tween: Tween(begin: 5, end: 0), weight: 1),
  ]).animate(
    CurvedAnimation(parent: _shakeController, curve: Curves.easeOut),
  );

  late final AnimationController _lossShakeController = AnimationController(
    vsync: this,
    duration: _lossShakeDuration,
  );
  late final Animation<double> _lossShakeAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 12, end: -9), weight: 1.6),
    TweenSequenceItem(tween: Tween(begin: -9, end: 9), weight: 1.4),
    TweenSequenceItem(tween: Tween(begin: 9, end: -5), weight: 1.2),
    TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 1),
  ]).animate(
    CurvedAnimation(parent: _lossShakeController, curve: Curves.easeOut),
  );

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: _pulseDuration,
  );
  late final Animation<double> _pulseAnimation = CurvedAnimation(
    parent: _pulseController,
    curve: Curves.easeOut,
  );

  late final ProviderSubscription<ReverseGameState> _feedbackSubscription;

  Timer? _flashTimer;
  Timer? _extraPulseTimer;
  Color _flashColor = Colors.transparent;
  double _flashOpacity = 0;

  @override
  void initState() {
    super.initState();
    _feedbackSubscription = ref.listenManual<ReverseGameState>(
      reverseGameNotifierProvider,
      (previous, next) {
        if (previous?.feedbackVersion == next.feedbackVersion) {
          return;
        }
        _handleFeedback(next.lastFeedbackType);
      },
    );
  }

  void _handleFeedback(ReverseFeedbackType feedbackType) {
    final audioService = ref.read(audioFeedbackServiceProvider);
    switch (feedbackType) {
      case ReverseFeedbackType.none:
        return;
      case ReverseFeedbackType.correct:
        audioService.playCorrect();
        _showFlash(AppColors.gold, 0.12, const Duration(milliseconds: 110));
        _pulseController.forward(from: 0);
        break;
      case ReverseFeedbackType.wrong:
        audioService.playWrong();
        _showFlash(
          AppColors.dangerRed,
          0.22,
          const Duration(milliseconds: 100),
        );
        _shakeController.forward(from: 0);
        break;
      case ReverseFeedbackType.stageSuccess:
        audioService.playStageSuccess();
        _showFlash(AppColors.gold, 0.18, const Duration(milliseconds: 180));
        _pulseController.forward(from: 0);
        break;
      case ReverseFeedbackType.newRecord:
        audioService.playNewRecord();
        _showFlash(AppColors.gold, 0.30, const Duration(milliseconds: 240));
        _pulseController.forward(from: 0);
        _extraPulseTimer?.cancel();
        _extraPulseTimer = Timer(const Duration(milliseconds: 170), () {
          if (mounted) {
            _pulseController.forward(from: 0);
          }
        });
        break;
      case ReverseFeedbackType.loss:
        audioService.playLoss();
        _showFlash(
          AppColors.dangerRed,
          0.38,
          const Duration(milliseconds: 150),
        );
        _lossShakeController.forward(from: 0);
        break;
    }
  }

  void _showFlash(Color color, double opacity, Duration duration) {
    _flashTimer?.cancel();
    setState(() {
      _flashColor = color;
      _flashOpacity = opacity;
    });
    _flashTimer = Timer(duration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _flashOpacity = 0;
      });
    });
  }

  @override
  void dispose() {
    _feedbackSubscription.close();
    _flashTimer?.cancel();
    _extraPulseTimer?.cancel();
    _shakeController.dispose();
    _lossShakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reverseGameNotifierProvider);
    final isPlaying = state.status == ReverseGameStatus.playing;

    return PopScope(
      canPop: !isPlaying,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Navigator.of(context).canPop()
              ? Opacity(
                  opacity: isPlaying ? 0.4 : 1,
                  child: IconButton(
                    onPressed: isPlaying
                        ? null
                        : () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                )
              : null,
          elevation: 0,
          backgroundColor: AppColors.black,
          iconTheme: const IconThemeData(color: AppColors.gold),
          title: Text(
            state.playerName ?? 'Reverse Operation',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
          titleSpacing: 12,
          actions: const [
            ReversePlayerStatisticsButton(),
          ],
        ),
        body: AnimatedBuilder(
          animation: Listenable.merge([
            _shakeController,
            _lossShakeController,
            _pulseController,
          ]),
          child: _buildGameBody(state),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Transform.translate(
                offset: Offset(_lossShakeAnimation.value, 0),
                child: Transform.scale(
                  scale: 1.0 + _pulseAnimation.value * 0.02,
                  child: Stack(
                    children: [
                      child!,
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color: _flashColor.withValues(alpha: _flashOpacity),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameBody(ReverseGameState state) {
    return Container(
      decoration: _backgroundDecoration,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                constraints.maxHeight < 680 || constraints.maxWidth < 430;
            final pad = isCompact ? 12.0 : 16.0;
            final gap = isCompact ? 10.0 : 16.0;

            return Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                children: [
                  _ModeHeader(
                    isCompact: isCompact,
                    state: state,
                    isLocked: state.status == ReverseGameStatus.playing,
                    onOperationSelected: (operation) => ref
                        .read(reverseGameNotifierProvider.notifier)
                        .selectOperation(operation),
                    onNextStage: () => ref
                        .read(reverseGameNotifierProvider.notifier)
                        .nextStage(),
                    onPreviousStage: () => ref
                        .read(reverseGameNotifierProvider.notifier)
                        .previousStage(),
                  ),
                  SizedBox(height: gap),
                  Expanded(
                    child: _GameBody(
                      isCompact: isCompact,
                      gap: gap,
                      state: state,
                      onOptionTap: (option) => ref
                          .read(reverseGameNotifierProvider.notifier)
                          .submitAnswer(option),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ControlBar(
                    isCompact: isCompact,
                    state: state,
                    onStart: () => ref
                        .read(reverseGameNotifierProvider.notifier)
                        .startGame(),
                    onStop: () => ref
                        .read(reverseGameNotifierProvider.notifier)
                        .stopGame(),
                    onRepeat: () => ref
                        .read(reverseGameNotifierProvider.notifier)
                        .repeatGame(),
                    onNextStage: () => ref
                        .read(reverseGameNotifierProvider.notifier)
                        .startNextStage(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ModeHeader extends StatelessWidget {
  const _ModeHeader({
    required this.isCompact,
    required this.state,
    required this.isLocked,
    required this.onOperationSelected,
    required this.onNextStage,
    required this.onPreviousStage,
  });

  final bool isCompact;
  final ReverseGameState state;
  final bool isLocked;
  final ValueChanged<String>? onOperationSelected;
  final VoidCallback onNextStage;
  final VoidCallback onPreviousStage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Opacity(
              opacity: isLocked ? 0.4 : 1,
              child: _OperationSelector(
                compact: isCompact,
                operation: state.selectedOperation,
                onSelected: isLocked ? null : onOperationSelected,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _StageSelector(
                stageIndex: state.stageIndex,
                maxUnlockedStageIndex: state.maxUnlockedStageIndex,
                isLocked: isLocked,
                onNext: onNextStage,
                onPrevious: onPreviousStage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Correct: ${state.correctAnswers} of 8',
                style: AppTextStyles.small.copyWith(color: AppColors.goldMuted),
              ),
              Text(
                'Wrong: ${state.totalAnswers - state.correctAnswers} of 3',
                style: AppTextStyles.small.copyWith(color: AppColors.goldMuted),
              ),
              Text(
                _formatDuration(
                  state.status == ReverseGameStatus.playing
                      ? state.elapsed.inMilliseconds / 1000.0
                      : state.period,
                ),
                style: AppTextStyles.small.copyWith(color: AppColors.goldMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDuration(double seconds) => _formatSeconds(seconds);
}

class _GameBody extends StatelessWidget {
  const _GameBody({
    required this.isCompact,
    required this.gap,
    required this.state,
    required this.onOptionTap,
  });

  final bool isCompact;
  final double gap;
  final ReverseGameState state;
  final ValueChanged<ReverseAnswerOption> onOptionTap;

  @override
  Widget build(BuildContext context) {
    final isTerminal = state.status == ReverseGameStatus.won ||
        state.status == ReverseGameStatus.failed;

    if (isTerminal) {
      return _TerminalResultPanel(isCompact: isCompact, state: state);
    }

    return Column(
      children: [
        Expanded(
          flex: isCompact ? 4 : 5,
          child: _QuestionArea(
            isCompact: isCompact,
            state: state,
          ),
        ),
        SizedBox(height: gap),
        Expanded(
          flex: isCompact ? 5 : 4,
          child: _AnswerArea(
            isCompact: isCompact,
            state: state,
            onOptionTap: onOptionTap,
          ),
        ),
      ],
    );
  }
}

class _TerminalResultPanel extends StatelessWidget {
  const _TerminalResultPanel({
    required this.isCompact,
    required this.state,
  });

  final bool isCompact;
  final ReverseGameState state;

  @override
  Widget build(BuildContext context) {
    final isWon = state.status == ReverseGameStatus.won;
    final playerName =
        (state.playerName != null && state.playerName!.isNotEmpty)
            ? state.playerName!
            : 'You';
    final title = isWon ? '$playerName wins' : '$playerName failed';
    final wrongAnswers = state.totalAnswers - state.correctAnswers;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWon ? AppColors.borderGold : AppColors.borderRed,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: isWon ? AppColors.gold : AppColors.dangerRed,
                    fontSize: isCompact ? 34 : 46,
                  ),
                ),
                SizedBox(height: isCompact ? 12 : 18),
                Text(
                  'Stage ${state.stageIndex + 1}',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.gold,
                    fontSize: isCompact ? 19 : 23,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Time: ${_formatSeconds(state.period)}',
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.goldMuted,
                    fontSize: isCompact ? 17 : 20,
                  ),
                ),
                SizedBox(height: isCompact ? 14 : 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.36),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGold),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Correct: ${state.correctAnswers} of 8',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gold,
                          fontSize: isCompact ? 15 : 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Wrong: $wrongAnswers of 3',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.goldMuted,
                          fontSize: isCompact ? 15 : 17,
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.evaluationMessage.isNotEmpty) ...[
                  SizedBox(height: isCompact ? 12 : 16),
                  Text(
                    state.evaluationMessage,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small.copyWith(
                      color: isWon ? AppColors.goldMuted : AppColors.dangerRed,
                      fontSize: isCompact ? 12 : 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OperationSelector extends StatelessWidget {
  const _OperationSelector({
    required this.operation,
    required this.compact,
    required this.onSelected,
  });

  final String operation;
  final bool compact;
  final ValueChanged<String>? onSelected;

  String _operationTitle(String symbol) {
    if (symbol == '+') return 'Addition +';
    if (symbol == '-') return 'Subtraction -';
    if (symbol == '*') return 'Multiplication *';
    if (symbol == '/') return 'Division /';
    return 'Random';
  }

  String _selectedLabel(String symbol) {
    if (symbol == 'R') return 'Random';
    return symbol;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: onSelected != null,
      onSelected: onSelected,
      color: AppColors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.red.withValues(alpha: 0.8)),
      ),
      itemBuilder: (context) => _reverseOperations
          .map(
            (symbol) => PopupMenuItem<String>(
              value: symbol,
              child: Text(
                _operationTitle(symbol),
                style: AppTextStyles.button.copyWith(
                  color: AppColors.gold,
                  fontSize: compact ? 14 : 15,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              compact ? 'Opr' : 'Operation',
              style: AppTextStyles.button.copyWith(
                color: AppColors.gold,
                fontSize: compact ? 12 : 13,
              ),
            ),
            SizedBox(width: compact ? 6 : 8),
            Flexible(
              child: Text(
                _selectedLabel(operation),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: compact ? 17 : 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(width: compact ? 4 : 6),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.gold,
              size: compact ? 18 : 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _StageSelector extends StatelessWidget {
  const _StageSelector({
    required this.stageIndex,
    required this.maxUnlockedStageIndex,
    required this.isLocked,
    required this.onNext,
    required this.onPrevious,
  });

  final int stageIndex;
  final int maxUnlockedStageIndex;
  final bool isLocked;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    final canGoDown = stageIndex > 0;
    final canGoUp = stageIndex < maxUnlockedStageIndex;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Opacity(
          opacity: (isLocked || !canGoDown) ? 0.4 : 1,
          child: InkWell(
            onTap: (isLocked || !canGoDown) ? null : onPrevious,
            child: Icon(
              Icons.arrow_drop_down,
              size: 36,
              color: canGoDown && !isLocked
                  ? AppColors.gold
                  : AppColors.gold.withValues(alpha: 0.3),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Stage ${stageIndex + 1}',
            style: AppTextStyles.subtitle.copyWith(fontSize: 18),
          ),
        ),
        Opacity(
          opacity: (isLocked || !canGoUp) ? 0.4 : 1,
          child: InkWell(
            onTap: (isLocked || !canGoUp) ? null : onNext,
            child: Icon(
              Icons.arrow_drop_up,
              size: 36,
              color: (isLocked || !canGoUp)
                  ? AppColors.gold.withValues(alpha: 0.3)
                  : AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionArea extends StatelessWidget {
  const _QuestionArea({required this.isCompact, required this.state});

  final bool isCompact;
  final ReverseGameState state;

  @override
  Widget build(BuildContext context) {
    final target = state.currentRound?.targetResult;
    final isIdle = state.status == ReverseGameStatus.idle;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Find the expression equal to:',
                style: AppTextStyles.small.copyWith(color: AppColors.goldMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isIdle ? '0' : (target != null ? '$target' : '?'),
                style: AppTextStyles.title.copyWith(
                  fontSize: isCompact ? 48 : 64,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerArea extends StatelessWidget {
  const _AnswerArea({
    required this.isCompact,
    required this.state,
    required this.onOptionTap,
  });

  final bool isCompact;
  final ReverseGameState state;
  final ValueChanged<ReverseAnswerOption> onOptionTap;

  @override
  Widget build(BuildContext context) {
    final round = state.currentRound;
    if (state.status != ReverseGameStatus.playing ||
        round == null ||
        round.options.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderRed),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Press Start to generate options',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.small.copyWith(color: AppColors.goldMuted),
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.6,
      ),
      itemCount: round.options.length,
      itemBuilder: (_, index) {
        final option = round.options[index];
        final isAnswered = state.status != ReverseGameStatus.playing;
        final isCorrect = index == round.correctIndex;
        Color borderColor = AppColors.borderGold;
        if (isAnswered) {
          borderColor = isCorrect ? AppColors.gold : AppColors.borderRed;
        }
        return _OptionButton(
          label: _displayExpression(option),
          borderColor: borderColor,
          onTap: isAnswered ? null : () => onOptionTap(option),
        );
      },
    );
  }

  String _displayExpression(ReverseAnswerOption option) {
    String op;
    switch (option.operation) {
      case '*':
        op = '×';
        break;
      case '/':
        op = '÷';
        break;
      default:
        op = option.operation;
    }
    return '${option.firstNumber} $op ${option.secondNumber}';
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.black, AppColors.darkRed],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                style: AppTextStyles.button.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.isCompact,
    required this.state,
    required this.onStart,
    required this.onStop,
    required this.onRepeat,
    required this.onNextStage,
  });

  final bool isCompact;
  final ReverseGameState state;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onRepeat;
  final VoidCallback onNextStage;

  @override
  Widget build(BuildContext context) {
    final List<_ControlSpec> controls;
    switch (state.status) {
      case ReverseGameStatus.idle:
        controls = [
          _ControlSpec(label: 'Start', onPressed: onStart),
        ];
        break;
      case ReverseGameStatus.playing:
        controls = [
          _ControlSpec(label: 'Repeat', onPressed: onRepeat),
          _ControlSpec(label: 'Stop', onPressed: onStop),
        ];
        break;
      case ReverseGameStatus.won:
        controls = [
          _ControlSpec(label: 'Next Stage', onPressed: onNextStage),
          _ControlSpec(label: 'Repeat Stage', onPressed: onRepeat),
        ];
        break;
      case ReverseGameStatus.failed:
        controls = [
          _ControlSpec(label: 'Repeat Stage', onPressed: onRepeat),
        ];
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: controls
            .map(
              (control) => SizedBox(
                width: controls.length == 1 ? double.infinity : null,
                child: SizedBox(
                  height: isCompact ? 48 : 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.gold,
                      textStyle: AppTextStyles.button,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.borderGold),
                      ),
                    ),
                    onPressed: control.onPressed,
                    child: Text(control.label),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ControlSpec {
  const _ControlSpec({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}
