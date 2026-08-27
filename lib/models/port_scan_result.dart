class PortResult {
  final int port;
  final bool open;

  const PortResult({required this.port, required this.open});
}

class PortScanResult {
  final String host;
  final List<PortResult> ports;

  const PortScanResult({required this.host, required this.ports});

  int get openCount => ports.where((p) => p.open).length;
}
