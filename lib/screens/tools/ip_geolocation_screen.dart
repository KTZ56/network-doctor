import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/ip_geolocation_result.dart';
import '../../providers/network_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/status_chip.dart';

class IpGeolocationScreen extends StatefulWidget {
  const IpGeolocationScreen({super.key});

  @override
  State<IpGeolocationScreen> createState() =>
      _IpGeolocationScreenState();
}

class _IpGeolocationScreenState
    extends State<IpGeolocationScreen> {
  final TextEditingController _inputController =
      TextEditingController(text: '1.1.1.1');

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _runLookup(NetworkProvider provider) {
    final input = _inputController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter an IP address or hostname.',
          ),
        ),
      );
      return;
    }

    provider.runIpGeolocationLookup(input);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkProvider>();
    final result = provider.ipGeolocationResult;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.public),
            SizedBox(width: 10),
            Text('IP Geolocation'),
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
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildSearchCard(context, provider),
                  const SizedBox(height: 24),
                  if (provider.testingIpGeolocation)
                    _buildLoadingCard(context),
                  if (result != null &&
                      !provider.testingIpGeolocation)
                    _ResultSection(result: result),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
          ),
          child: const Icon(
            Icons.public,
            color: Colors.white,
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
                'IP Geolocation',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Discover geographic and network information for an IP address.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard(
    BuildContext context,
    NetworkProvider provider,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          if (compact) {
            return Column(
              children: [
                _inputField(provider),
                const SizedBox(height: 12),
                _lookupButton(provider),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _inputField(provider)),
              const SizedBox(width: 12),
              _lookupButton(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _inputField(NetworkProvider provider) {
    return TextField(
      controller: _inputController,
      enabled: !provider.testingIpGeolocation,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) {
        if (!provider.testingIpGeolocation) {
          _runLookup(provider);
        }
      },
      decoration: InputDecoration(
        labelText: 'IP Address or Hostname',
        hintText: '1.1.1.1 or cloudflare.com',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _lookupButton(NetworkProvider provider) {
    return FilledButton.icon(
      onPressed: provider.testingIpGeolocation
          ? null
          : () => _runLookup(provider),
      icon: provider.testingIpGeolocation
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.location_searching),
      label: Text(
        provider.testingIpGeolocation
            ? 'Resolving...'
            : 'Lookup IP',
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Resolving IP information',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Contacting the geolocation service...',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final IpGeolocationResult result;

  const _ResultSection({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final success = result.success;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _ResultHeader(result: result),
        const SizedBox(height: 20),
        if (!success)
          _ErrorCard(message: result.message)
        else ...[
          Text(
            'Location',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _LocationGrid(result: result),
          const SizedBox(height: 24),
          Text(
            'Network Information',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _NetworkGrid(result: result),
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(result.message),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final IpGeolocationResult result;

  const _ResultHeader({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final success = result.success;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: success
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.15),
            ),
            child: Icon(
              success
                  ? Icons.check_circle
                  : Icons.error,
              color:
                  success ? Colors.green : Colors.red,
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
                  'Lookup Result',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.ip.isEmpty
                      ? 'Unknown IP'
                      : result.ip,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          StatusChip(
            label: success ? 'SUCCESS' : 'FAILED',
            status: success
                ? StatusType.healthy
                : StatusType.error,
          ),
        ],
      ),
    );
  }
}

class _LocationGrid extends StatelessWidget {
  final IpGeolocationResult result;

  const _LocationGrid({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 600
                    ? 2
                    : 1;

        return GridView(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.4,
          ),
          children: [
            MetricCard(
              title: 'Country',
              value: result.countryFlag.isEmpty
                  ? result.country
                  : '${result.country} ${result.countryFlag}',
              icon: Icons.public,
              color: Colors.blue,
            ),
            MetricCard(
              title: 'Country Code',
              value: result.countryCode,
              icon: Icons.flag,
              color: Colors.green,
            ),
            MetricCard(
              title: 'Continent',
              value: result.continent,
              icon: Icons.language,
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }
}

class _NetworkGrid extends StatelessWidget {
  final IpGeolocationResult result;

  const _NetworkGrid({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 600
                    ? 2
                    : 1;

        return GridView(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.4,
          ),
          children: [
            MetricCard(
              title: 'ASN',
              value: result.asNumber == null
                  ? 'Unknown'
                  : 'AS${result.asNumber}',
              icon: Icons.numbers,
              color: Colors.orange,
            ),
            MetricCard(
              title: 'Organization',
              value: result.organization,
              icon: Icons.business,
              color: Colors.cyan,
            ),
            MetricCard(
              title: 'BGP Prefix / CIDR',
              value:
                  result.cidr ?? 'Not available',
              icon: Icons.account_tree,
              color: Colors.pink,
            ),
          ],
        );
      },
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Lookup Failed',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
          const StatusChip(
            label: 'ERROR',
            status: StatusType.error,
          ),
        ],
      ),
    );
  }
}