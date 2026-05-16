import 'package:flutter/material.dart';

/// Pequeno indicador visual que pulsa conforme a magnitude do acelerômetro
/// varia, dando feedback de que o sensor está ativo.
class SensorPulseIndicator extends StatelessWidget {
  final double magnitude;

  const SensorPulseIndicator({super.key, required this.magnitude});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = ((magnitude - 5).clamp(0, 15)) / 15;
    final size = 16 + normalized * 24;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'sensor: ${magnitude.toStringAsFixed(2)} m/s²',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
