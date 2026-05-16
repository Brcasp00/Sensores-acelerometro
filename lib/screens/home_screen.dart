import 'package:flutter/material.dart';

import 'config_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Squat Counter')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.fitness_center,
              size: 96,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Conte seus agachamentos\ncom o acelerômetro do celular',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Configurar treino'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ConfigScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Histórico de treinos'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            const Spacer(),
            Text(
              'Coloque o celular no bolso da calça\ndurante o treino para melhor detecção.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
