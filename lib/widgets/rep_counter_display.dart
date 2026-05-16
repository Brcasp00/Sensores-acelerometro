import 'package:flutter/material.dart';

class RepCounterDisplay extends StatelessWidget {
  final int current;
  final int target;

  const RepCounterDisplay({
    super.key,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$current',
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 140,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          'de $target repetições',
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
