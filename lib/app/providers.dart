import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/audio_feedback_service.dart';
import '../features/game/domain/game_engine.dart';

/// Provides a singleton-like [GameEngine] instance for the app scope.
final gameEngineProvider = Provider<GameEngine>((ref) => GameEngine());

/// Provides app-wide short audio feedback effects.
final audioFeedbackServiceProvider = Provider<AudioFeedbackService>((ref) {
  final service = AudioFeedbackService();
  ref.onDispose(service.dispose);
  return service;
});
