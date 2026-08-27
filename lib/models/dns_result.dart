class DnsResult {
  final String hostname;
  final bool success;
  final String? ipv4;
  final String? ipv6;
  final String message;
  final int durationMs;

  const DnsResult({
    required this.hostname,
    required this.success,
    required this.ipv4,
    required this.ipv6,
    required this.message,
    required this.durationMs,
  });
}
