import 'package:flutter/material.dart';

enum StatusType { healthy, warning, error, info }

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType status;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.status,
    this.icon,
  });

  Color get _color {
    switch (status) {
      case StatusType.healthy:
        return const Color(0xFF10B981);
      case StatusType.warning:
        return const Color(0xFFF59E0B);
      case StatusType.error:
        return const Color(0xFFEF4444);
      case StatusType.info:
        return const Color(0xFF2563EB);
    }
  }

  IconData get _defaultIcon {
    switch (status) {
      case StatusType.healthy:
        return Icons.check_circle_rounded;
      case StatusType.warning:
        return Icons.warning_amber_rounded;
      case StatusType.error:
        return Icons.cancel_rounded;
      case StatusType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: chipColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? _defaultIcon, size: 16, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
