class SpeedTestResult {
  final double latencyMs;
  final double downloadSpeedMbps;
  final double uploadSpeedMbps;

  const SpeedTestResult({
    required this.latencyMs,
    required this.downloadSpeedMbps,
    required this.uploadSpeedMbps,
  });
}
