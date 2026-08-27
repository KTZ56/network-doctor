import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/traffic_stats.dart';

class TrafficMonitorService {
  int? _previousReceivedBytes;
  int? _previousSentBytes;
  DateTime? _previousTimestamp;

  bool _running = false;

  void stop() {
    _running = false;
  }

  Stream<TrafficStats> monitor(
    String interfaceName, {
    Duration interval = const Duration(seconds: 1),
  }) async* {
    _running = true;

    _previousReceivedBytes = null;
    _previousSentBytes = null;
    _previousTimestamp = null;

    while (_running) {
      final stats = await _readStats(interfaceName);

      if (stats != null) {
        yield stats;
      }

      await Future.delayed(interval);
    }
  }

  Future<TrafficStats?> _readStats(String interfaceName) async {
    try {
      final escapedName = interfaceName.replaceAll("'", "''");

      final command =
          '''
\$stats = Get-NetAdapterStatistics -Name '$escapedName' -ErrorAction Stop |
  Select-Object -First 1 ReceivedBytes,SentBytes;
\$stats | ConvertTo-Json -Compress
''';

      final result = await Process.run('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        command,
      ], runInShell: true);

      if (result.exitCode != 0) {
        return null;
      }

      final output = result.stdout.toString().trim();

      if (output.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(output) as Map<String, dynamic>;

      final received = (decoded['ReceivedBytes'] as num?)?.toInt() ?? 0;

      final sent = (decoded['SentBytes'] as num?)?.toInt() ?? 0;

      final now = DateTime.now();

      double downloadMbps = 0;
      double uploadMbps = 0;

      if (_previousReceivedBytes != null &&
          _previousSentBytes != null &&
          _previousTimestamp != null) {
        final elapsed = now.difference(_previousTimestamp!);

        final seconds = elapsed.inMicroseconds / 1000000;

        if (seconds > 0) {
          final receivedDelta = received - _previousReceivedBytes!;

          final sentDelta = sent - _previousSentBytes!;

          if (receivedDelta >= 0) {
            downloadMbps = (receivedDelta * 8) / seconds / 1000000;
          }

          if (sentDelta >= 0) {
            uploadMbps = (sentDelta * 8) / seconds / 1000000;
          }
        }
      }

      _previousReceivedBytes = received;
      _previousSentBytes = sent;
      _previousTimestamp = now;

      return TrafficStats(
        interfaceName: interfaceName,
        receivedBytes: received,
        sentBytes: sent,
        downloadMbps: downloadMbps,
        uploadMbps: uploadMbps,
        timestamp: now,
      );
    } catch (_) {
      return null;
    }
  }
}
