import 'dart:io';

import '../models/ping_result.dart';

class PingService {
  Future<PingResult> ping(String target) async {
    try {
      final result = await Process.run(
        'ping',
        ['-n', '4', target],
        runInShell: true,
      );

      final output = result.stdout.toString();

      if (result.exitCode != 0) {
        return PingResult(
          target: target,
          success: false,
          latency: null,
          message: 'Host unreachable',
        );
      }

      final latency = _extractAverageLatency(output);

      return PingResult(
        target: target,
        success: true,
        latency: latency,
        message: latency != null
            ? 'Average latency: $latency ms'
            : 'Host reachable',
      );
    } catch (e) {
      return PingResult(
        target: target,
        success: false,
        latency: null,
        message: e.toString(),
      );
    }
  }

  int? _extractAverageLatency(String output) {
    final regex = RegExp(
      r'Average = (\d+)ms',
      caseSensitive: false,
    );

    final match = regex.firstMatch(output);

    if (match == null) {
      return null;
    }

    return int.tryParse(match.group(1)!);
  }
}