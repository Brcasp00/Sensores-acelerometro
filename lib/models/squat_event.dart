class SquatEvent {
  final DateTime timestamp;
  final Duration duration;
  final int setNumber;

  const SquatEvent({
    required this.timestamp,
    required this.duration,
    required this.setNumber,
  });

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp.toIso8601String(),
        'durationMs': duration.inMilliseconds,
        'setNumber': setNumber,
      };

  factory SquatEvent.fromMap(Map<String, dynamic> map) => SquatEvent(
        timestamp: DateTime.parse(map['timestamp'] as String),
        duration: Duration(milliseconds: map['durationMs'] as int),
        setNumber: map['setNumber'] as int,
      );
}
