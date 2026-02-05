import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Widget to display time and space complexity
class ComplexityDisplay extends StatelessWidget {
  final String operation;
  final String dsType;

  const ComplexityDisplay({
    super.key,
    required this.operation,
    required this.dsType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeComplexity = AppConstants.timeComplexity[operation] ?? 'O(?)';
    final spaceComplexity = AppConstants.spaceComplexity[dsType] ?? 'O(?)';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complexity',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          _buildComplexityRow(
            context,
            'Time',
            timeComplexity,
            Icons.timer_outlined,
            AppConstants.secondaryColor,
          ),
          const SizedBox(height: 6),
          _buildComplexityRow(
            context,
            'Space',
            spaceComplexity,
            Icons.memory,
            AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildComplexityRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text('$label:', style: theme.textTheme.bodySmall),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
