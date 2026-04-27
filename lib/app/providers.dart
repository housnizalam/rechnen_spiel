import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/game/domain/game_engine.dart';

final gameEngineProvider = Provider<GameEngine>((ref) => GameEngine());
