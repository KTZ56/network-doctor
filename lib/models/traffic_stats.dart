class TrafficStats {
  final String interfaceName;
  final int receivedBytes;
  final int sentBytes;
  final double downloadMbps;
  final double uploadMbps;
  final DateTime timestamp;

  const TrafficStats({
    required this.interfaceName,
    required this.receivedBytes,
    required this.sentBytes,
    required this.downloadMbps,
    required this.uploadMbps,
    required this.timestamp,
  });

  factory TrafficStats.empty({
    String interfaceName = 'Unknown',
  }) {
    return TrafficStats(
      interfaceName: interfaceName,
      receivedBytes: 0,
      sentBytes: 0,
      downloadMbps: 0,
      uploadMbps: 0,
      timestamp: DateTime.now(),
    );
  }
}