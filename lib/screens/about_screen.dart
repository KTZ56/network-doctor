import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Network Doctor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 850,
              ),
              child: Column(
                children: [
                  // ==================================================
                  // LOGO
                  // ==================================================

                  Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: colors.outlineVariant,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/network_doctor_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Network Doctor',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Network diagnostics, analysis and troubleshooting.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // APPLICATION INFORMATION
                  // ==================================================

                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(
                        color: colors.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _AboutRow(
                            icon: Icons.apps_rounded,
                            title: 'Application',
                            value: 'Network Doctor',
                          ),
                          _AboutRow(
                            icon: Icons.numbers_rounded,
                            title: 'Version',
                            value: '1.0.0+1',
                          ),
                          _AboutRow(
                            icon: Icons.code_rounded,
                            title: 'Technology',
                            value: 'Flutter / Dart',
                          ),
                          _AboutRow(
                            icon: Icons.desktop_windows_rounded,
                            title: 'Platform',
                            value: 'Windows Desktop',
                          ),
                          _AboutRow(
                            icon: Icons.person_rounded,
                            title: 'Developer',
                            value: 'Kuach',
                          ),
                          _AboutRow(
                            icon: Icons.copyright_rounded,
                            title: 'Copyright',
                            value: '© 2026 Kuach',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================

                  Card(
                    elevation: 0,
                    color: colors.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'About the Application',
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Network Doctor is a desktop network diagnostic '
                            'application designed to help users inspect, '
                            'analyze and troubleshoot network connectivity.',
                            style: theme.textTheme.bodyMedium,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'It provides tools for ping testing, DNS lookup, '
                            'IP geolocation, ASN lookup, WHOIS, traceroute, '
                            'port scanning, device discovery and network speed testing.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // RESPONSIBLE USE
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.primary.withValues(
                          alpha: 0.12,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Use Network Doctor only on networks and '
                            'systems you own or are authorized to test.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    '© 2026 Kuach • All rights reserved.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
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

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AboutRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colors.primary,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}