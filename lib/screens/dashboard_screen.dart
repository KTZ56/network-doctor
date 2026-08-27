import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/network_provider.dart';

import 'tools/asn_lookup_screen.dart';
import 'tools/device_scanner_screen.dart';
import 'tools/dns_lookup_screen.dart';
import 'tools/ip_geolocation_screen.dart';
import 'tools/ping_test_screen.dart';
import 'tools/port_scanner_screen.dart';
import 'tools/speed_test_screen.dart';
import 'tools/traceroute_screen.dart';
import 'tools/whois_lookup_screen.dart';

import '../widgets/metric_card.dart';
import '../widgets/quick_action_card.dart';
import 'settings_screen.dart';
import 'tools/traffic_monitor_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/network_doctor_logo.png',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 12),

            Text(
              'Network Doctor',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          IconButton(
            tooltip: 'Scan Network',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: provider.loading ? null : provider.loadNetworkInfo,
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: provider.loading
            ? const _LoadingView()
            : provider.error != null
            ? _ErrorView(
                message: provider.error!,
                onRetry: provider.loadNetworkInfo,
              )
            : provider.networkInfo == null
            ? _EmptyView(onScan: provider.loadNetworkInfo)
            : _NetworkDashboard(info: provider.networkInfo!),
      ),
    );
  }
}

// ============================================================
// MAIN DASHBOARD
// ============================================================

class _NetworkDashboard extends StatelessWidget {
  final dynamic info;

  const _NetworkDashboard({required this.info});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeHeader(info: info),

                  const SizedBox(height: 28),

                  _QuickStatusBar(provider: provider),

                  const SizedBox(height: 32),

                  const _ToolsGridSection(),

                  const SizedBox(height: 36),

                  _NetworkHealthCard(provider: provider),

                  const SizedBox(height: 36),

                  _NetworkInfoSection(info: info),

                  const SizedBox(height: 36),

                  _DiagnosticsSection(provider: provider, info: info),

                  const SizedBox(height: 40),

                  const _AboutDeveloperCard(),

                  const SizedBox(height: 24),

                  const _DashboardFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// WELCOME HEADER
// ============================================================

class _WelcomeHeader extends StatelessWidget {
  final dynamic info;

  const _WelcomeHeader({required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.surfaceContainerHighest],
        ),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/network_doctor_logo.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network Doctor',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Diagnose, analyze and understand your network.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.lan_rounded, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      info.interfaceName,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
// QUICK STATUS BAR
// ============================================================

class _QuickStatusBar extends StatelessWidget {
  final NetworkProvider provider;

  const _QuickStatusBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final gatewayOk = provider.gatewayPing?.success == true;

    final internetOk = provider.internetPing?.success == true;

    final dnsOk = provider.dnsResult?.success == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 700;

        final items = [
          _QuickStatusItem(
            title: 'Gateway',
            value: gatewayOk ? 'Connected' : 'Not tested',
            icon: Icons.router_rounded,
            color: gatewayOk ? Colors.green : colors.outline,
          ),
          _QuickStatusItem(
            title: 'Internet',
            value: internetOk ? 'Connected' : 'Not tested',
            icon: Icons.public_rounded,
            color: internetOk ? Colors.green : colors.outline,
          ),
          _QuickStatusItem(
            title: 'DNS',
            value: dnsOk ? 'Operational' : 'Not tested',
            icon: Icons.dns_rounded,
            color: dnsOk ? Colors.green : colors.outline,
          ),
        ];

        if (isSmall) {
          return Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: item,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: items
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: item,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _QuickStatusItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStatusItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
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
// TOOLS
// ============================================================
class _ToolsGridSection extends StatelessWidget {
  const _ToolsGridSection();

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolItem(
        'Ping Test',
        'Test host connectivity',
        Icons.network_ping_rounded,
        const PingTestScreen(),
      ),
      _ToolItem(
        'DNS Lookup',
        'Resolve domain names',
        Icons.dns_rounded,
        const DnsLookupScreen(),
      ),
      _ToolItem(
        'IP Geolocation',
        'Inspect IP location',
        Icons.location_on_rounded,
        const IpGeolocationScreen(),
      ),
      _ToolItem(
        'ASN Lookup',
        'Inspect autonomous systems',
        Icons.account_tree_rounded,
        const AsnLookupScreen(),
      ),
      _ToolItem(
        'WHOIS Lookup',
        'Inspect domain registration',
        Icons.public_rounded,
        const WhoisLookupScreen(),
      ),
      _ToolItem(
        'Traceroute',
        'Trace network routes',
        Icons.route_rounded,
        const TracerouteScreen(),
      ),
      _ToolItem(
        'Port Scanner',
        'Check network ports',
        Icons.hub_rounded,
        const PortScannerScreen(),
      ),
      _ToolItem(
        'Device Scanner',
        'Discover local devices',
        Icons.devices_rounded,
        const DeviceScannerScreen(),
      ),
      _ToolItem(
        'Speed Test',
        'Measure network performance',
        Icons.speed_rounded,
        const SpeedTestScreen(),
      ),

      _ToolItem(
        'Traffic Monitor',
        'Monitor live bandwidth usage',
        Icons.monitor_heart_rounded,
        const TrafficMonitorScreen(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: Icons.build_circle_rounded,
          title: 'Network Tools',
          subtitle:
              'Everything you need to inspect and troubleshoot your network.',
        ),

        const SizedBox(height: 20),

        LayoutBuilder(
          builder: (context, constraints) {
            int columns;

            if (constraints.maxWidth >= 1100) {
              columns = 4;
            } else if (constraints.maxWidth >= 750) {
              columns = 3;
            } else if (constraints.maxWidth >= 500) {
              columns = 2;
            } else {
              columns = 1;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tools.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,

                // More vertical room for the card contents.
                childAspectRatio: columns == 4
                    ? 1.15
                    : columns == 3
                    ? 1.10
                    : columns == 2
                    ? 1.05
                    : 2.0,
              ),
              itemBuilder: (context, index) {
                final tool = tools[index];

                return QuickActionCard(
                  title: tool.title,
                  subtitle: tool.subtitle,
                  icon: tool.icon,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => tool.targetScreen),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget targetScreen;

  _ToolItem(this.title, this.subtitle, this.icon, this.targetScreen);
}

// ============================================================
// SECTION HEADING
// ============================================================

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.primary, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
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
}

// ============================================================
// NETWORK HEALTH
// ============================================================
class _NetworkHealthCard extends StatelessWidget {
  final NetworkProvider provider;

  const _NetworkHealthCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final gateway = provider.gatewayPing;
    final internet = provider.internetPing;
    final dns = provider.dnsResult;

    final gatewayOk = gateway?.success == true;
    final internetOk = internet?.success == true;
    final dnsOk = dns?.success == true;

    final testsCompleted = gateway != null && internet != null && dns != null;

    final healthyTests = [
      gatewayOk,
      internetOk,
      dnsOk,
    ].where((value) => value).length;

    final healthScore = testsCompleted ? ((healthyTests / 3) * 100).round() : 0;

    final Color healthColor;
    final String healthStatus;
    final IconData healthIcon;

    if (!testsCompleted) {
      healthColor = colors.outline;
      healthStatus = 'NOT TESTED';
      healthIcon = Icons.help_outline_rounded;
    } else if (healthScore == 100) {
      healthColor = Colors.green;
      healthStatus = 'EXCELLENT';
      healthIcon = Icons.check_circle_rounded;
    } else if (healthScore >= 66) {
      healthColor = Colors.orange;
      healthStatus = 'WARNING';
      healthIcon = Icons.warning_rounded;
    } else {
      healthColor = Colors.red;
      healthStatus = 'CRITICAL';
      healthIcon = Icons.error_rounded;
    }

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // HEADER
            // =====================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: healthColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(healthIcon, color: healthColor, size: 28),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network Health',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Real-time connectivity overview',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // SCORE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$healthScore%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: healthColor,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: healthColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        healthStatus,
                        style: TextStyle(
                          color: healthColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================================================
            // PROGRESS BAR
            // =====================================================
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: healthScore / 100,
                minHeight: 8,
                backgroundColor: colors.surfaceContainerHighest,
                color: healthColor,
              ),
            ),

            const SizedBox(height: 24),

            Divider(color: colors.outlineVariant),

            const SizedBox(height: 18),

            // =====================================================
            // TEST STATUS
            // =====================================================
            _HealthStatusRow(
              title: 'Gateway',
              subtitle: gateway == null ? 'Not tested' : gateway.message,
              success: gatewayOk,
              value: gateway?.latency != null ? '${gateway!.latency} ms' : null,
            ),

            const SizedBox(height: 16),

            _HealthStatusRow(
              title: 'Internet',
              subtitle: internet == null ? 'Not tested' : internet.message,
              success: internetOk,
              value: internet?.latency != null
                  ? '${internet!.latency} ms'
                  : null,
            ),

            const SizedBox(height: 16),

            _HealthStatusRow(
              title: 'DNS',
              subtitle: dns == null ? 'Not tested' : dns.message,
              success: dnsOk,
              value: dns?.durationMs != null ? '${dns!.durationMs} ms' : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// NETWORK INFORMATION
// ============================================================
// ============================================================
// NETWORK INFORMATION SECTION
// ============================================================

class _NetworkInfoSection extends StatelessWidget {
  final dynamic info;

  const _NetworkInfoSection({required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================
        // SECTION HEADER
        // =====================================================
        _SectionHeading(
          icon: Icons.lan_rounded,
          title: 'Network Information',
          subtitle: 'Current configuration of your active network interface.',
        ),

        const SizedBox(height: 20),

        // =====================================================
        // INFORMATION GRID
        // =====================================================
        LayoutBuilder(
          builder: (context, constraints) {
            int columns;

            if (constraints.maxWidth >= 1100) {
              columns = 3;
            } else if (constraints.maxWidth >= 700) {
              columns = 2;
            } else {
              columns = 1;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,

                // Gives MetricCard enough vertical space.
                childAspectRatio: columns == 3
                    ? 2.35
                    : columns == 2
                    ? 2.6
                    : 3.4,
              ),
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return MetricCard(
                      title: 'IPv4 Address',
                      value: info.ipv4,
                      icon: Icons.computer_rounded,
                      color: Colors.blue,
                    );

                  case 1:
                    return MetricCard(
                      title: 'Subnet Mask',
                      value: info.subnetMask,
                      icon: Icons.account_tree_rounded,
                      color: Colors.green,
                    );

                  case 2:
                    return MetricCard(
                      title: 'Default Gateway',
                      value: info.gateway,
                      icon: Icons.router_rounded,
                      color: Colors.orange,
                    );

                  case 3:
                    return MetricCard(
                      title: 'DNS Server',
                      value: info.dns,
                      icon: Icons.dns_rounded,
                      color: Colors.cyan,
                    );

                  case 4:
                    return MetricCard(
                      title: 'MAC Address',
                      value: info.macAddress,
                      icon: Icons.memory_rounded,
                      color: Colors.purple,
                    );

                  case 5:
                    return MetricCard(
                      title: 'DHCP',
                      value: info.dhcpEnabled ? 'Enabled' : 'Disabled',
                      icon: Icons.settings_ethernet_rounded,
                      color: info.dhcpEnabled ? Colors.green : Colors.red,
                    );

                  default:
                    return const SizedBox.shrink();
                }
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // =====================================================
        // INTERFACE SUMMARY
        // =====================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: colors.primaryContainer.withValues(alpha: 0.35),
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
                child: Icon(Icons.wifi_rounded, color: colors.primary),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Interface',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      info.interfaceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.green.withValues(alpha: 0.12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
// DIAGNOSTICS
// ============================================================

class _DiagnosticsSection extends StatelessWidget {
  final NetworkProvider provider;
  final dynamic info;

  const _DiagnosticsSection({required this.provider, required this.info});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: Icons.monitor_heart_rounded,
          title: 'Connectivity Diagnostics',
          subtitle:
              'Test your gateway, Internet connection and DNS resolution.',
        ),

        const SizedBox(height: 20),

        FilledButton.icon(
          onPressed: provider.testing ? null : provider.runConnectivityTest,
          icon: provider.testing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.network_check_rounded),
          label: Text(
            provider.testing ? 'Testing Network...' : 'Run Network Test',
          ),
        ),

        const SizedBox(height: 20),

        if (provider.gatewayPing != null)
          _TestResultCard(
            title: 'Local Gateway',
            subtitle: info.gateway,
            result: provider.gatewayPing!,
          ),

        if (provider.internetPing != null)
          _TestResultCard(
            title: 'Internet',
            subtitle: '8.8.8.8',
            result: provider.internetPing!,
          ),

        if (provider.dnsResult != null)
          _DnsResultCard(result: provider.dnsResult!),

        if (provider.diagnosis != null) ...[
          const SizedBox(height: 12),
          _DiagnosisCard(diagnosis: provider.diagnosis!),
        ],
      ],
    );
  }
}

// ============================================================
// TEST RESULT
// ============================================================

class _TestResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic result;

  const _TestResultCard({
    required this.title,
    required this.subtitle,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final success = result.success == true;

    final color = success ? Colors.green : Colors.red;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                success ? Icons.check_circle_rounded : Icons.error_rounded,
                color: color,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    result.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Text(
              success ? 'CONNECTED' : 'FAILED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DNS RESULT
// ============================================================

class _DnsResultCard extends StatelessWidget {
  final dynamic result;

  const _DnsResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final success = result.success == true;

    final color = success ? Colors.green : Colors.red;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                success ? Icons.dns_rounded : Icons.dns_outlined,
                color: color,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DNS Resolution',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    result.hostname,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(result.message),

                  const SizedBox(height: 5),

                  Text('IPv4: ${result.ipv4 ?? 'Not found'}'),

                  if (result.ipv6 != null) Text('IPv6: ${result.ipv6}'),
                ],
              ),
            ),

            Text(
              '${result.durationMs} ms',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DIAGNOSIS
// ============================================================

class _DiagnosisCard extends StatelessWidget {
  final dynamic diagnosis;

  const _DiagnosisCard({required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final levelName = diagnosis.level?.toString().split('.').last.toLowerCase();

    late Color color;
    late IconData icon;
    late String severity;

    switch (levelName) {
      case 'healthy':
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        severity = 'HEALTHY';
        break;

      case 'warning':
        color = Colors.orange;
        icon = Icons.warning_rounded;
        severity = 'WARNING';
        break;

      case 'critical':
        color = Colors.red;
        icon = Icons.error_rounded;
        severity = 'CRITICAL';
        break;

      default:
        color = colors.outline;
        icon = Icons.info_rounded;
        severity = 'UNKNOWN';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Network Diagnosis',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    diagnosis.title ?? 'Status',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(diagnosis.message ?? ''),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                severity,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HEALTH ROW
// ============================================================
class _HealthStatusRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool success;
  final String? value;

  const _HealthStatusRow({
    required this.title,
    required this.subtitle,
    required this.success,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final color = success ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(
              success ? Icons.check_rounded : Icons.close_rounded,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          if (value != null) ...[
            const SizedBox(width: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: colors.surface,
              ),
              child: Text(
                value!,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// ABOUT / DEVELOPER
// ============================================================

class _AboutDeveloperCard extends StatelessWidget {
  const _AboutDeveloperCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.code_rounded,
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
                        'About Network Doctor',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'A network diagnostic and troubleshooting toolkit designed to help users understand their network environment.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Divider(color: colors.outlineVariant),

            const SizedBox(height: 18),

            _AboutRow(
              icon: Icons.person_rounded,
              title: 'Developer',
              value: 'James Kuach',
            ),

            const SizedBox(height: 12),

            _AboutRow(
              icon: Icons.apps_rounded,
              title: 'Application',
              value: 'Network Doctor',
            ),

            const SizedBox(height: 12),

            _AboutRow(
              icon: Icons.numbers_rounded,
              title: 'Version',
              value: '1.0.0',
            ),

            const SizedBox(height: 12),

            _AboutRow(
              icon: Icons.calendar_today_rounded,
              title: 'Copyright',
              value: '© 2026 Kush Tech Zone • All rights reserved.',
            ),

            const SizedBox(height: 12),

            _AboutRow(
              icon: Icons.security_rounded,
              title: 'Privacy',
              value:
                  'Network diagnostics are performed locally where supported.',
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Network Doctor is intended for network diagnostics, troubleshooting, learning, and authorized testing.',
                      style: theme.textTheme.bodySmall,
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

    return Row(
      children: [
        Icon(icon, size: 20, color: colors.primary),

        const SizedBox(width: 12),

        SizedBox(
          width: 100,
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
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
    );
  }
}

// ============================================================
// FOOTER
// ============================================================

class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            size: 26,
            color: colors.primary,
          ),

          const SizedBox(height: 8),

          Text(
            'Network Doctor',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            '© 2026 Kush Tech Zone • All rights reserved.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 4),

          Text(
            'Built for network diagnostics.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ==================================================
          // NETWORK DOCTOR LOGO
          // ==================================================
          Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: colors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/network_doctor_logo.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 22),

          // ==================================================
          // PROGRESS
          // ==================================================
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colors.primary,
            ),
          ),

          const SizedBox(height: 18),

          // ==================================================
          // TITLE
          // ==================================================
          Text(
            'Scanning Network',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // ==================================================
          // DESCRIPTION
          // ==================================================
          Text(
            'Reading network interface information...',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 58,
                  color: colors.error,
                ),

                const SizedBox(height: 16),

                Text(
                  'Network Scan Failed',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyView extends StatelessWidget {
  final VoidCallback onScan;

  const _EmptyView({required this.onScan});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.network_check_rounded,
                size: 40,
                color: colors.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'No Network Information',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Network Doctor has not scanned your network yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.radar_rounded),
              label: const Text('Scan Network'),
            ),
          ],
        ),
      ),
    );
  }
}
