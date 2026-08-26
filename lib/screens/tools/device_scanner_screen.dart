import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/network_device.dart';
import '../../providers/network_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_chip.dart';

class DeviceScannerScreen extends StatefulWidget {
  const DeviceScannerScreen({super.key});

  @override
  State<DeviceScannerScreen> createState() =>
      _DeviceScannerScreenState();
}

class _DeviceScannerScreenState
    extends State<DeviceScannerScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();

    final devices = [...provider.devices];

    // Online devices first, offline devices last.
    devices.sort((a, b) {
      if (a.reachable == b.reachable) {
        return _compareIpAddresses(a.ip, b.ip);
      }

      return a.reachable ? -1 : 1;
    });

    final onlineCount =
        devices.where((device) => device.reachable).length;

    final offlineCount =
        devices.where((device) => !device.reachable).length;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.devices_rounded),
            SizedBox(width: 10),
            Text('Device Scanner'),
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
                  const _HeaderSection(),

                  const SizedBox(height: 28),

                  _StatisticsSection(
                    total: devices.length,
                    online: onlineCount,
                    offline: offlineCount,
                  ),

                  const SizedBox(height: 24),

                  _ScanControlCard(
                    provider: provider,
                  ),

                  const SizedBox(height: 28),

                  _DevicesSection(
                    provider: provider,
                    devices: devices,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _compareIpAddresses(String a, String b) {
    final aParts =
        a.split('.').map(int.parse).toList();

    final bParts =
        b.split('.').map(int.parse).toList();

    for (int i = 0; i < 4; i++) {
      final result =
          aParts[i].compareTo(bParts[i]);

      if (result != 0) {
        return result;
      }
    }

    return 0;
  }
}

// ============================================================
// HEADER
// ============================================================

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

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
            Icons.radar_rounded,
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
                'Network Devices',
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
                'Discover and inspect devices connected to your local network.',
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
// STATISTICS
// ============================================================

class _StatisticsSection
    extends StatelessWidget {
  final int total;
  final int online;
  final int offline;

  const _StatisticsSection({
    required this.total,
    required this.online,
    required this.offline,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 850
            ? 3
            : width >= 550
                ? 2
                : 1;

        const spacing = 12.0;

        final itemWidth = columns == 1
            ? width
            : (width -
                    ((columns - 1) *
                        spacing)) /
                columns;

        final items = [
          _StatItem(
            title: 'Hosts Scanned',
            value: '$total',
            icon: Icons.devices_rounded,
          ),
          _StatItem(
            title: 'Online',
            value: '$online',
            icon: Icons.check_circle_rounded,
          ),
          _StatItem(
            title: 'Offline',
            value: '$offline',
            icon: Icons.cloud_off_rounded,
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: _StatCard(
                item: item,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================================
// STAT ITEM
// ============================================================

class _StatItem {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
  });
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(14),
              color: colors.primary
                  .withValues(alpha: 0.12),
            ),
            child: Icon(
              item.icon,
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
                  item.title,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: colors
                            .onSurfaceVariant,
                      ),
                ),

                const SizedBox(height: 4),

                Text(
                  item.value,
                  style: theme
                      .textTheme
                      .headlineSmall
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
// SCAN CONTROL
// ============================================================

class _ScanControlCard
    extends StatelessWidget {
  final NetworkProvider provider;

  const _ScanControlCard({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final completed =
        provider.deviceScanCompleted;

    final total =
        provider.deviceScanTotal;

    final progress = total > 0
        ? (completed / total)
            .clamp(0.0, 1.0)
        : 0.0;

    return GlassCard(
      child: LayoutBuilder(
        builder:
            (context, constraints) {
          final compact =
              constraints.maxWidth < 650;

          final header = Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(16),
                  color: colors.primary
                      .withValues(alpha: 0.12),
                ),
                child: Icon(
                  provider.scanningDevices
                      ? Icons.radar_rounded
                      : Icons
                          .manage_search_rounded,
                  color: colors.primary,
                  size: 27,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.scanningDevices
                          ? 'Scanning Network'
                          : 'Network Scanner',
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      provider.scanningDevices
                          ? '$completed of $total hosts checked'
                          : 'Scan your local subnet for connected devices.',
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
          );

          final button =
              FilledButton.icon(
            onPressed:
                provider.scanningDevices
                    ? provider.cancelDeviceScan
                    : provider.scanDevices,
            icon: provider.scanningDevices
                ? const Icon(
                    Icons.stop_rounded,
                  )
                : const Icon(
                    Icons.radar_rounded,
                  ),
            label: Text(
              provider.scanningDevices
                  ? 'Cancel'
                  : 'Scan Network',
            ),
          );

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (compact) ...[
                header,
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: button,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: header,
                    ),
                    const SizedBox(width: 16),
                    button,
                  ],
                ),
              ],

              if (provider.scanningDevices) ...[
                const SizedBox(height: 20),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),
                  child:
                      LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: theme
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const Spacer(),

                    Text(
                      '${provider.devices.length} devices found',
                      style: theme
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// DEVICES SECTION
// ============================================================

class _DevicesSection
    extends StatelessWidget {
  final NetworkProvider provider;
  final List<NetworkDevice> devices;

  const _DevicesSection({
    required this.provider,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.colorScheme;

    if (provider.scanningDevices) {
      return GlassCard(
        child: Padding(
          padding:
              const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  width: 42,
                  height: 42,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Scanning network devices...',
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Please wait while Network Doctor checks the local network.',
                  textAlign:
                      TextAlign.center,
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
        ),
      );
    }

    if (devices.isEmpty) {
      return GlassCard(
        child: Padding(
          padding:
              const EdgeInsets.all(42),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    color: colors.primary
                        .withValues(
                      alpha: 0.10,
                    ),
                  ),
                  child: Icon(
                    Icons
                        .devices_other_rounded,
                    size: 36,
                    color:
                        colors.primary,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'No Devices Found',
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 7),

                Text(
                  'Run a network scan to discover devices.',
                  textAlign:
                      TextAlign.center,
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
        ),
      );
    }

    final onlineDevices =
        devices
            .where(
              (device) =>
                  device.reachable,
            )
            .toList();

    final offlineDevices =
        devices
            .where(
              (device) =>
                  !device.reachable,
            )
            .toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Scanned Hosts',
                style: theme
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    colors.primaryContainer,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                '${devices.length}',
                style: TextStyle(
                  color: colors
                      .onPrimaryContainer,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        if (onlineDevices.isNotEmpty) ...[
          _SectionTitle(
            icon:
                Icons.check_circle_rounded,
            title: 'Online Devices',
            count:
                onlineDevices.length,
          ),

          const SizedBox(height: 10),

          ...onlineDevices.map(
            (device) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child:
                  _DeviceCard(
                device: device,
              ),
            ),
          ),
        ],

        if (offlineDevices.isNotEmpty) ...[
          const SizedBox(height: 12),

          _SectionTitle(
            icon:
                Icons.cloud_off_rounded,
            title: 'Offline Hosts',
            count:
                offlineDevices.length,
          ),

          const SizedBox(height: 10),

          ...offlineDevices.map(
            (device) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child:
                  _DeviceCard(
                device: device,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colors.primary,
        ),

        const SizedBox(width: 8),

        Text(
          title,
          style: theme
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
        ),

        const SizedBox(width: 8),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          decoration:
              BoxDecoration(
            color: colors
                .surfaceContainerHighest,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: theme
                .textTheme
                .labelMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DEVICE CARD
// ============================================================

class _DeviceCard
    extends StatelessWidget {
  final NetworkDevice device;

  const _DeviceCard({
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.colorScheme;

    final isOnline =
        device.reachable;

    final hostname =
        device.hostName
                ?.trim()
                .isNotEmpty ==
            true
        ? device.hostName!
        : 'Unknown Device';

    final latency =
        device.latency != null
            ? '${device.latency} ms'
            : 'N/A';

    return GlassCard(
      child: LayoutBuilder(
        builder:
            (context, constraints) {
          final compact =
              constraints.maxWidth < 600;

          final icon =
              Container(
            width: 50,
            height: 50,
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
              color: isOnline
                  ? colors.primary
                      .withValues(
                      alpha: 0.10,
                    )
                  : colors.error
                      .withValues(
                      alpha: 0.08,
                    ),
            ),
            child: Icon(
              _deviceIcon(hostname),
              color: isOnline
                  ? colors.primary
                  : colors.error,
              size: 25,
            ),
          );

          final information =
              Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  hostname,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                ),

                const SizedBox(height: 5),

                Text(
                  device.ip,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: colors
                            .onSurfaceVariant,
                      ),
                ),

                if (!isOnline) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Host did not respond',
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color:
                              colors.error,
                        ),
                  ),
                ],
              ],
            ),
          );

          final status =
              Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment
                    .end,
            children: [
              StatusChip(
                label: isOnline
                    ? 'ONLINE'
                    : 'OFFLINE',
                status: isOnline
                    ? StatusType
                        .healthy
                    : StatusType
                        .error,
              ),

              const SizedBox(height: 5),

              Text(
                latency,
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      fontWeight:
                          FontWeight
                              .bold,
                      color: isOnline
                          ? colors
                              .primary
                          : colors
                              .error,
                    ),
              ),
            ],
          );

          if (compact) {
            return Column(
              children: [
                Row(
                  children: [
                    icon,
                    const SizedBox(
                      width: 14,
                    ),
                    information,
                  ],
                ),

                const SizedBox(
                  height: 14,
                ),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .end,
                  children: [
                    status,
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              icon,
              const SizedBox(
                width: 14,
              ),
              information,
              const SizedBox(
                width: 16,
              ),
              status,
            ],
          );
        },
      ),
    );
  }

  IconData _deviceIcon(
    String name,
  ) {
    final value =
        name.toLowerCase();

    if (value.contains('router') ||
        value.contains('gateway')) {
      return Icons
          .router_rounded;
    }

    if (value.contains('phone') ||
        value.contains('android') ||
        value.contains('iphone')) {
      return Icons
          .smartphone_rounded;
    }

    if (value.contains('laptop')) {
      return Icons
          .laptop_rounded;
    }

    if (value.contains('printer')) {
      return Icons
          .print_rounded;
    }

    if (value.contains('tv')) {
      return Icons.tv_rounded;
    }

    return Icons
        .devices_other_rounded;
  }
}