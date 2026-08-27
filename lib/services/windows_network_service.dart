import 'dart:io';

import '../models/network_info.dart';

class WindowsNetworkService {
  Future<NetworkInfo> getNetworkInfo() async {
    final result = await Process.run('ipconfig', ['/all'], runInShell: true);

    if (result.exitCode != 0) {
      throw Exception('Unable to read Windows network configuration.');
    }

    final output = result.stdout.toString();

    return _parseNetworkInfo(output);
  }

  NetworkInfo _parseNetworkInfo(String output) {
    final adapters = _parseAdapters(output);

    _AdapterInfo? activeAdapter;

    // Prefer the adapter that has both IPv4 and gateway.
    for (final adapter in adapters) {
      if (adapter.ipv4 != null &&
          adapter.gateway != null &&
          adapter.ipv4 != '127.0.0.1') {
        activeAdapter = adapter;
        break;
      }
    }

    // Fallback: adapter with an IPv4 address.
    activeAdapter ??= _findAdapterWithIpv4(adapters);

    if (activeAdapter == null) {
      return const NetworkInfo(
        interfaceName: 'Unknown',
        ipv4: 'Unknown',
        subnetMask: 'Unknown',
        gateway: 'Unknown',
        dns: 'Unknown',
        macAddress: 'Unknown',
        dhcpEnabled: false,
      );
    }

    return NetworkInfo(
      interfaceName: activeAdapter.name ?? 'Unknown',
      ipv4: activeAdapter.ipv4 ?? 'Unknown',
      subnetMask: activeAdapter.subnetMask ?? 'Unknown',
      gateway: activeAdapter.gateway ?? 'Unknown',
      dns: activeAdapter.dns ?? 'Unknown',
      macAddress: activeAdapter.macAddress ?? 'Unknown',
      dhcpEnabled: activeAdapter.dhcpEnabled,
    );
  }

  _AdapterInfo? _findAdapterWithIpv4(List<_AdapterInfo> adapters) {
    for (final adapter in adapters) {
      if (adapter.ipv4 != null && adapter.ipv4 != '127.0.0.1') {
        return adapter;
      }
    }

    return null;
  }

  List<_AdapterInfo> _parseAdapters(String output) {
    final lines = output.split(RegExp(r'\r?\n'));

    final adapters = <_AdapterInfo>[];

    _AdapterInfo? current;

    for (final rawLine in lines) {
      final line = rawLine.trim();

      if (line.isEmpty) {
        continue;
      }

      // Detect Windows adapter sections.
      final headerMatch = RegExp(
        r'^(Ethernet adapter|Wireless LAN adapter|Bluetooth Network Connection adapter|Tunnel adapter)\s+(.+):$',
        caseSensitive: false,
      ).firstMatch(line);

      if (headerMatch != null) {
        if (current != null) {
          adapters.add(current);
        }

        current = _AdapterInfo(name: headerMatch.group(2)?.trim());

        continue;
      }

      if (current == null) {
        continue;
      }

      // Physical Address
      if (line.startsWith('Physical Address')) {
        current.macAddress = _value(line);
        continue;
      }

      // DHCP
      if (line.startsWith('DHCP Enabled')) {
        current.dhcpEnabled = line.toLowerCase().contains('yes');
        continue;
      }

      // IPv4 Address
      if (line.startsWith('IPv4 Address')) {
        current.ipv4 = _cleanValue(_value(line));
        continue;
      }

      // Subnet Mask
      if (line.startsWith('Subnet Mask')) {
        current.subnetMask = _cleanValue(_value(line));
        continue;
      }

      // Default Gateway
      if (line.startsWith('Default Gateway')) {
        final value = _cleanValue(_value(line));

        if (value.isNotEmpty) {
          current.gateway = value;
        }

        continue;
      }

      // DNS Servers
      if (line.startsWith('DNS Servers')) {
        final value = _cleanValue(_value(line));

        if (value.isNotEmpty) {
          current.dns = value;
        }

        continue;
      }
    }

    if (current != null) {
      adapters.add(current);
    }

    return adapters;
  }

  String _value(String line) {
    final index = line.indexOf(':');

    if (index == -1) {
      return '';
    }

    return line.substring(index + 1).trim();
  }

  String _cleanValue(String value) {
    return value
        .replaceAll(RegExp(r'\s*\(Preferred\)', caseSensitive: false), '')
        .trim();
  }
}

class _AdapterInfo {
  String? name;
  String? ipv4;
  String? subnetMask;
  String? gateway;
  String? dns;
  String? macAddress;

  bool dhcpEnabled = false;

  _AdapterInfo({this.name});
}
