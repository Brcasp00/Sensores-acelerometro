import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/config_provider.dart';
import 'workout_screen.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar treino')),
      body: Consumer<ConfigProvider>(
        builder: (context, provider, _) {
          if (!provider.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final config = provider.config;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Repetições por série',
                  style: theme.textTheme.titleMedium,
                ),
                _Stepper(
                  value: config.repsPerSet,
                  min: 1,
                  max: 100,
                  onChanged: provider.setRepsPerSet,
                ),
                const SizedBox(height: 24),
                Text(
                  'Quantidade de séries',
                  style: theme.textTheme.titleMedium,
                ),
                _Stepper(
                  value: config.totalSets,
                  min: 1,
                  max: 20,
                  onChanged: provider.setTotalSets,
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total de repetições',
                            style: theme.textTheme.titleMedium),
                        Text(
                          '${config.totalReps}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar treino'),
                  onPressed: () async {
                    await provider.persist();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            WorkoutScreen(config: provider.config),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          iconSize: 36,
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 96,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton.filledTonal(
          iconSize: 36,
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
