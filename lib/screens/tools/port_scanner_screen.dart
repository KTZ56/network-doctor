import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/network_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_chip.dart';

class PortScannerScreen extends StatefulWidget {
  const PortScannerScreen({super.key});

  @override
  State<PortScannerScreen> createState() => _PortScannerScreenState();
}

class _PortScannerScreenState extends State<PortScannerScreen> {
  final _hostController = TextEditingController(text: '8.8.8.8');

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();

    final result = provider.portScanResult;

    final openPorts = result == null
        ? 0
        : result.ports.where((port) => port.open).length;

    final closedPorts = result == null
        ? 0
        : result.ports.where((port) => !port.open).length;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.hub),
            SizedBox(width: 10),
            Text('Port Scanner'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              const SizedBox(height: 24),

              _buildTargetCard(context, provider),

              const SizedBox(height: 24),

              if (provider.portScanning)
                _buildScanningCard(context),

              if (result != null) ...[
                _buildStats(
                  context,
                  total: result.ports.length,
                  open: openPorts,
                  closed: closedPorts,
                ),

                const SizedBox(height: 24),

                _buildResults(context, result),
              ],

              if (!provider.portScanning && result == null)
                _buildEmptyState(context),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ),
          ),
          child: Icon(
            Icons.radar,
            color: colorScheme.onPrimary,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Port Scanner',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Inspect TCP ports and identify accessible services.',
                style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildTargetCard(
    BuildContext context,
    NetworkProvider provider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.dns,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Target',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Enter an IP address or hostname.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    TextField(
                      controller: _hostController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Host',
                        hintText: '192.168.1.1',
                        prefixIcon: Icon(Icons.language),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _buildScanButton(provider),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hostController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Host',
                        hintText: '192.168.1.1',
                        prefixIcon: Icon(Icons.language),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildScanButton(provider),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(NetworkProvider provider) {
    return FilledButton.icon(
      onPressed: provider.portScanning
          ? null
          : () {
              final host = _hostController.text.trim();

              if (host.isNotEmpty) {
                provider.runPortScan(host);
              }
            },
      icon: provider.portScanning
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.search),
      label: Text(
        provider.portScanning ? 'Scanning...' : 'Scan Ports',
      ),
    );
  }

  // ============================================================
  // SCANNING
  // ============================================================

  Widget _buildScanningCard(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Scanning ports...',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Checking the target for accessible ports.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStats(
    BuildContext context, {
    required int total,
    required int open,
    required int closed,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _StatData(
            title: 'Ports Scanned',
            value: '$total',
            icon: Icons.hub,
          ),
          _StatData(
            title: 'Open',
            value: '$open',
            icon: Icons.lock_open,
          ),
          _StatData(
            title: 'Closed',
            value: '$closed',
            icon: Icons.lock,
          ),
        ];

        if (constraints.maxWidth < 600) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StatCard(data: card),
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _StatCard(data: card),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  // ============================================================
  // RESULTS
  // ============================================================

  Widget _buildResults(
    BuildContext context,
    dynamic result,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scan Results',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        GlassCard(
          child: Column(
            children: [
              ...result.ports.map(
                (port) => _PortResultRow(port: port),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.radar,
                size: 56,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Ready to Scan',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter a target above and start a port scan.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PORT RESULT ROW
// ============================================================

class _PortResultRow extends StatelessWidget {
  final dynamic port;

  const _PortResultRow({
    required this.port,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = port.open;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isOpen
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.red.withValues(alpha: 0.10),
            ),
            child: Icon(
              isOpen ? Icons.lock_open : Icons.lock,
              color: isOpen ? Colors.green : Colors.red,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Port ${port.port}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isOpen ? 'Port is accessible' : 'Port is closed',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          StatusChip(
            label: isOpen ? 'OPEN' : 'CLOSED',
            status: isOpen
                ? StatusType.healthy
                : StatusType.error,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatData {
  final String title;
  final String value;
  final IconData icon;

  const _StatData({
    required this.title,
    required this.value,
    required this.icon,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;

  const _StatCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              data.icon,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 3),
              Text(
                data.value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}