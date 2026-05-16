import 'package:flutter/foundation.dart';

import '../models/workout_config.dart';
import '../services/prefs_service.dart';

class ConfigProvider extends ChangeNotifier {
  final PrefsService _prefs;

  WorkoutConfig _config = WorkoutConfig.defaultConfig;
  bool _loaded = false;

  ConfigProvider(this._prefs);

  WorkoutConfig get config => _config;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    _config = await _prefs.loadLastConfig();
    _loaded = true;
    notifyListeners();
  }

  void setRepsPerSet(int reps) {
    if (reps < 1) return;
    _config = _config.copyWith(repsPerSet: reps);
    notifyListeners();
  }

  void setTotalSets(int sets) {
    if (sets < 1) return;
    _config = _config.copyWith(totalSets: sets);
    notifyListeners();
  }

  Future<void> persist() async {
    await _prefs.saveLastConfig(_config);
  }
}
