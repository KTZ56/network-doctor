class WhoisResult {
  final bool success;

  final String domain;

  final String registrar;

  final String creationDate;

  final String expiryDate;

  final List<String> nameServers;

  final String message;

  const WhoisResult({
    required this.success,
    required this.domain,
    required this.registrar,
    required this.creationDate,
    required this.expiryDate,
    required this.nameServers,
    required this.message,
  });

  factory WhoisResult.failure({
    required String domain,
    required String message,
  }) {
    return WhoisResult(
      success: false,
      domain: domain,
      registrar: 'Unknown',
      creationDate: 'Unknown',
      expiryDate: 'Unknown',
      nameServers: const [],
      message: message,
    );
  }


  factory WhoisResult.fromJson(
  Map<String, dynamic> json,
) {
  return WhoisResult(
    success: true,
    domain: json['domainName'] ?? '',
    registrar: json['registrarName'] ?? 'Unknown',
    creationDate:
        json['createdDate'] ?? 'Unknown',
    expiryDate:
        json['expiresDate'] ?? 'Unknown',
    nameServers:
        List<String>.from(
      json['nameServers'] ?? [],
    ),
    message:
        'WHOIS lookup completed successfully.',
  );
}
}

