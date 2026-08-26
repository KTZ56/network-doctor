import 'package:flutter/material.dart';

import 'glass_card.dart';
import 'status_chip.dart';

class HealthScoreCard extends StatelessWidget {
  final int score;
  final String status;
  final String description;

  const HealthScoreCard({
    super.key,
    required this.score,
    required this.status,
    required this.description,
  });

  StatusType get _statusType {
    if (score >= 80) return StatusType.healthy;
    if (score >= 50) return StatusType.warning;
    return StatusType.error;
  }

  Color get _progressColor {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      _progressColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                    ),
                    const Text(
                      'Score',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Internet Health',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),

                const SizedBox(height: 12),

                StatusChip(
                  label: status,
                  status: _statusType,
                ),

                const SizedBox(height: 12),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}