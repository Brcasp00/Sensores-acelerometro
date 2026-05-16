import 'package:flutter/foundation.dart';

import '../models/workout_session.dart';
import '../services/session_repository.dart';

class HistoryProvider extends ChangeNotifier {
  final SessionRepository _repository;

  List<WorkoutSession> _sessions = [];
  bool _loading = false;

  HistoryProvider(this._repository);

  List<WorkoutSession> get sessions => _sessions;
  bool get isLoading => _loading;

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    _sessions = await _repository.listSessions();
    _loading = false;
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repository.deleteSession(id);
    await refresh();
  }
}
