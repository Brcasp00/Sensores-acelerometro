/// Constantes ajustáveis para a detecção de agachamentos.
///
/// O detector observa a magnitude do vetor aceleração `√(x² + y² + z²)`.
/// Em repouso esse valor fica próximo de 9.8 m/s² (gravidade). Durante o
/// agachamento, a fase de descida reduz a magnitude (queda livre parcial) e
/// a fase de subida aumenta (impulso vertical).
class SquatDetectorConfig {
  /// Limite inferior para considerar que o usuário está descendo.
  static const double thresholdDown = 7.5;

  /// Limite superior para considerar que o usuário está subindo.
  static const double thresholdUp = 12.0;

  /// Magnitude próxima da gravidade — usado para detectar estabilização.
  static const double restingMagnitude = 9.8;

  /// Tolerância para considerar a magnitude "em repouso".
  static const double restingTolerance = 1.5;

  /// Duração mínima de uma repetição (filtra ruído / tremor).
  static const Duration minRepDuration = Duration(milliseconds: 600);

  /// Duração máxima de uma repetição (abandona detecção parcial).
  static const Duration maxRepDuration = Duration(milliseconds: 3500);

  /// Janela da média móvel aplicada ao sinal bruto (em amostras).
  static const int smoothingWindow = 5;
}

class StorageKeys {
  static const String lastConfig = 'last_workout_config';
}
