import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

/// Encapsula o acesso ao acelerômetro e expõe um stream com a magnitude
/// do vetor aceleração (`√(x² + y² + z²)`).
///
/// Manter esse cálculo aqui (em vez de espalhar pelo detector) facilita
/// substituir a fonte do sinal (ex.: usar giroscópio combinado) sem mexer
/// no resto do app.
class SensorService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  final _controller = StreamController<AccelerometerReading>.broadcast();

  Stream<AccelerometerReading> get readings => _controller.stream;

  void start({
    Duration samplingPeriod = const Duration(milliseconds: 33),
  }) {
    _subscription?.cancel();
    _subscription = accelerometerEventStream(samplingPeriod: samplingPeriod)
        .listen((event) {
      final magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _controller.add(
        AccelerometerReading(
          x: event.x,
          y: event.y,
          z: event.z,
          magnitude: magnitude,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}

class AccelerometerReading {
  final double x;
  final double y;
  final double z;
  final double magnitude;
  final DateTime timestamp;

  const AccelerometerReading({
    required this.x,
    required this.y,
    required this.z,
    required this.magnitude,
    required this.timestamp,
  });
}
