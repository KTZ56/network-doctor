import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/network_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_chip.dart';

class TrafficMonitorScreen extends StatelessWidget {
  const TrafficMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();
    final stats = provider.trafficStats;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.monitor_heart_rounded),
            SizedBox(width: 10),
            Text('Traffic Monitor'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _Header(),

                  const SizedBox(height: 28),

                  _MonitorControl(
                    provider: provider,
                  ),

                  const SizedBox(height: 24),

                  if (stats == null &&
                      !provider.monitoringTraffic)
                    const _EmptyState(),

                  if (stats != null) ...[
                    _LiveTrafficOverview(
                      provider: provider,
                    ),

                    const SizedBox(height: 20),

                    _TrafficChart(
                      download:
                          provider.downloadHistory,
                      upload:
                          provider.uploadHistory,
                    ),

                    const SizedBox(height: 20),

                    _TrafficTotals(
                      stats: stats,
                    ),
                  ],
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
// HEADER
// ============================================================

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                colors.primary,
                colors.secondary,
              ],
            ),
          ),
          child: Icon(
            Icons.monitor_heart_rounded,
            color: colors.onPrimary,
            size: 30,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Network Traffic',
                style: theme
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 5),

              Text(
                'Monitor real-time bandwidth usage on your active network interface.',
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// CONTROL
// ============================================================

class _MonitorControl
    extends StatelessWidget {
  final NetworkProvider provider;

  const _MonitorControl({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final interfaceName =
        provider.networkInfo?.interfaceName ??
            'Unknown';

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  colors.primary.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              provider.monitoringTraffic
                  ? Icons.wifi_tethering_rounded
                  : Icons.network_check_rounded,
              color: colors.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  provider.monitoringTraffic
                      ? 'Monitoring Traffic'
                      : 'Traffic Monitor',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Interface: $interfaceName',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                    color:
                        colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          StatusChip(
            label: provider.monitoringTraffic
                ? 'LIVE'
                : 'STOPPED',
            status: provider.monitoringTraffic
                ? StatusType.healthy
                : StatusType.warning,
          ),

          const SizedBox(width: 12),

          FilledButton.icon(
            onPressed: provider.monitoringTraffic
                ? provider.stopTrafficMonitoring
                : provider.startTrafficMonitoring,
            icon: Icon(
              provider.monitoringTraffic
                  ? Icons.stop_rounded
                  : Icons.play_arrow_rounded,
            ),
            label: Text(
              provider.monitoringTraffic
                  ? 'Stop'
                  : 'Start',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LIVE TRAFFIC
// ============================================================

class _LiveTrafficOverview
    extends StatelessWidget {
  final NetworkProvider provider;

  const _LiveTrafficOverview({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final stats = provider.trafficStats!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 800 ? 2 : 1;

        final spacing = 16.0;

        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth -
                    spacing) /
                2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: width,
              child: _TrafficMetric(
                title: 'Download',
                value:
                    '${stats.downloadMbps.toStringAsFixed(2)} Mbps',
                icon:
                    Icons.arrow_downward_rounded,
                color: Colors.blue,
              ),
            ),

            SizedBox(
              width: width,
              child: _TrafficMetric(
                title: 'Upload',
                value:
                    '${stats.uploadMbps.toStringAsFixed(2)} Mbps',
                icon:
                    Icons.arrow_upward_rounded,
                color: Colors.teal,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// TRAFFIC METRIC
// ============================================================

class _TrafficMetric
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _TrafficMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color:
                  color.withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: theme.textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHART
// ============================================================

class _TrafficChart extends StatelessWidget {
  final List<double> download;
  final List<double> upload;

  const _TrafficChart({
    required this.download,
    required this.upload,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: colors.primary,
              ),

              const SizedBox(width: 10),

              Text(
                'Traffic Over Time',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
              ),

              const Spacer(),

              const _Legend(
                label: 'Download',
                color: Colors.blue,
              ),

              const SizedBox(width: 14),

              const _Legend(
                label: 'Upload',
                color: Colors.teal,
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 260,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrafficChartPainter(
                download: download,
                upload: upload,
                downloadColor:
                    Colors.blue,
                uploadColor:
                    Colors.teal,
                gridColor:
                    colors.outlineVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LEGEND
// ============================================================

class _Legend extends StatelessWidget {
  final String label;
  final Color color;

  const _Legend({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }
}

// ============================================================
// CHART PAINTER
// ============================================================

class _TrafficChartPainter
    extends CustomPainter {
  final List<double> download;
  final List<double> upload;

  final Color downloadColor;
  final Color uploadColor;
  final Color gridColor;

  const _TrafficChartPainter({
    required this.download,
    required this.upload,
    required this.downloadColor,
    required this.uploadColor,
    required this.gridColor,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final chartWidth = size.width;
    final chartHeight = size.height;

    final padding = 20.0;

    final rect = Rect.fromLTWH(
      padding,
      padding,
      chartWidth - padding * 2,
      chartHeight - padding * 2,
    );

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = rect.top +
          (rect.height / 5) * i;

      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        gridPaint,
      );
    }

    final values = [
      ...download,
      ...upload,
    ];

    if (values.isEmpty) {
      return;
    }

    final maxValue =
        values.reduce(
          (a, b) => a > b ? a : b,
        );

    final safeMax =
        maxValue <= 0 ? 1.0 : maxValue;

    _drawLine(
      canvas,
      rect,
      download,
      safeMax,
      downloadColor,
    );

    _drawLine(
      canvas,
      rect,
      upload,
      safeMax,
      uploadColor,
    );
  }

  void _drawLine(
    Canvas canvas,
    Rect rect,
    List<double> values,
    double maxValue,
    Color color,
  ) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (int i = 0;
        i < values.length;
        i++) {
      final x = values.length == 1
          ? rect.left
          : rect.left +
              (i /
                      (values.length - 1)) *
                  rect.width;

      final normalized =
          values[i] / maxValue;

      final y = rect.bottom -
          normalized * rect.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _TrafficChartPainter oldDelegate,
  ) {
    return oldDelegate.download !=
            download ||
        oldDelegate.upload != upload;
  }
}

// ============================================================
// TOTALS
// ============================================================

class _TrafficTotals extends StatelessWidget {
  final dynamic stats;

  const _TrafficTotals({
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 800 ? 2 : 1;

        final spacing = 16.0;

        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth -
                    spacing) /
                2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: width,
              child: _TotalCard(
                title: 'Total Received',
                value: _formatBytes(
                  stats.receivedBytes,
                ),
                icon:
                    Icons.download_done_rounded,
              ),
            ),

            SizedBox(
              width: width,
              child: _TotalCard(
                title: 'Total Sent',
                value: _formatBytes(
                  stats.sentBytes,
                ),
                icon:
                    Icons.upload_rounded,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatBytes(
    int bytes,
  ) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }

    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }

    return '$bytes B';
  }
}

// ============================================================
// TOTAL CARD
// ============================================================

class _TotalCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _TotalCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.primary
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: colors.primary,
            ),
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(42),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary
                      .withValues(alpha: 0.10),
                ),
                child: Icon(
                  Icons.monitor_heart_rounded,
                  size: 38,
                  color: colors.primary,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Traffic Monitoring Ready',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 7),

              Text(
                'Start monitoring to see real-time bandwidth usage.',
                textAlign:
                    TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(height: 8),

              Text(
                'No network traffic is generated by this monitor.',
                textAlign:
                    TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}