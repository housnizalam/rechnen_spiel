import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioFeedbackService {
  AudioFeedbackService()
      : _player = AudioPlayer(playerId: 'game-feedback-audio') {
    _player.setPlayerMode(PlayerMode.lowLatency);
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setVolume(1.0);
  }

  final AudioPlayer _player;

  Future<void> playCorrect() => _playAsset('sounds/correct.mp3');

  Future<void> playWrong() => _playAsset('sounds/wrong.mp3');

  Future<void> playStageSuccess() => _playAsset('sounds/stage_success.mp3');

  Future<void> playNewRecord() => _playAsset('sounds/new_record.mp3');

  Future<void> playLoss() => _playAsset('sounds/loss.mp3');

  Future<void> _playAsset(String assetPath) async {
    try {
      if (kDebugMode) {
        debugPrint('[AudioFeedbackService] play request: $assetPath');
      }

      // Stop previous short SFX first so rapid answers stay clean.
      await _player.stop();
      await _player.play(AssetSource(assetPath));

      if (kDebugMode) {
        debugPrint('[AudioFeedbackService] play success: $assetPath');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[AudioFeedbackService] play failed: $assetPath error=$error',
        );
        debugPrint(stackTrace.toString());
      }
      // Audio failures should never block gameplay.
    }
  }

  Future<void> dispose() => _player.dispose();
}
