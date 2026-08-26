class IpGeolocationResult {
  final bool success;
  final String ip;
  final String countryCode;
  final String country;
  final String countryFlag;
  final String continent;
  final int? asNumber;
  final String organization;
  final String? cidr;
  final String message;

  const IpGeolocationResult({
    required this.success,
    required this.ip,
    required this.countryCode,
    required this.country,
    required this.countryFlag,
    required this.continent,
    required this.asNumber,
    required this.organization,
    required this.cidr,
    required this.message,
  });

  factory IpGeolocationResult.fromJson(
    Map<String, dynamic> json,
  ) {
    final error = json['error'];

    return IpGeolocationResult(
      success: error == null,
      ip: json['ip']?.toString() ?? 'Unknown',
      countryCode:
          json['country_code']?.toString() ?? 'Unknown',
      country:
          json['country']?.toString() ?? 'Unknown',
      countryFlag:
          json['country_flag']?.toString() ?? '',
      continent:
          json['continent']?.toString() ?? 'Unknown',
      asNumber:
          json['as_number'] is num
              ? (json['as_number'] as num).toInt()
              : null,
      organization:
          json['as_description']?.toString() ?? 'Unknown',
      cidr: json['cidr']?.toString(),
      message: error == null
          ? 'IP geolocation lookup completed successfully.'
          : error.toString(),
    );
  }

  factory IpGeolocationResult.failure({
    required String ip,
    required String message,
  }) {
    return IpGeolocationResult(
      success: false,
      ip: ip,
      countryCode: 'Unknown',
      country: 'Unknown',
      countryFlag: '',
      continent: 'Unknown',
      asNumber: null,
      organization: 'Unknown',
      cidr: null,
      message: message,
    );
  }
}