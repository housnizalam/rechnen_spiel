import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../state/game_notifier.dart';
import '../widgets/answer_input.dart';
import '../widgets/evaluation.dart';
import '../widgets/exercise_display.dart';
import '../widgets/game_controller.dart';
import '../widgets/player_statistics_button.dart';
import '../widgets/stage_display.dart';
import '../widgets/timer_display.dart';

/// Responsive game screen split into header, game area, and answer area.
class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage>
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

  late final ProviderSubscription<GameState> _feedbackSubscription;

  Timer? _flashTimer;
  Timer? _extraPulseTimer;
  Color _flashColor = Colors.transparent;
  double _flashOpacity = 0;

  @override
  void initState() {
    super.initState();
    _feedbackSubscription = ref.listenManual<GameState>(
      gameNotifierProvider,
      (previous, next) {
        if (previous?.feedbackVersion == next.feedbackVersion) {
          return;
        }
        _handleFeedback(next.lastFeedbackType);
      },
    );
  }

  void _handleFeedback(GameFeedbackType feedbackType) {
    final audioService = ref.read(audioFeedbackServiceProvider);
    switch (feedbackType) {
      case GameFeedbackType.none:
        return;
      case GameFeedbackType.correct:
        audioService.playCorrect();
        _showFlash(AppColors.gold, 0.12, const Duration(milliseconds: 110));
        _pulseController.forward(from: 0);
        break;
      case GameFeedbackType.wrong:
        audioService.playWrong();
        _showFlash(
          AppColors.dangerRed,
          0.22,
          const Duration(milliseconds: 100),
        );
        _shakeController.forward(from: 0);
        break;
      case GameFeedbackType.stageSuccess:
        audioService.playStageSuccess();
        _showFlash(AppColors.gold, 0.18, const Duration(milliseconds: 180));
        _pulseController.forward(from: 0);
        break;
      case GameFeedbackType.newRecord:
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
      case GameFeedbackType.loss:
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
    final state = ref.watch(gameNotifierProvider);
    final showBottomAction = state.status == GameStatus.idle ||
        state.status == GameStatus.playing ||
        state.status == GameStatus.won ||
        state.status == GameStatus.failed;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.black,
        title: Row(
          children: [
            Expanded(
              child: Text(
                state.player?.name ?? state.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
            ),
            const SizedBox(width: 6),
            const PlayerStatisticsButton(),
          ],
        ),
        titleSpacing: 12,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _shakeController,
          _lossShakeController,
          _pulseController,
        ]),
        child: Container(
          decoration: _backgroundDecoration,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact =
                    constraints.maxHeight < 680 || constraints.maxWidth < 430;
                final outerPadding = isCompact ? 12.0 : 16.0;
                final sectionGap = isCompact ? 10.0 : 16.0;

                return Padding(
                  padding: EdgeInsets.all(outerPadding),
                  child: Column(
                    children: [
                      _Header(
                        isCompact: isCompact,
                        operation: state.calcOperation?.operation ?? '+',
                        isLocked: state.status == GameStatus.playing,
                        onOperationSelected: state.status == GameStatus.playing
                            ? null
                            : (selectedOperation) {
                                ref
                                    .read(gameNotifierProvider.notifier)
                                    .selectOperation(selectedOperation);
                              },
                      ),
                      SizedBox(height: sectionGap),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              flex: isCompact ? 4 : 5,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isCompact ? 8 : 16,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ExerciseDisplay(compact: isCompact),
                                      SizedBox(height: isCompact ? 12 : 18),
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: Evaluation(compact: isCompact),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: sectionGap),
                            Expanded(
                              flex: isCompact ? 5 : 4,
                              child: AnswerInput(compact: isCompact),
                            ),
                          ],
                        ),
                      ),
                      if (showBottomAction) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 2 : 4,
                          ),
                          child: GameController(compact: isCompact),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        builder: (context, child) {
          return Transform.translate(
            offset:
                Offset(_shakeAnimation.value + _lossShakeAnimation.value, 0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (child != null) child,
                IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _flashOpacity,
                    duration: const Duration(milliseconds: 90),
                    curve: Curves.easeOut,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: _flashColor),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Opacity(
                    opacity: _pulseAnimation.value * 0.22,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.9,
                          colors: [
                            AppColors.gold.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isCompact,
    required this.operation,
    required this.isLocked,
    required this.onOperationSelected,
  });

  final bool isCompact;
  final String operation;
  final bool isLocked;
  final ValueChanged<String>? onOperationSelected;

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
              opacity: isLocked ? 0.4 : 1.0,
              child: _OperationSelector(
                operation: operation,
                compact: isCompact,
                onSelected: onOperationSelected,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: StageDisplay(),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TimerDisplay(),
              ),
            ),
          ),
        ],
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
      itemBuilder: (context) => calcOperationsList
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
