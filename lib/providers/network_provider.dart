import 'package:flutter/foundation.dart';

import '../models/asn_result.dart';
import '../models/diagnosis.dart';
import '../models/dns_result.dart';
import '../models/ip_geolocation_result.dart';
import '../models/network_device.dart';
import '../models/network_info.dart';
import '../models/ping_result.dart';
import '../models/port_scan_result.dart';
import '../models/speed_test_result.dart';
import '../models/traceroute_result.dart';
import '../models/whois_result.dart';

import '../services/asn_service.dart';
import '../services/device_scanner_service.dart';
import '../services/diagnostic_service.dart';
import '../services/dns_service.dart';
import '../services/ip_geolocation_service.dart';
import '../services/ping_service.dart';
import '../services/port_scanner_service.dart';
import '../services/speed_test_service.dart';
import '../services/traceroute_service.dart';
import '../services/whois_service.dart';
import '../services/windows_network_service.dart';
import '../models/traffic_stats.dart';
import '../services/traffic_monitor_service.dart';


class NetworkProvider extends ChangeNotifier {
  // Services
  final WindowsNetworkService _windowsNetworkService = WindowsNetworkService();
  final PingService _pingService = PingService();
  final DnsService _dnsService = DnsService();
  final DiagnosticService _diagnosticService = DiagnosticService();
  final TracerouteService _tracerouteService = TracerouteService();
  final PortScannerService _portScannerService = PortScannerService();
  final SpeedTestService _speedTestService = SpeedTestService();
  final WhoisService _whoisService = WhoisService();
  final IpGeolocationService _ipGeolocationService = IpGeolocationService();
  final AsnService _asnService = AsnService();
  final DeviceScannerService _deviceScannerService = DeviceScannerService();
  final TrafficMonitorService _trafficMonitorService =
    TrafficMonitorService();


  // Network State
  NetworkInfo? networkInfo;
  bool loading = false;
  bool testing = false;
  String? error;

  // Test Results & Flags
  AsnResult? asnResult;
  bool testingAsn = false;

  IpGeolocationResult? ipGeolocationResult;
  bool testingIpGeolocation = false;

  WhoisResult? whoisResult;
  bool testingWhois = false;

  PingResult? gatewayPing;
  PingResult? internetPing;
  DnsResult? dnsResult;
  Diagnosis? diagnosis;

  TracerouteResult? tracerouteResult;
  bool tracerouteTesting = false;

  PortScanResult? portScanResult;
  bool portScanning = false;

  PingResult? pingTestResult;
  bool testingPing = false;

  SpeedTestResult? speedTestResult;
  bool testingSpeed = false;

  List<NetworkDevice> devices = [];
  bool scanningDevices = false;

  TrafficStats? trafficStats;

bool monitoringTraffic = false;

final List<double> downloadHistory = [];
final List<double> uploadHistory = [];

  DnsResult? dnsLookupResult;
  bool testingDnsLookup = false;

int deviceScanCompleted = 0;
int deviceScanTotal = 254;

  // Actions
  Future<void> loadNetworkInfo() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      networkInfo = await _windowsNetworkService.getNetworkInfo();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> runAsnLookup(String input) async {
    final query = input.trim();
    if (query.isEmpty) return;

    testingAsn = true;
    asnResult = null;
    error = null;
    notifyListeners();

    try {
      asnResult = await _asnService.lookup(query);
    } catch (e) {
      asnResult = AsnResult.failure(message: e.toString());
    } finally {
      testingAsn = false;
      notifyListeners();
    }
  }

  Future<void> runIpGeolocationLookup(String input) async {
    final query = input.trim();
    if (query.isEmpty) return;

    testingIpGeolocation = true;
    ipGeolocationResult = null;
    error = null;
    notifyListeners();

    try {
      ipGeolocationResult = await _ipGeolocationService.lookup(query);
    } catch (e) {
      ipGeolocationResult = IpGeolocationResult.failure(
        ip: query,
        message: e.toString(),
      );
    } finally {
      testingIpGeolocation = false;
      notifyListeners();
    }
  }

  Future<void> runWhoisLookup(String domain) async {
    final query = domain.trim();
    if (query.isEmpty) return;

    testingWhois = true;
    whoisResult = null;
    notifyListeners();

    try {
      whoisResult = await _whoisService.lookup(query);
    } catch (e) {
      whoisResult = WhoisResult.failure(domain: query, message: e.toString());
    } finally {
      testingWhois = false;
      notifyListeners();
    }
  }

  Future<void> runDnsLookup(String hostname) async {
    final host = hostname.trim();
    if (host.isEmpty) return;

    testingDnsLookup = true;
    dnsLookupResult = null;
    error = null;
    notifyListeners();

    try {
      dnsLookupResult = await _dnsService.lookup(host);
    } catch (e) {
      error = e.toString();
    } finally {
      testingDnsLookup = false;
      notifyListeners();
    }
  }

  Future<void> runSpeedTest() async {
    testingSpeed = true;
    speedTestResult = null;
    error = null;
    notifyListeners();

    try {
      speedTestResult = await _speedTestService.runTest();
    } catch (e) {
      error = e.toString();
    } finally {
      testingSpeed = false;
      notifyListeners();
    }
  }

  Future<void> runPingTest(String host) async {
    testingPing = true;
    pingTestResult = null;
    notifyListeners();

    try {
      pingTestResult = await _pingService.ping(host);
    } catch (e) {
      pingTestResult = PingResult(
        target: host,
        success: false,
        latency: null,
        message: e.toString(),
      );
    } finally {
      testingPing = false;
      notifyListeners();
    }
  }

  Future<void> runPortScan(String host) async {
    portScanning = true;
    portScanResult = null;
    notifyListeners();

    try {
      portScanResult = await _portScannerService.scan(host);
    } catch (e) {
      error = e.toString();
    } finally {
      portScanning = false;
      notifyListeners();
    }
  }

  Future<void> runConnectivityTest() async {
    if (networkInfo == null) {
      await loadNetworkInfo();
    }
    if (networkInfo == null) return;

    testing = true;
    error = null;
    gatewayPing = null;
    internetPing = null;
    dnsResult = null;
    diagnosis = null;
    notifyListeners();

    try {
      gatewayPing = await _pingService.ping(networkInfo!.gateway);
      notifyListeners();

      internetPing = await _pingService.ping('8.8.8.8');
      notifyListeners();

      dnsResult = await _dnsService.lookup('google.com');
      notifyListeners();

      diagnosis = _diagnosticService.analyze(
        gateway: gatewayPing,
        internet: internetPing,
        dns: dnsResult,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      testing = false;
      notifyListeners();
    }
  }
Future<void> scanDevices() async {
  if (scanningDevices) return;

  final info = networkInfo;

  if (info == null || info.ipv4.isEmpty) {
    error = 'Network information is not available.';
    notifyListeners();
    return;
  }

  scanningDevices = true;
  devices = [];
  deviceScanCompleted = 0;
  deviceScanTotal = 254;
  error = null;

  notifyListeners();

  try {
    final parts = info.ipv4.split('.');

    if (parts.length != 4) {
      throw Exception(
        'Invalid IPv4 address: ${info.ipv4}',
      );
    }

    final subnet =
        '${parts[0]}.${parts[1]}.${parts[2]}';

    final results =
        await _deviceScannerService.scanSubnet(
      subnet,
      onProgress: (completed, total) {
        deviceScanCompleted = completed;
        deviceScanTotal = total;

        notifyListeners();
      },
    );

    devices = results;
  } catch (e) {
    error = 'Device scan failed: $e';
  } finally {
    scanningDevices = false;
    notifyListeners();
  }
}

Future<void> startTrafficMonitoring() async {
  if (monitoringTraffic) return;

  final info = networkInfo;

  if (info == null ||
      info.interfaceName.isEmpty ||
      info.interfaceName == 'Unknown') {
    error = 'Active network interface is not available.';
    notifyListeners();
    return;
  }

  monitoringTraffic = true;

  trafficStats = TrafficStats.empty(
    interfaceName: info.interfaceName,
  );

  downloadHistory.clear();
  uploadHistory.clear();

  error = null;

  notifyListeners();

  try {
    await for (
      final stats in _trafficMonitorService.monitor(
        info.interfaceName,
      )
    ) {
      if (!monitoringTraffic) {
        break;
      }

      trafficStats = stats;

      downloadHistory.add(
        stats.downloadMbps,
      );

      uploadHistory.add(
        stats.uploadMbps,
      );

      const maxPoints = 30;

      if (downloadHistory.length > maxPoints) {
        downloadHistory.removeAt(0);
      }

      if (uploadHistory.length > maxPoints) {
        uploadHistory.removeAt(0);
      }

      notifyListeners();
    }
  } catch (e) {
    error = 'Traffic monitoring failed: $e';
  } finally {
    monitoringTraffic = false;
    notifyListeners();
  }
}

void stopTrafficMonitoring() {
  if (!monitoringTraffic) return;

  monitoringTraffic = false;

  _trafficMonitorService.stop();

  notifyListeners();


}

 void clearTrafficStats() {
  trafficStats = null;
  downloadHistory.clear();
  uploadHistory.clear();

  notifyListeners();
}

  Future<void> runTraceroute(String destination) async {
    tracerouteTesting = true;
    tracerouteResult = null;
    notifyListeners();

    try {
      tracerouteResult = await _tracerouteService.traceroute(destination);
    } catch (e) {
      tracerouteResult = TracerouteResult(
        destination: destination,
        hops: const [],
        completed: false,
        error: e.toString(),
      );
    } finally {
      tracerouteTesting = false;
      notifyListeners();
    }
  }


  void cancelDeviceScan() {
  if (!scanningDevices) return;

  _deviceScannerService.cancelScan();

  scanningDevices = false;

  notifyListeners();
}

  void clearDiagnostics() {
    gatewayPing = null;
    internetPing = null;
    dnsResult = null;
    diagnosis = null;
    tracerouteResult = null;
    notifyListeners();
  }
}