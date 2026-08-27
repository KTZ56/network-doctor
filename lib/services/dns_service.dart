import 'dart:io';

import '../models/dns_result.dart';

class DnsService {
  Future<DnsResult> lookup(String hostname) async {
    final stopwatch = Stopwatch()..start();

    try {
      final addresses = await InternetAddress.lookup(hostname);

      stopwatch.stop();

      if (addresses.isEmpty) {
        return DnsResult(
          hostname: hostname,
          success: false,
          ipv4: null,
          ipv6: null,
          message: 'No DNS records found.',
          durationMs: stopwatch.elapsedMilliseconds,
        );
      }

      String? ipv4;
      String? ipv6;

      for (final address in addresses) {
        if (address.type == InternetAddressType.IPv4) {
          ipv4 ??= address.address;
        }

        if (address.type == InternetAddressType.IPv6) {
          ipv6 ??= address.address;
        }
      }

      return DnsResult(
        hostname: hostname,
        success: true,
        ipv4: ipv4,
        ipv6: ipv6,
        message: 'DNS resolution successful.',
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();

      return DnsResult(
        hostname: hostname,
        success: false,
        ipv4: null,
        ipv6: null,
        message: 'DNS lookup failed: $e',
        durationMs: stopwatch.elapsedMilliseconds,
      );
    }
  }
}
