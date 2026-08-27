class NetworkInfo {
  final String interfaceName;
  final String ipv4;
  final String subnetMask;
  final String gateway;
  final String dns;
  final String macAddress;
  final bool dhcpEnabled;

  const NetworkInfo({
    required this.interfaceName,
    required this.ipv4,
    required this.subnetMask,
    required this.gateway,
    required this.dns,
    required this.macAddress,
    required this.dhcpEnabled,
  });
}
