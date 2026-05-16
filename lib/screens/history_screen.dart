import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/workout_session.dart';
import '../providers/history_provider.dart';
import 'summary_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de treinos')),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.sessions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhum treino registrado ainda.\nFinalize um treino para ver o histórico aqui.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.sessions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = provider.sessions[i];
                return _SessionTile(
                  session: s,
                  formattedDate: dateFmt.format(s.startedAt),
                  onDelete: () async {
                    final id = s.id;
                    if (id == null) return;
                    await provider.delete(id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final WorkoutSession session;
  final String formattedDate;
  final Future<void> Function() onDelete;

  const _SessionTile({
    required this.session,
    required this.formattedDate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adherencePct = (session.adherence * 100).toStringAsFixed(0);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            '$adherencePct%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(formattedDate),
        subtitle: Text(
          '${session.totalRepsDone}/${session.config.totalReps} reps · '
          '${session.config.totalSets} séries',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  SummaryScreen(session: session, fromHistory: true),
            ),
          );
        },
      ),
    );
  }
}
