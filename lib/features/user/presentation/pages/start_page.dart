import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../game/presentation/pages/game_page.dart';
import '../../../game/state/game_notifier.dart';
import '../../data/user_storage_service.dart';
import '../../domain/user_profile.dart';
import '../../state/user_providers.dart';

/// Initial screen where players select an existing profile or create a new one.
///
/// After a player is chosen, [GameNotifier.giveName] is called and the app
/// navigates to [GamePage] using [Navigator.pushReplacement] so the back
/// button cannot return to this screen during a game session.
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

  void _enterGame(String name) {
    ref.read(gameNotifierProvider.notifier).giveName(name);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GamePage()),
    );
  }

  Future<void> _startWithNewName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final service = ref.read(userStorageServiceProvider);
    try {
      final profile = UserProfile.create(name);
      await service.save(profile);
      ref.invalidate(savedUsersProvider);
    } on DuplicateNameException {
      // Name already exists — enter the game with it anyway.
    }
    if (mounted) _enterGame(name);
  }

  Future<void> _showDeleteDialog(UserProfile user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete user'),
        content: Text('Are you sure you want to delete "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
            title: const Text('Edit name'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: dialogError,
              ),
              onChanged: (_) => setDialogState(() => dialogError = null),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.red,
              Color.fromARGB(255, 105, 5, 5),
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Color.fromARGB(255, 105, 5, 5),
              Color.fromARGB(255, 105, 5, 5),
              Colors.red,
              Colors.red,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: savedUsersAsync.when(
                loading: () =>
                    const CircularProgressIndicator(color: Colors.red),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (savedUsers.isNotEmpty) ...[
          const Text(
            'Choose a player',
            style: TextStyle(
              color: Colors.red,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...savedUsers.map(
            (user) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _enterGame(user.name),
                      child: Text(user.name),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit, color: Colors.red),
                    onPressed: () => _showEditDialog(user),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(user),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Divider(color: Colors.red, thickness: 1),
          const SizedBox(height: 16),
          const Text(
            'Create a new Player',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _nameController,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            labelText: 'Enter your name',
            labelStyle: const TextStyle(
              color: Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            errorText: _errorText,
          ),
          onSubmitted: (_) => _canStart ? _startWithNewName() : null,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.red.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _canStart ? _startWithNewName : null,
          child: const Text('Start'),
        ),
      ],
    );
  }
}
