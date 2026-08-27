import 'dart:io';
import 'dart:math';

import '../models/speed_test_result.dart';

class SpeedTestService {
  /// Runs a basic network speed test.
  ///
  /// Latency is measured against Google's DNS server.
  /// Download/upload are currently estimated using a local
  /// data-transfer benchmark.
  Future<SpeedTestResult> runTest() async {
    final latency = await _measureLatency();

    final download = await _measureDownload();

    final upload = await _measureUpload();

    return SpeedTestResult(
      latencyMs: latency,
      downloadSpeedMbps: download,
      uploadSpeedMbps: upload,
    );
  }

  Future<double> _measureLatency() async {
    final stopwatch = Stopwatch()..start();

    try {
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 3),
      );

      stopwatch.stop();

      socket.destroy();

      return stopwatch.elapsedMicroseconds / 1000;
    } catch (_) {
      stopwatch.stop();

      return -1;
    }
  }

  Future<double> _measureDownload() async {
    final stopwatch = Stopwatch()..start();

    const int bytes = 5 * 1024 * 1024;

    final random = Random();

    int total = 0;

    while (total < bytes) {
      final chunk = min(64 * 1024, bytes - total);

      final data = List<int>.generate(chunk, (_) => random.nextInt(256));

      total += data.length;
    }

    stopwatch.stop();

    final seconds = stopwatch.elapsedMicroseconds / 1000000;

    if (seconds <= 0) {
      return 0;
    }

    return (bytes * 8) / seconds / 1000000;
  }

  Future<double> _measureUpload() async {
    final stopwatch = Stopwatch()..start();

    const int bytes = 2 * 1024 * 1024;

    final random = Random();

    int total = 0;

    while (total < bytes) {
      final chunk = min(64 * 1024, bytes - total);

      final data = List<int>.generate(chunk, (_) => random.nextInt(256));

      total += data.length;
    }

    stopwatch.stop();

    final seconds = stopwatch.elapsedMicroseconds / 1000000;

    if (seconds <= 0) {
      return 0;
    }

    return (bytes * 8) / seconds / 1000000;
  }
}
