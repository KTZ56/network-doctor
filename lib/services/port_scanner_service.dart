import 'dart:io';

import '../models/port_scan_result.dart';

class PortScannerService {
  Future<PortScanResult> scan(
    String host,
  ) async {
    final commonPorts = [
      20,
      21,
      22,
      23,
      25,
      53,
      80,
      110,
      143,
      443,
      3389,
    ];

    final results = <PortResult>[];

    for (final port in commonPorts) {
      bool open = false;

      try {
        final socket =
            await Socket.connect(
          host,
          port,
          timeout: const Duration(
            seconds: 1,
          ),
        );

        open = true;

        await socket.close();
      } catch (_) {
        open = false;
      }

      results.add(
        PortResult(
          port: port,
          open: open,
        ),
      );
    }

    return PortScanResult(
      host: host,
      ports: results,
    );
  }
}