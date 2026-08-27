import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/asn_result.dart';
import '../../providers/network_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_chip.dart';

class AsnLookupScreen extends StatefulWidget {
  const AsnLookupScreen({super.key});

  @override
  State<AsnLookupScreen> createState() => _AsnLookupScreenState();
}

class _AsnLookupScreenState extends State<AsnLookupScreen> {
  final TextEditingController _asnController = TextEditingController(
    text: 'AS22612',
  );

  @override
  void dispose() {
    _asnController.dispose();
    super.dispose();
  }

  void _runLookup(NetworkProvider provider) {
    final input = _asnController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an ASN.')));
      return;
    }

    provider.runAsnLookup(input);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();
    final result = provider.asnResult;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_tree_rounded),
            SizedBox(width: 10),
            Text('ASN Lookup'),
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
                          Icons.account_tree_rounded,
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
                              'ASN Lookup',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Look up an Autonomous System Number and inspect its network announcements.',
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
                              Icon(Icons.search_rounded, color: colors.primary),
                              const SizedBox(width: 10),
                              Text(
                                'ASN Lookup',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Enter an ASN such as AS22612 or 22612.',
                            style: theme.textTheme.bodySmall,
                          ),

                          const SizedBox(height: 18),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 650) {
                                return Column(
                                  children: [
                                    TextField(
                                      controller: _asnController,
                                      enabled: !provider.testingAsn,
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: (_) {
                                        if (!provider.testingAsn) {
                                          _runLookup(provider);
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'ASN',
                                        hintText: 'AS22612 or 22612',
                                        prefixIcon: Icon(
                                          Icons.account_tree_outlined,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: _LookupButton(
                                        loading: provider.testingAsn,
                                        onPressed: () => _runLookup(provider),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _asnController,
                                      enabled: !provider.testingAsn,
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: (_) {
                                        if (!provider.testingAsn) {
                                          _runLookup(provider);
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'ASN',
                                        hintText: 'AS22612 or 22612',
                                        prefixIcon: Icon(
                                          Icons.account_tree_outlined,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  SizedBox(
                                    height: 56,
                                    child: _LookupButton(
                                      loading: provider.testingAsn,
                                      onPressed: () => _runLookup(provider),
                                    ),
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
                  if (provider.testingAsn)
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Looking up ASN',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Retrieving network information...',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // =====================================================
                  // RESULT
                  // =====================================================
                  if (result != null && !provider.testingAsn) ...[
                    const SizedBox(height: 4),
                    _AsnResultCard(result: result),
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
// LOOKUP BUTTON
// ============================================================

class _LookupButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _LookupButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.search_rounded),
      label: Text(loading ? 'Looking up...' : 'Lookup ASN'),
    );
  }
}

// ============================================================
// RESULT CARD
// ============================================================

class _AsnResultCard extends StatelessWidget {
  final AsnResult result;

  const _AsnResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final success = result.success;

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
                    color: success
                        ? Colors.green.withValues(alpha: 0.12)
                        : colors.error.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    success ? Icons.check_circle_rounded : Icons.error_rounded,
                    color: success ? Colors.green : colors.error,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ASN Lookup Result',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.asNumber == null
                            ? 'Unknown ASN'
                            : 'AS${result.asNumber}',
                        style: theme.textTheme.bodyMedium,
                      ),
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
            // NETWORK INFORMATION
            // =====================================================
            Text(
              'Network Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                final columns = width >= 750 ? 2 : 1;

                final itemWidth = columns == 2 ? (width - 12) / 2 : width;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _InfoTile(
                        icon: Icons.account_tree_rounded,
                        title: 'ASN',
                        value: result.asNumber == null
                            ? 'Unknown'
                            : 'AS${result.asNumber}',
                        color: colors.primary,
                      ),
                    ),

                    SizedBox(
                      width: itemWidth,
                      child: _InfoTile(
                        icon: Icons.business_rounded,
                        title: 'Organization',
                        value: result.organization,
                        color: colors.secondary,
                      ),
                    ),

                    SizedBox(
                      width: itemWidth,
                      child: _InfoTile(
                        icon: Icons.storage_rounded,
                        title: 'IPv4 Address Count',
                        value: _formatNumber(result.ipv4Count),
                        color: colors.primary,
                      ),
                    ),

                    SizedBox(
                      width: itemWidth,
                      child: _InfoTile(
                        icon: Icons.language_rounded,
                        title: 'IPv6 Prefix Count',
                        value: _formatNumber(result.ipv6PrefixCount),
                        color: colors.secondary,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // =====================================================
            // BGP PREFIXES
            // =====================================================
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Announced BGP Prefixes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (result.cidrs.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${result.cidrs.length}',
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            if (result.cidrs.isEmpty)
              const _EmptyPrefixCard()
            else
              Column(
                children: result.cidrs
                    .map(
                      (prefix) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PrefixTile(prefix: prefix),
                      ),
                    )
                    .toList(),
              ),

            const SizedBox(height: 20),

            // =====================================================
            // MESSAGE
            // =====================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: success
                    ? colors.primaryContainer.withValues(alpha: 0.45)
                    : colors.errorContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    success
                        ? Icons.info_outline_rounded
                        : Icons.warning_amber_rounded,
                    size: 20,
                    color: success ? colors.primary : colors.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result.message,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
  }
}

// ============================================================
// INFORMATION TILE
// ============================================================

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
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
                  maxLines: 2,
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

// ============================================================
// EMPTY PREFIX CARD
// ============================================================

class _EmptyPrefixCard extends StatelessWidget {
  const _EmptyPrefixCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.route_rounded, color: colors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No announced prefixes were returned.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PREFIX TILE
// ============================================================

class _PrefixTile extends StatelessWidget {
  final AsnPrefix prefix;

  const _PrefixTile({required this.prefix});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.route_rounded,
              size: 21,
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prefix.cidr,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${prefix.country} (${prefix.countryCode})',
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 3),

                Text(
                  prefix.continent,
                  style: theme.textTheme.bodySmall?.copyWith(
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
