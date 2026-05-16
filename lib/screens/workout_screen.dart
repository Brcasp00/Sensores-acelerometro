import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/workout_config.dart';
import '../providers/workout_provider.dart';
import '../widgets/rep_counter_display.dart';
import '../widgets/sensor_pulse_indicator.dart';
import '../widgets/set_progress_indicator.dart';
import 'summary_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final WorkoutConfig config;
  const WorkoutScreen({super.key, required this.config});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().start(widget.config);
    });
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar treino?'),
        content: const Text(
          'O progresso atual será descartado. Deseja sair mesmo assim?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final provider = context.read<WorkoutProvider>();
        if (provider.status == WorkoutStatus.finished) {
          navigator.pop();
          return;
        }
        final confirmed = await _confirmExit();
        if (!confirmed || !mounted) return;
        provider.cancel();
        navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Treino em andamento'),
          automaticallyImplyLeading: false,
        ),
        body: Consumer<WorkoutProvider>(
          builder: (context, provider, _) {
            final session = provider.session;
            if (session == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.status == WorkoutStatus.finished) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => SummaryScreen(session: session),
                  ),
                );
              });
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Série ${session.currentSet} de ${session.config.totalSets}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SetProgressIndicator(
                    currentSet: session.currentSet,
                    totalSets: session.config.totalSets,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Center(
                      child: provider.status == WorkoutStatus.restingBetweenSets
                          ? _RestView(
                              onReady: provider.startNextSet,
                              nextSet: session.currentSet + 1,
                            )
                          : RepCounterDisplay(
                              current: session.repsInCurrentSet,
                              target: session.config.repsPerSet,
                            ),
                    ),
                  ),
                  SensorPulseIndicator(magnitude: provider.lastMagnitude),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Contar manual'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed:
                              provider.status == WorkoutStatus.running
                                  ? provider.addManualRep
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.stop),
                          label: const Text('Encerrar'),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: () async {
                            await provider.finish();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RestView extends StatelessWidget {
  final int nextSet;
  final VoidCallback onReady;

  const _RestView({required this.nextSet, required this.onReady});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_drink, size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'Descanso',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Quando estiver pronto, inicie a série $nextSet',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: Text('Iniciar série $nextSet'),
          onPressed: onReady,
        ),
      ],
    );
  }
}
