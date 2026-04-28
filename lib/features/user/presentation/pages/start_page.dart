import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../game_mode/presentation/pages/game_mode_selection_page.dart';
import '../../../game/domain/game_models.dart';
import '../../../game/state/game_notifier.dart';
import '../../data/user_storage_service.dart';
import '../../domain/user_profile.dart';
import '../../state/user_providers.dart';
import '../widgets/global_statistics_button.dart';

/// Initial screen where players select an existing profile or create a new one.
///
/// After a player is chosen, [GameNotifier.giveName] is called and the app
/// navigates to [GameModeSelectionPage] using [Navigator.pushReplacement] so
/// the back button cannot return to this screen during a game session.
class StartPage extends ConsumerStatefulWidget {
  const StartPage({super.key});

  @override
  ConsumerState<StartPage> createState() => _StartPageState();
}

class _StartPageState extends ConsumerState<StartPage> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() => _errorText = null));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canStart => _nameController.text.trim().isNotEmpty;

  void _enterGame(UserProfile profile) {
    // Convert UserProfile to Player for currentUserProvider
    final player = Player(
      id: profile.id,
      name: profile.name,
      createdAt: profile.createdAt,
      gameRecords: profile.gameRecords,
    );

    // Set the global current user
    ref.read(currentUserProvider.notifier).state = player;

    // Initialize GameNotifier with player data
    ref.read(gameNotifierProvider.notifier).giveName(
          profile.name,
          userId: profile.id,
          createdAt: profile.createdAt,
          gameRecords: profile.gameRecords,
        );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameModeSelectionPage()),
    );
  }

  Future<void> _startWithNewName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final service = ref.read(userStorageServiceProvider);
    late UserProfile profileToEnter;
    try {
      final profile = UserProfile.create(name);
      await service.save(profile);
      profileToEnter = profile;
      ref.invalidate(savedUsersProvider);
    } on DuplicateNameException {
      profileToEnter = service.findByName(name) ?? UserProfile.create(name);
    }
    if (mounted) _enterGame(profileToEnter);
  }

  Future<void> _showDeleteDialog(UserProfile user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: AppDecorations.dialogDecoration().shape as OutlinedBorder,
        title: const Text(
          'Delete user',
          style: AppTextStyles.subtitle,
        ),
        content: Text(
          'Are you sure you want to delete "${user.name}"?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.goldMuted),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.gold),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final service = ref.read(userStorageServiceProvider);
      await service.deleteById(user.id);
      ref.invalidate(savedUsersProvider);
    }
  }

  Future<void> _showEditDialog(UserProfile user) async {
    final controller = TextEditingController(text: user.name);
    String? dialogError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final canSave = controller.text.trim().isNotEmpty;
          return AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            shape: AppDecorations.dialogDecoration().shape as OutlinedBorder,
            title: const Text(
              'Edit name',
              style: AppTextStyles.subtitle,
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              style: AppTextStyles.body,
              cursorColor: AppColors.gold,
              decoration: AppDecorations.inputDecoration(
                labelText: 'Name',
                errorText: dialogError,
              ),
              onChanged: (_) => setDialogState(() => dialogError = null),
            ),
            actions: [
              TextButton(
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.goldMuted),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.gold),
                onPressed: canSave
                    ? () async {
                        final service = ref.read(userStorageServiceProvider);
                        try {
                          await service.updateName(
                              user.id, controller.text.trim());
                          if (mounted) ref.invalidate(savedUsersProvider);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        } on DuplicateNameException catch (e) {
                          setDialogState(() => dialogError = e.message);
                        }
                      }
                    : null,
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedUsersAsync = ref.watch(savedUsersProvider);

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: AppDecorations.pageBackground(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: savedUsersAsync.when(
                loading: () =>
                    const CircularProgressIndicator(color: AppColors.gold),
                error: (_, __) => _buildForm(savedUsers: const []),
                data: (savedUsers) => _buildForm(savedUsers: savedUsers),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm({required List<UserProfile> savedUsers}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Global Stats',
                  style: AppTextStyles.subtitle,
                ),
              ),
              GlobalStatisticsButton(savedUsers: savedUsers),
            ],
          ),
          const SizedBox(height: 8),
          if (savedUsers.isNotEmpty) ...[
            const Text(
              'Choose a player',
              style: AppTextStyles.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...savedUsers.map(
              (user) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: AppDecorations.buttonDecoration(),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: AppColors.gold,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: AppTextStyles.button,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _enterGame(user),
                          child: Text(user.name),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit, color: AppColors.gold),
                      onPressed: () => _showEditDialog(user),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete, color: AppColors.gold),
                      onPressed: () => _showDeleteDialog(user),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Divider(color: AppColors.borderRed, thickness: 1),
            const SizedBox(height: 16),
            const Text(
              'Create a new Player',
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _nameController,
            style: AppTextStyles.title.copyWith(fontSize: 28),
            cursorColor: AppColors.gold,
            decoration: AppDecorations.inputDecoration(
              labelText: 'Enter your name',
              errorText: _errorText,
            ),
            onSubmitted: (_) => _canStart ? _startWithNewName() : null,
          ),
          const SizedBox(height: 24),
          Container(
            decoration: AppDecorations.buttonDecoration(),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: AppColors.gold,
                disabledForegroundColor: AppColors.goldMuted,
                disabledBackgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: AppTextStyles.button.copyWith(fontSize: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _canStart ? _startWithNewName : null,
              child: const Text('Start'),
            ),
          ),
        ],
      ),
    );
  }
}
