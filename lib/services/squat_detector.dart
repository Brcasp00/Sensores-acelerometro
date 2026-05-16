import 'dart:collection';

import '../core/constants.dart';
import 'sensor_service.dart';

enum _Phase { idle, descending, bottom, ascending }

class DetectedSquat {
  final DateTime timestamp;
  final Duration duration;
  const DetectedSquat({required this.timestamp, required this.duration});
}

/// Máquina de estados que transforma leituras filtradas do acelerômetro
/// em eventos de agachamento.
///
/// Fluxo: IDLE → DESCENDING (magnitude cai abaixo de [thresholdDown]) →
/// BOTTOM (magnitude estabiliza perto da gravidade) →
/// ASCENDING (magnitude sobe acima de [thresholdUp]) → conta a rep e volta IDLE.
class SquatDetector {
  final void Function(DetectedSquat) onSquatDetected;

  _Phase _phase = _Phase.idle;
  DateTime? _phaseStartedAt;
  final Queue<double> _window = Queue<double>();

  SquatDetector({required this.onSquatDetected});

  void reset() {
    _phase = _Phase.idle;
    _phaseStartedAt = null;
    _window.clear();
  }

  void onReading(AccelerometerReading reading) {
    final smoothed = _smooth(reading.magnitude);
    final now = reading.timestamp;

    switch (_phase) {
      case _Phase.idle:
        if (smoothed < SquatDetectorConfig.thresholdDown) {
          _phase = _Phase.descending;
          _phaseStartedAt = now;
        }
        break;

      case _Phase.descending:
        if (_isResting(smoothed)) {
          _phase = _Phase.bottom;
        } else if (_timedOut(now)) {
          reset();
        }
        break;

      case _Phase.bottom:
        if (smoothed > SquatDetectorConfig.thresholdUp) {
          _phase = _Phase.ascending;
        } else if (_timedOut(now)) {
          reset();
        }
        break;

      case _Phase.ascending:
        if (_isResting(smoothed)) {
          final start = _phaseStartedAt;
          if (start != null) {
            final duration = now.difference(start);
            if (duration >= SquatDetectorConfig.minRepDuration) {
              onSquatDetected(
                DetectedSquat(timestamp: now, duration: duration),
              );
            }
          }
          reset();
        } else if (_timedOut(now)) {
          reset();
        }
        break;
    }
  }

  double _smooth(double value) {
    _window.add(value);
    if (_window.length > SquatDetectorConfig.smoothingWindow) {
      _window.removeFirst();
    }
    final sum = _window.fold<double>(0, (a, b) => a + b);
    return sum / _window.length;
  }

  bool _isResting(double magnitude) {
    return (magnitude - SquatDetectorConfig.restingMagnitude).abs() <
        SquatDetectorConfig.restingTolerance;
  }

  bool _timedOut(DateTime now) {
    final start = _phaseStartedAt;
    if (start == null) return false;
    return now.difference(start) > SquatDetectorConfig.maxRepDuration;
  }
}
