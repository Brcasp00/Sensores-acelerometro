import 'package:flutter_test/flutter_test.dart';

import 'package:squat_counter/models/squat_event.dart';
import 'package:squat_counter/models/workout_config.dart';
import 'package:squat_counter/models/workout_session.dart';

void main() {
  test('WorkoutConfig calcula totalReps corretamente', () {
    const config = WorkoutConfig(repsPerSet: 10, totalSets: 3);
    expect(config.totalReps, 30);
  });

  test('WorkoutConfig serializa e deserializa', () {
    const config = WorkoutConfig(repsPerSet: 12, totalSets: 4);
    final restored = WorkoutConfig.fromMap(config.toMap());
    expect(restored.repsPerSet, 12);
    expect(restored.totalSets, 4);
  });

  test('WorkoutSession calcula aderência e reps por série', () {
    final session = WorkoutSession(
      config: const WorkoutConfig(repsPerSet: 10, totalSets: 2),
      startedAt: DateTime(2026, 1, 1),
      events: List.generate(
        15,
        (i) => SquatEvent(
          timestamp: DateTime(2026, 1, 1).add(Duration(seconds: i)),
          duration: const Duration(milliseconds: 1500),
          setNumber: i < 10 ? 1 : 2,
        ),
      ),
    );
    expect(session.totalRepsDone, 15);
    expect(session.adherence, closeTo(0.75, 0.001));
    expect(session.repsPerSetList(), [10, 5]);
  });
}
