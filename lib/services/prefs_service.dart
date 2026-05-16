import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/workout_config.dart';

class PrefsService {
  Future<WorkoutConfig> loadLastConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.lastConfig);
    if (raw == null) return WorkoutConfig.defaultConfig;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return WorkoutConfig.fromMap(map);
    } catch (_) {
      return WorkoutConfig.defaultConfig;
    }
  }

  Future<void> saveLastConfig(WorkoutConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.lastConfig, jsonEncode(config.toMap()));
  }
}
