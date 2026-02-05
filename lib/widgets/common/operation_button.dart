import 'package:flutter/material.dart';

/// Reusable Operation Button
class OperationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  const OperationButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: enabled
                  ? color.withAlpha(25)
                  : theme.disabledColor.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled
                    ? color.withAlpha(76)
                    : theme.disabledColor.withAlpha(51),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: enabled ? color : theme.disabledColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: enabled ? color : theme.disabledColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: (enabled ? color : theme.disabledColor).withAlpha(127),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
