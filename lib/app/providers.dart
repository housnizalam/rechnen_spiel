import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/game/domain/game_engine.dart';

/// Provides a singleton-like [GameEngine] instance for the app scope.
final gameEngineProvider = Provider<GameEngine>((ref) => GameEngine());
