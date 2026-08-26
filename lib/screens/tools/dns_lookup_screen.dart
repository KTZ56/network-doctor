import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/network_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_chip.dart';

class DnsLookupScreen extends StatefulWidget {
  const DnsLookupScreen({super.key});

  @override
  State<DnsLookupScreen> createState() => _DnsLookupScreenState();
}

class _DnsLookupScreenState extends State<DnsLookupScreen> {
  final TextEditingController _hostController = TextEditingController(
    text: 'google.com',
  );

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  void _runLookup(NetworkProvider provider) {
    final hostname = _hostController.text.trim();

    if (hostname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a domain name.')),
      );
      return;
    }

    provider.runDnsLookup(hostname);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();
    final result = provider.dnsLookupResult;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [Icon(Icons.dns), SizedBox(width: 10), Text('DNS Lookup')],
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
                          Icons.dns,
                          color: colors.onPrimary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DNS Lookup',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Resolve domain names and inspect DNS response information.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // =====================================================
                  // SEARCH CARD
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
                                'Domain Lookup',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          TextField(
                            controller: _hostController,
                            enabled: !provider.testingDnsLookup,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) {
                              if (!provider.testingDnsLookup) {
                                _runLookup(provider);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Domain Name',
                              hintText: 'google.com',
                              prefixIcon: const Icon(Icons.language),
                              suffixIcon: _hostController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: provider.testingDnsLookup
                                          ? null
                                          : () {
                                              _hostController.clear();
                                              setState(() {});
                                            },
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: provider.testingDnsLookup
                                  ? null
                                  : () => _runLookup(provider),
                              icon: provider.testingDnsLookup
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.travel_explore),
                              label: Text(
                                provider.testingDnsLookup
                                    ? 'Resolving DNS...'
                                    : 'Lookup DNS',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =====================================================
                  // LOADING
                  // =====================================================
                  if (provider.testingDnsLookup)
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
                                  'Resolving DNS',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Waiting for DNS response...',
                                  style: theme.textTheme.bodySmall,
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
                  if (result != null && !provider.testingDnsLookup) ...[
                    const SizedBox(height: 4),
                    _DnsResultCard(result: result),
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
// DNS RESULT CARD
// ============================================================

class _DnsResultCard extends StatelessWidget {
  final dynamic result;

  const _DnsResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool success = result.success;

    final Color statusColor = success ? Colors.green : Colors.red;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // RESULT HEADER
            // =====================================================
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: statusColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: statusColor,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DNS Lookup Result',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(result.hostname, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),

                StatusChip(
                  label: success ? 'SUCCESS' : 'FAILED',
                  status: success ? StatusType.healthy : StatusType.error,
                ),
              ],
            ),

            const SizedBox(height: 24),

            Divider(color: colors.outlineVariant),

            const SizedBox(height: 20),

            // =====================================================
            // MESSAGE
            // =====================================================
            Text(
              'Response',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(result.message, style: theme.textTheme.bodyMedium),

            const SizedBox(height: 22),

            // =====================================================
            // IP INFORMATION
            // =====================================================
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      _DnsInfoTile(
                        icon: Icons.language,
                        title: 'IPv4 Address',
                        value: result.ipv4 ?? 'Not resolved',
                        color: colors.primary,
                      ),

                      if (result.ipv6 != null) ...[
                        const SizedBox(height: 12),
                        _DnsInfoTile(
                          icon: Icons.language,
                          title: 'IPv6 Address',
                          value: result.ipv6!,
                          color: colors.secondary,
                        ),
                      ],

                      const SizedBox(height: 12),

                      _DnsInfoTile(
                        icon: Icons.timer_outlined,
                        title: 'Response Time',
                        value: '${result.durationMs} ms',
                        color: Colors.orange,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _DnsInfoTile(
                        icon: Icons.language,
                        title: 'IPv4 Address',
                        value: result.ipv4 ?? 'Not resolved',
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _DnsInfoTile(
                        icon: Icons.timer_outlined,
                        title: 'Response Time',
                        value: '${result.durationMs} ms',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                );
              },
            ),

            if (result.ipv6 != null) ...[
              const SizedBox(height: 12),
              _DnsInfoTile(
                icon: Icons.language,
                title: 'IPv6 Address',
                value: result.ipv6!,
                color: colors.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DNS INFORMATION TILE
// ============================================================

class _DnsInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DnsInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
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
