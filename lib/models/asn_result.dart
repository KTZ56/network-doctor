class AsnPrefix {
  final String cidr;
  final String countryCode;
  final String country;
  final String continent;

  const AsnPrefix({
    required this.cidr,
    required this.countryCode,
    required this.country,
    required this.continent,
  });

  factory AsnPrefix.fromJson(
    Map<String, dynamic> json,
  ) {
    return AsnPrefix(
      cidr: json['cidr']?.toString() ?? 'Unknown',
      countryCode:
          json['country_code']?.toString() ?? 'Unknown',
      country:
          json['country']?.toString() ?? 'Unknown',
      continent:
          json['continent']?.toString() ?? 'Unknown',
    );
  }
}

class AsnResult {
  final bool success;
  final int? asNumber;
  final String organization;
  final int ipv4Count;
  final int ipv6PrefixCount;
  final List<AsnPrefix> cidrs;
  final String message;

  const AsnResult({
    required this.success,
    required this.asNumber,
    required this.organization,
    required this.ipv4Count,
    required this.ipv6PrefixCount,
    required this.cidrs,
    required this.message,
  });

  factory AsnResult.fromJson(
    Map<String, dynamic> json,
  ) {
    final error = json['error'];

    final cidrData =
        json['cidrs'] as List? ?? [];

    return AsnResult(
      success: error == null,
      asNumber: json['as_number'] is num
          ? (json['as_number'] as num).toInt()
          : null,
      organization:
          json['as_description']?.toString() ?? 'Unknown',
      ipv4Count: json['ipv4_count'] is num
          ? (json['ipv4_count'] as num).toInt()
          : 0,
      ipv6PrefixCount:
          json['ipv6_prefix_count'] is num
              ? (json['ipv6_prefix_count'] as num).toInt()
              : 0,
      cidrs: cidrData
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => AsnPrefix.fromJson(item),
          )
          .toList(),
      message: error == null
          ? 'ASN lookup completed successfully.'
          : error.toString(),
    );
  }

  factory AsnResult.failure({
    required String message,
  }) {
    return AsnResult(
      success: false,
      asNumber: null,
      organization: 'Unknown',
      ipv4Count: 0,
      ipv6PrefixCount: 0,
      cidrs: const [],
      message: message,
    );
  }
}