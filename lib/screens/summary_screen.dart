import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/workout_session.dart';

class SummaryScreen extends StatelessWidget {
  final WorkoutSession session;
  final bool fromHistory;

  const SummaryScreen({
    super.key,
    required this.session,
    this.fromHistory = false,
  });

  String _fmtDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m == 0) return '${s}s';
    return '${m}min ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = session.config;
    final repsPerSetList = session.repsPerSetList();
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(fromHistory ? 'Detalhes da sessão' : 'Resumo do treino'),
        leading: fromHistory
            ? null
            : IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Treino finalizado!',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFmt.format(session.startedAt),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _StatsGrid(
              items: [
                _StatItem(
                  icon: Icons.repeat,
                  label: 'Repetições',
                  value: '${session.totalRepsDone}/${config.totalReps}',
                ),
                _StatItem(
                  icon: Icons.layers,
                  label: 'Séries completas',
                  value:
                      '${session.completedSets}/${config.totalSets}',
                ),
                _StatItem(
                  icon: Icons.timer,
                  label: 'Duração total',
                  value: _fmtDuration(session.totalDuration),
                ),
                _StatItem(
                  icon: Icons.speed,
                  label: 'Tempo médio/rep',
                  value: _fmtDuration(session.averageRepDuration),
                ),
                _StatItem(
                  icon: Icons.local_drink,
                  label: 'Descanso médio',
                  value: _fmtDuration(session.averageRestBetweenSets),
                ),
                _StatItem(
                  icon: Icons.percent,
                  label: 'Aderência',
                  value: '${(session.adherence * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Repetições por série', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _RepsBarChart(
                repsPerSet: repsPerSetList,
                target: config.repsPerSet,
              ),
            ),
            const SizedBox(height: 24),
            if (!fromHistory)
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Voltar ao início'),
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _StatsGrid extends StatelessWidget {
  final List<_StatItem> items;
  const _StatsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: items.map((item) => _StatCard(item: item)).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              item.value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              item.label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RepsBarChart extends StatelessWidget {
  final List<int> repsPerSet;
  final int target;

  const _RepsBarChart({required this.repsPerSet, required this.target});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = (target * 1.2).clamp(target.toDouble(), double.infinity);
    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (target / 2).clamp(1, double.infinity),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('S${i + 1}',
                      style: theme.textTheme.bodySmall),
                );
              },
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: target.toDouble(),
              color: theme.colorScheme.tertiary,
              strokeWidth: 1.5,
              dashArray: [6, 4],
            ),
          ],
        ),
        barGroups: List.generate(repsPerSet.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: repsPerSet[i].toDouble(),
                color: theme.colorScheme.primary,
                width: 22,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}
