import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/network_provider.dart';

class SpeedTestScreen extends StatelessWidget {
  const SpeedTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();
    final result = provider.speedTestResult;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.speed_rounded),
            SizedBox(width: 10),
            Text('Speed Test'),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Container(
                        width: 56,
                        height: 56,

                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(17),
                        ),

                        child: Icon(
                          Icons.speed_rounded,
                          size: 30,
                          color: colors.onPrimaryContainer,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              'Network Speed Test',

                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Measure your connection latency, download speed, and upload speed.',

                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // TEST CONTROL CARD
                  // ==================================================
                  Card(
                    elevation: 0,

                    color: colors.surfaceContainerHighest,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(24),

                      child: Column(
                        children: [
                          Container(
                            width: 82,
                            height: 82,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              color: colors.primaryContainer,
                            ),

                            child: Icon(
                              Icons.network_check_rounded,
                              size: 42,

                              color: colors.onPrimaryContainer,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            provider.testingSpeed
                                ? 'Testing your connection...'
                                : 'Ready to test your connection',

                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),

                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 6),

                          Text(
                            provider.testingSpeed
                                ? 'Please wait while Network Doctor measures your network performance.'
                                : 'Run a speed test to measure your current network performance.',

                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),

                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: 240,
                            height: 52,

                            child: FilledButton.icon(
                              onPressed: provider.testingSpeed
                                  ? null
                                  : provider.runSpeedTest,

                              icon: provider.testingSpeed
                                  ? const SizedBox(
                                      width: 19,
                                      height: 19,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.play_arrow_rounded),

                              label: Text(
                                provider.testingSpeed
                                    ? 'Testing...'
                                    : 'Start Speed Test',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // LOADING
                  // ==================================================
                  if (provider.testingSpeed)
                    Card(
                      elevation: 0,

                      child: Padding(
                        padding: const EdgeInsets.all(22),

                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              height: 28,

                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colors.primary,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    'Running speed test',

                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Measuring latency, download, and upload performance...',

                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ==================================================
                  // RESULT
                  // ==================================================
                  if (result != null && !provider.testingSpeed)
                    _SpeedResultCard(result: result),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SPEED RESULT CARD
// ============================================================

class _SpeedResultCard extends StatelessWidget {
  final dynamic result;

  const _SpeedResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // RESULT HEADER
            // ==================================================
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: colors.primaryContainer,

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Icon(
                    Icons.analytics_rounded,
                    color: colors.onPrimaryContainer,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Speed Test Results',

                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Your measured network performance',

                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Text(
                    'COMPLETED',

                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Divider(color: colors.outlineVariant),

            const SizedBox(height: 24),

            // ==================================================
            // METRICS
            // ==================================================
            Text(
              'Connection Performance',

              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                if (width < 650) {
                  return Column(
                    children: [
                      _MetricCard(
                        title: 'Latency',
                        value: '${result.latencyMs.toStringAsFixed(1)} ms',
                        icon: Icons.timer_outlined,
                        color: Colors.orange,
                      ),

                      const SizedBox(height: 12),

                      _MetricCard(
                        title: 'Download',
                        value:
                            '${result.downloadSpeedMbps.toStringAsFixed(2)} Mbps',
                        icon: Icons.download_rounded,
                        color: colors.primary,
                      ),

                      const SizedBox(height: 12),

                      _MetricCard(
                        title: 'Upload',
                        value:
                            '${result.uploadSpeedMbps.toStringAsFixed(2)} Mbps',
                        icon: Icons.upload_rounded,
                        color: colors.secondary,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Latency',
                        value: '${result.latencyMs.toStringAsFixed(1)} ms',
                        icon: Icons.timer_outlined,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _MetricCard(
                        title: 'Download',
                        value:
                            '${result.downloadSpeedMbps.toStringAsFixed(2)} Mbps',
                        icon: Icons.download_rounded,
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _MetricCard(
                        title: 'Upload',
                        value:
                            '${result.uploadSpeedMbps.toStringAsFixed(2)} Mbps',
                        icon: Icons.upload_rounded,
                        color: colors.secondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// METRIC CARD
// ============================================================

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(icon, color: color, size: 21),
              ),

              const Spacer(),

              Icon(
                Icons.trending_up_rounded,
                color: color.withValues(alpha: 0.7),
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            title,

            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
