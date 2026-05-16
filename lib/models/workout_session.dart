import 'dart:convert';

import 'squat_event.dart';
import 'workout_config.dart';

class WorkoutSession {
  final int? id;
  final WorkoutConfig config;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int currentSet;
  final int repsInCurrentSet;
  final List<SquatEvent> events;

  const WorkoutSession({
    this.id,
    required this.config,
    required this.startedAt,
    this.finishedAt,
    this.currentSet = 1,
    this.repsInCurrentSet = 0,
    this.events = const [],
  });

  int get totalRepsDone => events.length;

  int get completedSets {
    if (events.isEmpty) return 0;
    final lastEvent = events.last;
    final fullyCompleted = lastEvent.setNumber - 1;
    if (repsInCurrentSet >= config.repsPerSet) {
      return lastEvent.setNumber;
    }
    return fullyCompleted;
  }

  bool get isFinished => finishedAt != null;

  Duration get totalDuration =>
      (finishedAt ?? DateTime.now()).difference(startedAt);

  double get adherence {
    if (config.totalReps == 0) return 0;
    return (totalRepsDone / config.totalReps).clamp(0.0, 1.0);
  }

  Duration get averageRepDuration {
    if (events.isEmpty) return Duration.zero;
    final totalMs =
        events.fold<int>(0, (sum, e) => sum + e.duration.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ events.length);
  }

  /// Tempo médio de descanso entre séries (entre a última rep de uma série
  /// e a primeira rep da série seguinte).
  Duration get averageRestBetweenSets {
    final restPeriods = <int>[];
    for (var set = 1; set < config.totalSets; set++) {
      final lastOfSet = events.where((e) => e.setNumber == set).lastOrNull;
      final firstOfNext =
          events.where((e) => e.setNumber == set + 1).firstOrNull;
      if (lastOfSet != null && firstOfNext != null) {
        restPeriods.add(
          firstOfNext.timestamp.difference(lastOfSet.timestamp).inMilliseconds -
              firstOfNext.duration.inMilliseconds,
        );
      }
    }
    if (restPeriods.isEmpty) return Duration.zero;
    final avg = restPeriods.reduce((a, b) => a + b) ~/ restPeriods.length;
    return Duration(milliseconds: avg.clamp(0, 1 << 31));
  }

  List<int> repsPerSetList() {
    final list = List<int>.filled(config.totalSets, 0);
    for (final e in events) {
      if (e.setNumber >= 1 && e.setNumber <= config.totalSets) {
        list[e.setNumber - 1]++;
      }
    }
    return list;
  }

  WorkoutSession copyWith({
    int? id,
    WorkoutConfig? config,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? currentSet,
    int? repsInCurrentSet,
    List<SquatEvent>? events,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      config: config ?? this.config,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      currentSet: currentSet ?? this.currentSet,
      repsInCurrentSet: repsInCurrentSet ?? this.repsInCurrentSet,
      events: events ?? this.events,
    );
  }

  Map<String, dynamic> toDbMap() => {
        if (id != null) 'id': id,
        'config': jsonEncode(config.toMap()),
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt?.toIso8601String(),
        'events': jsonEncode(events.map((e) => e.toMap()).toList()),
        'totalReps': totalRepsDone,
        'totalDurationMs': totalDuration.inMilliseconds,
      };

  factory WorkoutSession.fromDbMap(Map<String, dynamic> map) {
    final config =
        WorkoutConfig.fromMap(jsonDecode(map['config'] as String) as Map<String, dynamic>);
    final eventsRaw = jsonDecode(map['events'] as String) as List<dynamic>;
    final events = eventsRaw
        .map((e) => SquatEvent.fromMap(e as Map<String, dynamic>))
        .toList();
    return WorkoutSession(
      id: map['id'] as int?,
      config: config,
      startedAt: DateTime.parse(map['startedAt'] as String),
      finishedAt: map['finishedAt'] != null
          ? DateTime.parse(map['finishedAt'] as String)
          : null,
      events: events,
      currentSet: config.totalSets,
      repsInCurrentSet:
          events.where((e) => e.setNumber == config.totalSets).length,
    );
  }
}

extension _ListExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}
