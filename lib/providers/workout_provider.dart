import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/squat_event.dart';
import '../models/workout_config.dart';
import '../models/workout_session.dart';
import '../services/feedback_service.dart';
import '../services/sensor_service.dart';
import '../services/session_repository.dart';
import '../services/squat_detector.dart';

enum WorkoutStatus { idle, running, restingBetweenSets, finished }

class WorkoutProvider extends ChangeNotifier {
  final SensorService _sensorService;
  final FeedbackService _feedback;
  final SessionRepository _repository;

  late SquatDetector _detector;
  StreamSubscription<AccelerometerReading>? _readingSub;

  WorkoutSession? _session;
  WorkoutStatus _status = WorkoutStatus.idle;
  double _lastMagnitude = 9.8;
  int? _savedSessionId;

  WorkoutProvider({
    required SensorService sensorService,
    required FeedbackService feedback,
    required SessionRepository repository,
  })  : _sensorService = sensorService,
        _feedback = feedback,
        _repository = repository {
    _detector = SquatDetector(onSquatDetected: _handleSquat);
  }

  WorkoutSession? get session => _session;
  WorkoutStatus get status => _status;
  double get lastMagnitude => _lastMagnitude;
  int? get savedSessionId => _savedSessionId;

  int get currentSet => _session?.currentSet ?? 0;
  int get repsInCurrentSet => _session?.repsInCurrentSet ?? 0;
  int get totalRepsDone => _session?.totalRepsDone ?? 0;

  void start(WorkoutConfig config) {
    _detector.reset();
    _session = WorkoutSession(
      config: config,
      startedAt: DateTime.now(),
    );
    _status = WorkoutStatus.running;
    _savedSessionId = null;
    _sensorService.start();
    _readingSub?.cancel();
    _readingSub = _sensorService.readings.listen((reading) {
      _lastMagnitude = reading.magnitude;
      if (_status == WorkoutStatus.running) {
        _detector.onReading(reading);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  /// Avança para a próxima série após o descanso.
  void startNextSet() {
    final s = _session;
    if (s == null) return;
    if (s.currentSet >= s.config.totalSets) return;
    _session = s.copyWith(
      currentSet: s.currentSet + 1,
      repsInCurrentSet: 0,
    );
    _detector.reset();
    _status = WorkoutStatus.running;
    notifyListeners();
  }

  Future<void> finish() async {
    final s = _session;
    if (s == null) return;
    _readingSub?.cancel();
    _readingSub = null;
    _sensorService.stop();
    _session = s.copyWith(finishedAt: DateTime.now());
    _status = WorkoutStatus.finished;
    await _feedback.workoutFinished();
    notifyListeners();
    final finished = _session;
    if (finished != null) {
      _savedSessionId = await _repository.insertSession(finished);
    }
  }

  /// Adiciona uma rep manualmente — útil quando o detector falha.
  void addManualRep() {
    _handleSquat(DetectedSquat(
      timestamp: DateTime.now(),
      duration: const Duration(milliseconds: 1500),
    ));
  }

  void cancel() {
    _readingSub?.cancel();
    _readingSub = null;
    _sensorService.stop();
    _session = null;
    _status = WorkoutStatus.idle;
    notifyListeners();
  }

  void _handleSquat(DetectedSquat squat) {
    final s = _session;
    if (s == null) return;
    if (_status != WorkoutStatus.running) return;

    final newEvent = SquatEvent(
      timestamp: squat.timestamp,
      duration: squat.duration,
      setNumber: s.currentSet,
    );
    final updatedReps = s.repsInCurrentSet + 1;
    _session = s.copyWith(
      repsInCurrentSet: updatedReps,
      events: [...s.events, newEvent],
    );

    _feedback.repCounted();

    final completedSet = updatedReps >= s.config.repsPerSet;
    if (completedSet) {
      final wasLastSet = s.currentSet >= s.config.totalSets;
      if (wasLastSet) {
        notifyListeners();
        finish();
        return;
      } else {
        _status = WorkoutStatus.restingBetweenSets;
        _feedback.setCompleted();
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _readingSub?.cancel();
    _sensorService.stop();
    super.dispose();
  }
}
