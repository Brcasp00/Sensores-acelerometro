class WorkoutConfig {
  final int repsPerSet;
  final int totalSets;

  const WorkoutConfig({
    required this.repsPerSet,
    required this.totalSets,
  });

  int get totalReps => repsPerSet * totalSets;

  WorkoutConfig copyWith({int? repsPerSet, int? totalSets}) {
    return WorkoutConfig(
      repsPerSet: repsPerSet ?? this.repsPerSet,
      totalSets: totalSets ?? this.totalSets,
    );
  }

  Map<String, dynamic> toMap() => {
        'repsPerSet': repsPerSet,
        'totalSets': totalSets,
      };

  factory WorkoutConfig.fromMap(Map<String, dynamic> map) => WorkoutConfig(
        repsPerSet: map['repsPerSet'] as int,
        totalSets: map['totalSets'] as int,
      );

  static const defaultConfig = WorkoutConfig(repsPerSet: 10, totalSets: 3);
}
