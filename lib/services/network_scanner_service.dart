import 'dart:io';

import '../models/network_device.dart';

class NetworkScannerService {
  Future<List<NetworkDevice>> scanSubnet(String subnet) async {
    final devices = <NetworkDevice>[];

    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';

      try {
        final result = await InternetAddress.lookup(ip);

        if (result.isNotEmpty) {
          devices.add(
            NetworkDevice(ip: ip, hostName: result.first.host, reachable: true),
          );
        }
      } catch (_) {}
    }

    return devices;
  }
}
