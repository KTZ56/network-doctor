class PingResult {
  final String target;
  final bool success;
  final int? latency;
  final String message;

  const PingResult({
    required this.target,
    required this.success,
    required this.latency,
    required this.message,
  });
}