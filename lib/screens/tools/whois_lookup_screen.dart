import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/network_provider.dart';

class WhoisLookupScreen extends StatefulWidget {
  const WhoisLookupScreen({super.key});

  @override
  State<WhoisLookupScreen> createState() =>
      _WhoisLookupScreenState();
}

class _WhoisLookupScreenState
    extends State<WhoisLookupScreen> {
  final TextEditingController _domainController =
      TextEditingController(
    text: 'google.com',
  );

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  void _runLookup(NetworkProvider provider) {
    final domain = _domainController.text.trim();

    if (domain.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a domain name.'),
        ),
      );
      return;
    }

    provider.runWhoisLookup(domain);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();
    final result = provider.whoisResult;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.public_rounded),
            SizedBox(width: 10),
            Text('WHOIS Lookup'),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1000,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Container(
                        width: 56,
                        height: 56,

                        decoration: BoxDecoration(
                          color:
                              colors.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(17),
                        ),

                        child: Icon(
                          Icons.public_rounded,
                          size: 30,
                          color:
                              colors.onPrimaryContainer,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              'WHOIS Lookup',

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
                              'Retrieve domain registration, registrar, expiry, and name server information.',

                              style: theme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: colors
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // SEARCH CARD
                  // ==================================================

                  Card(
                    elevation: 0,

                    color:
                        colors.surfaceContainerHighest,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color:
                                    colors.primary,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                'Domain Lookup',

                                style: theme
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Enter a domain such as google.com.',

                            style: theme
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color:
                                  colors.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 16),

                          LayoutBuilder(
                            builder:
                                (context, constraints) {
                              final compact =
                                  constraints.maxWidth <
                                      600;

                              final field =
                                  TextField(
                                controller:
                                    _domainController,

                                enabled:
                                    !provider
                                        .testingWhois,

                                keyboardType:
                                    TextInputType.url,

                                textInputAction:
                                    TextInputAction.search,

                                onSubmitted: (_) {
                                  if (!provider
                                      .testingWhois) {
                                    _runLookup(
                                      provider,
                                    );
                                  }
                                },

                                decoration:
                                    InputDecoration(
                                  labelText:
                                      'Domain Name',

                                  hintText:
                                      'google.com',

                                  prefixIcon:
                                      const Icon(
                                    Icons
                                        .language_rounded,
                                  ),

                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),
                                ),
                              );

                              final button =
                                  SizedBox(
                                height: 56,

                                child:
                                    FilledButton.icon(
                                  onPressed:
                                      provider
                                              .testingWhois
                                          ? null
                                          : () {
                                              _runLookup(
                                                provider,
                                              );
                                            },

                                  icon: provider
                                          .testingWhois
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons
                                              .search_rounded,
                                        ),

                                  label: Text(
                                    provider
                                            .testingWhois
                                        ? 'Looking up...'
                                        : 'Lookup WHOIS',
                                  ),
                                ),
                              );

                              if (compact) {
                                return Column(
                                  children: [
                                    field,

                                    const SizedBox(
                                      height: 12,
                                    ),

                                    SizedBox(
                                      width:
                                          double.infinity,
                                      child: button,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  Expanded(
                                    child: field,
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  button,
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // LOADING
                  // ==================================================

                  if (provider.testingWhois)
                    Card(
                      elevation: 0,

                      child: Padding(
                        padding:
                            const EdgeInsets.all(24),

                        child: Row(
                          children: [
                            SizedBox(
                              width: 26,
                              height: 26,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color:
                                    colors.primary,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  Text(
                                    'Retrieving WHOIS data',

                                    style: theme
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    'Querying domain registration information...',

                                    style: theme
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                      color: colors
                                          .onSurfaceVariant,
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

                  if (result != null &&
                      !provider.testingWhois)
                    _WhoisResultCard(
                      result: result,
                    ),
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
// WHOIS RESULT CARD
// ============================================================

class _WhoisResultCard extends StatelessWidget {
  final dynamic result;

  const _WhoisResultCard({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool success = result.success as bool;

    final Color statusColor =
        success ? Colors.green : colors.error;

    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // RESULT HEADER
            // ==================================================

            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,

                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.12,
                    ),

                    borderRadius:
                        BorderRadius.circular(17),
                  ),

                  child: Icon(
                    success
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,

                    color: statusColor,
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
                        'WHOIS Result',

                        style: theme
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        result.domain,

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

                _StatusBadge(
                  success: success,
                ),
              ],
            ),

            const SizedBox(height: 24),

            Divider(
              color: colors.outlineVariant,
            ),

            const SizedBox(height: 24),

            // ==================================================
            // REGISTRATION INFORMATION
            // ==================================================

            Text(
              'Registration Information',

              style: theme
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= 700
                        ? 2
                        : 1;

                final width = columns == 2
                    ? (constraints.maxWidth - 12) /
                        2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,

                  children: [
                    SizedBox(
                      width: width,

                      child: _WhoisInfoTile(
                        icon:
                            Icons.business_rounded,

                        title: 'Registrar',

                        value:
                            result.registrar,
                      ),
                    ),

                    SizedBox(
                      width: width,

                      child: _WhoisInfoTile(
                        icon:
                            Icons.calendar_today_rounded,

                        title: 'Creation Date',

                        value:
                            result.creationDate,
                      ),
                    ),

                    SizedBox(
                      width: width,

                      child: _WhoisInfoTile(
                        icon:
                            Icons.event_rounded,

                        title: 'Expiry Date',

                        value:
                            result.expiryDate,
                      ),
                    ),

                    SizedBox(
                      width: width,

                      child: _WhoisInfoTile(
                        icon:
                            Icons.public_rounded,

                        title: 'Domain',

                        value:
                            result.domain,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // ==================================================
            // NAME SERVERS
            // ==================================================

            Row(
              children: [
                Icon(
                  Icons.dns_rounded,
                  color: colors.primary,
                ),

                const SizedBox(width: 10),

                Text(
                  'Name Servers',

                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (result.nameServers.isEmpty)
              _EmptyNameServers()
            else
              Column(
                children: result.nameServers
                    .map<Widget>(
                      (server) =>
                          _NameServerTile(
                        server:
                            server.toString(),
                      ),
                    )
                    .toList(),
              ),

            const SizedBox(height: 24),

            // ==================================================
            // MESSAGE
            // ==================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color:
                    colors.surfaceContainerHighest,

                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Icon(
                    success
                        ? Icons.info_outline_rounded
                        : Icons
                            .warning_amber_rounded,

                    color: statusColor,
                    size: 21,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      result.message,

                      style: theme
                          .textTheme
                          .bodyMedium,
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
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final bool success;

  const _StatusBadge({
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        success ? Colors.green : Colors.red;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        success ? 'SUCCESS' : 'FAILED',

        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// WHOIS INFORMATION TILE
// ============================================================

class _WhoisInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _WhoisInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color:
            colors.surfaceContainerHighest,

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color:
                  colors.primaryContainer,

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              size: 21,
              color:
                  colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: theme
                      .textTheme
                      .labelMedium
                      ?.copyWith(
                    color:
                        colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,

                  maxLines: 2,

                  overflow:
                      TextOverflow.ellipsis,

                  style: theme
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
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
// NAME SERVER TILE
// ============================================================

class _NameServerTile extends StatelessWidget {
  final String server;

  const _NameServerTile({
    required this.server,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(bottom: 10),

      padding:
          const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color:
            colors.surfaceContainerHighest,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color:
              colors.outlineVariant,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color:
                  colors.secondaryContainer,

              borderRadius:
                  BorderRadius.circular(11),
            ),

            child: Icon(
              Icons.dns_rounded,
              size: 19,
              color:
                  colors.onSecondaryContainer,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              server,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              style: theme
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY NAME SERVERS
// ============================================================

class _EmptyNameServers
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color:
            colors.surfaceContainerHighest,

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Icon(
            Icons.dns_outlined,
            color:
                colors.onSurfaceVariant,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'No name servers were returned.',

              style: TextStyle(
                color:
                    colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}