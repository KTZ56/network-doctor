import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/ping_result.dart';
import '../../providers/network_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/status_chip.dart';

class PingTestScreen extends StatefulWidget {
  const PingTestScreen({super.key});

  @override
  State<PingTestScreen> createState() => _PingTestScreenState();
}

class _PingTestScreenState extends State<PingTestScreen> {
  final TextEditingController _hostController = TextEditingController(
    text: '8.8.8.8',
  );

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _runPing(NetworkProvider provider) async {
    final host = _hostController.text.trim();

    if (host.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an IP address or hostname.'),
        ),
      );
      return;
    }

    await provider.runPingTest(host);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();
    final result = provider.pingTestResult;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.network_ping),
            SizedBox(width: 10),
            Text('Ping Test'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =====================================================
                  // HEADER
                  // =====================================================
                  Row(
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
                        child: Icon(
                          Icons.network_ping,
                          size: 30,
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ping Test',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Check host connectivity and measure network response time.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // =====================================================
                  // TARGET INPUT
                  // =====================================================
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.search, color: colors.primary),
                              const SizedBox(width: 10),
                              Text(
                                'Target Host',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 600) {
                                return Column(
                                  children: [
                                    _HostField(
                                      controller: _hostController,
                                      enabled: !provider.testingPing,
                                      onSubmitted: () {
                                        if (!provider.testingPing) {
                                          _runPing(provider);
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    _PingButton(
                                      provider: provider,
                                      onPressed: () => _runPing(provider),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: _HostField(
                                      controller: _hostController,
                                      enabled: !provider.testingPing,
                                      onSubmitted: () {
                                        if (!provider.testingPing) {
                                          _runPing(provider);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  _PingButton(
                                    provider: provider,
                                    onPressed: () => _runPing(provider),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =====================================================
                  // LOADING
                  // =====================================================
                  if (provider.testingPing)
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Testing Connection',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Sending ping request...',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // =====================================================
                  // RESULT
                  // =====================================================
                  if (result != null && !provider.testingPing) ...[
                    const SizedBox(height: 4),
                    _PingResultCard(
                      result: result,
                      host: _hostController.text.trim(),
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
// HOST FIELD
// ============================================================

class _HostField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmitted;

  const _HostField({
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmitted(),
      decoration: const InputDecoration(
        labelText: 'Host IP or Domain',
        hintText: '8.8.8.8 or google.com',
        prefixIcon: Icon(Icons.computer),
      ),
    );
  }
}

// ============================================================
// PING BUTTON
// ============================================================

class _PingButton extends StatelessWidget {
  final NetworkProvider provider;
  final VoidCallback onPressed;

  const _PingButton({required this.provider, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: provider.testingPing ? null : onPressed,
      icon: provider.testingPing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.network_ping),
      label: Text(provider.testingPing ? 'Pinging...' : 'Send Ping'),
    );
  }
}

// ============================================================
// PING RESULT
// ============================================================

class _PingResultCard extends StatelessWidget {
  final PingResult result;
  final String host;

  const _PingResultCard({required this.result, required this.host});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool success = result.success;

    final Color statusColor = success ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================
        // RESULT HEADER
        // =====================================================
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: statusColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: statusColor,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ping Result',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(host, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),

                StatusChip(
                  label: success ? 'REACHABLE' : 'FAILED',
                  status: success ? StatusType.healthy : StatusType.error,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // =====================================================
        // METRICS
        // =====================================================
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 3 : 1;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 3.0 : 1.8,
              children: [
                MetricCard(
                  title: 'Status',
                  value: success ? 'Online' : 'Offline',
                  icon: success ? Icons.wifi : Icons.wifi_off,
                  color: statusColor,
                ),

                MetricCard(
                  title: 'Response',
                  value: result.latency != null
                      ? '${result.latency} ms'
                      : 'N/A',
                  icon: Icons.timer,
                  color: colors.primary,
                ),

                MetricCard(
                  title: 'Target',
                  value: host,
                  icon: Icons.language,
                  color: colors.secondary,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // =====================================================
        // RESPONSE MESSAGE
        // =====================================================
        GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: colors.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Response Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(result.message, style: theme.textTheme.bodyLarge),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(
                      success ? Icons.check_circle : Icons.error_outline,
                      size: 20,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        success
                            ? 'The target host responded successfully.'
                            : 'The target host did not respond to the ping request.',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
