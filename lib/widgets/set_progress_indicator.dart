import 'package:flutter/material.dart';

class SetProgressIndicator extends StatelessWidget {
  final int currentSet;
  final int totalSets;

  const SetProgressIndicator({
    super.key,
    required this.currentSet,
    required this.totalSets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(totalSets, (i) {
        final setNumber = i + 1;
        final isDone = setNumber < currentSet;
        final isCurrent = setNumber == currentSet;
        Color color;
        if (isDone) {
          color = theme.colorScheme.primary;
        } else if (isCurrent) {
          color = theme.colorScheme.primaryContainer;
        } else {
          color = theme.colorScheme.surfaceContainerHighest;
        }
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$setNumber',
            style: TextStyle(
              color: isDone
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }
}
