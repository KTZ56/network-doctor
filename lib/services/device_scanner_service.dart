import 'dart:async';
import 'dart:io';

import '../models/network_device.dart';

class DeviceScannerService {
  bool _cancelRequested = false;

  static const int _totalHosts = 254;
  static const int _pingTimeoutMs = 200;
  static const int _defaultBatchSize = 20;

  /// Cancel the current scan.
  void cancelScan() {
    _cancelRequested = true;
  }

  /// Scan a /24 subnet.
  ///
  /// Example:
  /// 192.168.1
  ///
  /// Scans:
  /// 192.168.1.1 - 192.168.1.254
  ///
  /// Every scanned IP is returned:
  /// - reachable = true  -> ONLINE
  /// - reachable = false -> OFFLINE
  Future<List<NetworkDevice>> scanSubnet(
    String subnet, {
    void Function(int completed, int total)? onProgress,
    int batchSize = _defaultBatchSize,
  }) async {
    _cancelRequested = false;

    final devices = <NetworkDevice>[];
    var completed = 0;

    final safeBatchSize = batchSize.clamp(1, _totalHosts);

    for (int start = 1; start <= _totalHosts; start += safeBatchSize) {
      if (_cancelRequested) {
        break;
      }

      final end = (start + safeBatchSize - 1).clamp(1, _totalHosts);

      final futures = <Future<NetworkDevice>>[];

      for (int i = start; i <= end; i++) {
        if (_cancelRequested) {
          break;
        }

        final ip = '$subnet.$i';

        futures.add(_scanHost(ip));
      }

      final results = await Future.wait(futures);

      for (final device in results) {
        devices.add(device);

        completed++;

        onProgress?.call(completed, _totalHosts);
      }
    }

    devices.sort((a, b) {
      // Online devices first.
      if (a.reachable != b.reachable) {
        return a.reachable ? -1 : 1;
      }

      // Within the same status, sort by IP address.
      return _compareIpAddresses(a.ip, b.ip);
    });

    return devices;
  }

  // ============================================================
  // SCAN SINGLE HOST
  // ============================================================

  Future<NetworkDevice> _scanHost(String ip) async {
    try {
      final result = await Process.run('ping', [
        '-n',
        '1',
        '-w',
        '$_pingTimeoutMs',
        ip,
      ]);

      if (_cancelRequested) {
        return NetworkDevice(
          ip: ip,
          hostName: null,
          reachable: false,
          latency: null,
        );
      }

      final output = result.stdout.toString();
      final error = result.stderr.toString();

      final combinedOutput = '$output\n$error';

      final reachable =
          combinedOutput.contains('TTL=') || combinedOutput.contains('ttl=');

      // --------------------------------------------------------
      // OFFLINE DEVICE
      // --------------------------------------------------------

      if (!reachable) {
        return NetworkDevice(
          ip: ip,
          hostName: null,
          reachable: false,
          latency: null,
        );
      }

      // --------------------------------------------------------
      // ONLINE DEVICE
      // --------------------------------------------------------

      final latency = _extractLatency(combinedOutput);

      return NetworkDevice(
        ip: ip,
        hostName: null,
        reachable: true,
        latency: latency,
      );
    } catch (_) {
      // If the ping process fails, still record
      // the IP as offline instead of removing it.

      return NetworkDevice(
        ip: ip,
        hostName: null,
        reachable: false,
        latency: null,
      );
    }
  }

  // ============================================================
  // EXTRACT PING LATENCY
  // ============================================================

  int? _extractLatency(String output) {
    final match = RegExp(
      r'time[=<]\s*(\d+)\s*ms',
      caseSensitive: false,
    ).firstMatch(output);

    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(1)!);
  }

  // ============================================================
  // OPTIONAL HOSTNAME LOOKUP
  // ============================================================

  Future<String?> resolveHostName(String ip) async {
    try {
      final result = await Process.run('ping', [
        '-a',
        '-n',
        '1',
        '-w',
        '200',
        ip,
      ]);

      final output = result.stdout.toString();

      final match = RegExp(
        r'Pinging\s+([^\s\[]+)\s+\[',
        caseSensitive: false,
      ).firstMatch(output);

      if (match != null) {
        return match.group(1);
      }
    } catch (_) {}

    return null;
  }

  // ============================================================
  // SORT IP ADDRESSES NUMERICALLY
  // ============================================================

  int _compareIpAddresses(String a, String b) {
    final aParts = a.split('.').map(int.parse).toList();

    final bParts = b.split('.').map(int.parse).toList();

    for (int i = 0; i < 4; i++) {
      final comparison = aParts[i].compareTo(bParts[i]);

      if (comparison != 0) {
        return comparison;
      }
    }

    return 0;
  }
}
