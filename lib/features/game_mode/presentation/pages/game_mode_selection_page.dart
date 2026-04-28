import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../game/presentation/pages/game_page.dart';
import '../../../game/state/game_notifier.dart';
import '../../../reverse_game/presentation/pages/reverse_game_page.dart';

class GameModeSelectionPage extends ConsumerWidget {
  const GameModeSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerName = ref.watch(gameNotifierProvider).player?.name ?? 'Player';
    const modes = <_GameModeOption>[
      _GameModeOption(
        title: 'Normal Operation',
        subtitle: 'Play the current arithmetic game mode.',
        icon: Icons.calculate_rounded,
        isEnabled: true,
      ),
      _GameModeOption(
        title: 'Reverse Operation',
        subtitle: 'Given a result, find the expression.',
        icon: Icons.swap_horiz_rounded,
        isEnabled: true,
      ),
      _GameModeOption(
        title: 'Binary to Decimal',
        subtitle: 'Coming soon',
        icon: Icons.memory_rounded,
        isEnabled: false,
      ),
      _GameModeOption(
        title: 'Decimal to Binary',
        subtitle: 'Coming soon',
        icon: Icons.developer_board_rounded,
        isEnabled: false,
      ),
    ];

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: AppDecorations.pageBackground(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Choose Game Mode',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        playerName,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.goldMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 560;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: modes.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isWide ? 2 : 1,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              mainAxisExtent: 138,
                            ),
                            itemBuilder: (context, index) {
                              final mode = modes[index];
                              return _GameModeCard(
                                option: mode,
                                onTap: mode.isEnabled
                                    ? () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => index == 0
                                                ? const GamePage()
                                                : const ReverseGamePage(),
                                          ),
                                        );
                                      }
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameModeOption {
  const _GameModeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isEnabled,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isEnabled;
}

class _GameModeCard extends StatelessWidget {
  const _GameModeCard({
    required this.option,
    required this.onTap,
  });

  final _GameModeOption option;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = option.isEnabled
        ? AppColors.borderGold
        : AppColors.red.withValues(alpha: 0.45);
    final textColor = option.isEnabled ? AppColors.gold : AppColors.goldMuted;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.black,
            AppColors.darkRed,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(option.icon, color: textColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style:
                            AppTextStyles.subtitle.copyWith(color: textColor),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        option.subtitle,
                        style: AppTextStyles.body.copyWith(
                          color: option.isEnabled
                              ? AppColors.goldMuted
                              : AppColors.goldMuted.withValues(alpha: 0.82),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (option.isEnabled)
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.gold,
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.46),
                      ),
                    ),
                    child: Text(
                      'Coming soon',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.goldMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
