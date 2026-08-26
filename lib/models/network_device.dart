class NetworkDevice {
  final String ip;
  final String? hostName;
  final String? macAddress;
  final bool reachable;
  final int? latency;

  const NetworkDevice({
    required this.ip,
    this.hostName,
    this.macAddress,
    required this.reachable,
    this.latency,
  });
}
