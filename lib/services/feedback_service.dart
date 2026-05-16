import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

/// Fornece feedback tátil e sonoro a cada repetição contada.
/// Falhas são silenciadas: se o dispositivo não tem vibração ou áudio,
/// o app continua funcionando normalmente.
class FeedbackService {
  final AudioPlayer _player = AudioPlayer(playerId: 'rep_beep');
  bool _hasVibrator = false;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _hasVibrator = await Vibration.hasVibrator();
    } catch (_) {
      _hasVibrator = false;
    }
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> repCounted() async {
    if (_hasVibrator) {
      try {
        await Vibration.vibrate(duration: 80);
      } catch (_) {/* ignore */}
    }
    try {
      // Som curto gerado a partir de uma URL de tom embutido na própria lib
      // do AudioPlayer não existe; usamos um tick simples via system_sound.
      // Como fallback portátil, disparamos um beep curto via AssetSource se
      // o asset existir. Em caso de erro, ignoramos silenciosamente.
      await _player.play(AssetSource('sounds/beep.mp3'), volume: 0.6);
    } catch (_) {/* sem asset de som disponível — ok */}
  }

  Future<void> setCompleted() async {
    if (_hasVibrator) {
      try {
        await Vibration.vibrate(pattern: [0, 120, 80, 120]);
      } catch (_) {/* ignore */}
    }
  }

  Future<void> workoutFinished() async {
    if (_hasVibrator) {
      try {
        await Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 400]);
      } catch (_) {/* ignore */}
    }
  }

  void dispose() {
    _player.dispose();
  }
}
