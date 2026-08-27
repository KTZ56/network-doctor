import 'package:flutter/material.dart';

import 'glass_card.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),

          const Spacer(),

          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                'Open',
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, color: color, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
