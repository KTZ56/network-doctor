import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/traceroute_result.dart';
import '../../providers/network_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_chip.dart';

class TracerouteScreen extends StatefulWidget {
  const TracerouteScreen({super.key});

  @override
  State<TracerouteScreen> createState() => _TracerouteScreenState();
}

class _TracerouteScreenState extends State<TracerouteScreen> {
  final TextEditingController _hostController = TextEditingController(
    text: '8.8.8.8',
  );

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  void _runTraceroute(NetworkProvider provider) {
    final destination = _hostController.text.trim();

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a host or IP address.')),
      );
      return;
    }

    provider.runTraceroute(destination);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();
    final result = provider.tracerouteResult;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.route_rounded),
            SizedBox(width: 10),
            Text('Traceroute'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),

                  const SizedBox(height: 24),

                  _buildTargetCard(context, provider),

                  const SizedBox(height: 24),

                  if (provider.tracerouteTesting)
                    _buildLoadingCard(context, provider),

                  if (result != null) ...[
                    const SizedBox(height: 4),
                    _TracerouteResultCard(result: result),
                  ],

                  if (!provider.tracerouteTesting && result == null)
                    _buildEmptyState(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [colors.primary, colors.secondary],
            ),
          ),
          child: Icon(Icons.route_rounded, color: colors.onPrimary, size: 30),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Traceroute',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Analyze the network path between your computer and a destination.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TARGET CARD
  // ============================================================

  Widget _buildTargetCard(BuildContext context, NetworkProvider provider) {
    final colors = Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colors.primary.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.public_rounded, color: colors.primary),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trace Destination',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Enter a hostname or IPv4 address.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    _buildTextField(provider),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: _buildRunButton(provider),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildTextField(provider)),

                  const SizedBox(width: 12),

                  _buildRunButton(provider),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(NetworkProvider provider) {
    return TextField(
      controller: _hostController,
      enabled: !provider.tracerouteTesting,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) {
        if (!provider.tracerouteTesting) {
          _runTraceroute(provider);
        }
      },
      decoration: const InputDecoration(
        labelText: 'Host or IP Address',
        hintText: '8.8.8.8',
        prefixIcon: Icon(Icons.language_rounded),
      ),
    );
  }

  Widget _buildRunButton(NetworkProvider provider) {
    return FilledButton.icon(
      onPressed: provider.tracerouteTesting
          ? null
          : () => _runTraceroute(provider),
      icon: provider.tracerouteTesting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.route_rounded),
      label: Text(provider.tracerouteTesting ? 'Tracing...' : 'Run Traceroute'),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoadingCard(BuildContext context, NetworkProvider provider) {
    final colors = Theme.of(context).colorScheme;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),

            const SizedBox(height: 18),

            Text(
              'Tracing Network Route',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Windows is discovering the path to ${_hostController.text.trim()}.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 18),

            LinearProgressIndicator(
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(44),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.10),
                ),
                child: Icon(
                  Icons.route_rounded,
                  size: 38,
                  color: colors.primary,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Ready to Trace',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 7),

              Text(
                'Enter a destination above to discover its network path.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// RESULT CARD
// ============================================================

class _TracerouteResultCard extends StatelessWidget {
  final TracerouteResult result;

  const _TracerouteResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultHeader(context),

          const SizedBox(height: 22),

          if (result.error != null) _buildError(context),

          _buildStatistics(context),

          const SizedBox(height: 28),

          _buildPerformance(context),

          const SizedBox(height: 30),

          Text(
            'Network Path',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            'Each hop represents a router or network device along the route.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          if (result.hops.isEmpty) _buildNoHops(context),

          ...result.hops.map(
            (hop) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TracerouteHopTile(
                hop: hop,
                isLast: hop.hop == result.lastHop?.hop,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULT HEADER
  // ============================================================

  Widget _buildResultHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final status = result.completed
        ? StatusType.healthy
        : result.hops.isNotEmpty
        ? StatusType.warning
        : StatusType.error;

    final label = result.completed
        ? 'COMPLETED'
        : result.hops.isNotEmpty
        ? 'INCOMPLETE'
        : 'FAILED';

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: colors.primary.withValues(alpha: 0.12),
          ),
          child: Icon(
            result.completed ? Icons.check_rounded : Icons.route_rounded,
            color: colors.primary,
            size: 28,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Traceroute Results',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              Text(
                'Destination: ${result.destination}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        StatusChip(label: label, status: status),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.red.withValues(alpha: 0.08),
        border: Border.all(color: Colors.red.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              result.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics(BuildContext context) {
    final items = [
      _SummaryCard(
        label: 'Total Hops',
        value: '${result.hopCount}',
        icon: Icons.account_tree_rounded,
      ),
      _SummaryCard(
        label: 'Responding',
        value: '${result.respondingHopCount}',
        icon: Icons.router_rounded,
      ),
      _SummaryCard(
        label: 'Timeouts',
        value: '${result.timeoutCount}',
        icon: Icons.timer_off_rounded,
      ),
      _SummaryCard(
        label: 'Average',
        value: '${result.averageLatency.toStringAsFixed(1)} ms',
        icon: Icons.speed_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
            ? 4
            : constraints.maxWidth >= 550
            ? 2
            : 1;

        const spacing = 12.0;

        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map((item) => SizedBox(width: width, child: item))
              .toList(),
        );
      },
    );
  }

  // ============================================================
  // PERFORMANCE
  // ============================================================

  Widget _buildPerformance(BuildContext context) {
    final fastest = result.fastestHop;
    final slowest = result.slowestHop;

    if (fastest == null && slowest == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                children: [
                  _PerformanceCard(
                    title: 'Fastest Hop',
                    hop: fastest,
                    icon: Icons.bolt_rounded,
                    value: fastest == null
                        ? 'N/A'
                        : '${fastest.averageLatency.toStringAsFixed(1)} ms',
                  ),

                  const SizedBox(height: 12),

                  _PerformanceCard(
                    title: 'Slowest Hop',
                    hop: slowest,
                    icon: Icons.speed_rounded,
                    value: slowest == null
                        ? 'N/A'
                        : '${slowest.averageLatency.toStringAsFixed(1)} ms',
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _PerformanceCard(
                    title: 'Fastest Hop',
                    hop: fastest,
                    icon: Icons.bolt_rounded,
                    value: fastest == null
                        ? 'N/A'
                        : '${fastest.averageLatency.toStringAsFixed(1)} ms',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _PerformanceCard(
                    title: 'Slowest Hop',
                    hop: slowest,
                    icon: Icons.speed_rounded,
                    value: slowest == null
                        ? 'N/A'
                        : '${slowest.averageLatency.toStringAsFixed(1)} ms',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoHops(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'No traceroute hops received.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

// ============================================================
// PERFORMANCE CARD
// ============================================================

class _PerformanceCard extends StatelessWidget {
  final String title;
  final TracerouteHop? hop;
  final IconData icon;
  final String value;

  const _PerformanceCard({
    required this.title,
    required this.hop,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: colors.primary.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (hop != null)
                  Text(
                    'Hop ${hop!.hop} • ${hop!.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
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

// ============================================================
// HOP TILE
// ============================================================

class _TracerouteHopTile extends StatelessWidget {
  final TracerouteHop hop;
  final bool isLast;

  const _TracerouteHopTile({required this.hop, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final timedOut = hop.timedOut;
    final success = hop.success;

    final color = timedOut
        ? Colors.orange
        : success
        ? Colors.green
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.20)),
        color: color.withValues(alpha: 0.04),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text(
                '${hop.hop}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        timedOut ? 'Request Timed Out' : hop.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    if (isLast && success) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.flag_rounded, size: 16, color: color),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  timedOut
                      ? 'No response received'
                      : '${hop.responseCount} response(s) • '
                            'Min ${hop.minLatency} ms • '
                            'Max ${hop.maxLatency} ms',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          if (timedOut)
            const StatusChip(label: 'TIMEOUT', status: StatusType.warning)
          else
            Text(
              '${hop.averageLatency.toStringAsFixed(1)} ms',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.primary.withValues(alpha: 0.06),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
