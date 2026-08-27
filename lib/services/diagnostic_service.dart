import '../models/diagnosis.dart';
import '../models/dns_result.dart';
import '../models/ping_result.dart';

class DiagnosticService {
  Diagnosis analyze({
    required PingResult? gateway,
    required PingResult? internet,
    required DnsResult? dns,
  }) {
    // --------------------------------------------------------
    // NO RESULTS
    // --------------------------------------------------------

    if (gateway == null || internet == null || dns == null) {
      return const Diagnosis(
        level: DiagnosisLevel.warning,
        title: 'Diagnostics Incomplete',
        message: 'Network testing has not completed yet.',
        recommendations: ['Run the network test again.'],
      );
    }

    // --------------------------------------------------------
    // GATEWAY FAILURE
    // --------------------------------------------------------

    if (!gateway.success) {
      return const Diagnosis(
        level: DiagnosisLevel.critical,
        title: 'Local Network Failure',
        message: 'Your computer cannot reach the default gateway.',
        recommendations: [
          'Check the Ethernet cable or Wi-Fi connection.',
          'Check the switch port.',
          'Check the VLAN configuration.',
          'Check the computer IP address.',
          'Check the default gateway.',
          'Check the router.',
        ],
      );
    }

    // --------------------------------------------------------
    // INTERNET FAILURE
    // --------------------------------------------------------

    if (!internet.success) {
      return const Diagnosis(
        level: DiagnosisLevel.critical,
        title: 'Internet Connectivity Failure',
        message:
            'Your local network is working, but the Internet cannot be reached.',
        recommendations: [
          'Check the router WAN connection.',
          'Check the ISP connection.',
          'Check firewall rules.',
          'Check whether the ISP is experiencing an outage.',
        ],
      );
    }

    // --------------------------------------------------------
    // DNS FAILURE
    // --------------------------------------------------------

    if (!dns.success) {
      return const Diagnosis(
        level: DiagnosisLevel.warning,
        title: 'DNS Resolution Failure',
        message:
            'Internet connectivity is working, but domain names cannot be resolved.',
        recommendations: [
          'Check the configured DNS server.',
          'Try another DNS server.',
          'Check the router DNS configuration.',
          'Test DNS using nslookup.',
        ],
      );
    }

    // --------------------------------------------------------
    // EVERYTHING OK
    // --------------------------------------------------------

    return const Diagnosis(
      level: DiagnosisLevel.healthy,
      title: 'Network Healthy',
      message:
          'Your local network, Internet connection, and DNS are working correctly.',
      recommendations: ['No action required.'],
    );
  }
}
