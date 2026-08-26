import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ip_geolocation_result.dart';

class IpGeolocationService {
  Future<IpGeolocationResult> lookup(
    String input,
  ) async {
    var query = input.trim();

    if (query.isEmpty) {
      return IpGeolocationResult.failure(
        ip: '',
        message:
            'Please enter an IP address or hostname.',
      );
    }

    query = query.replaceFirst(
      RegExp(r'^https?://'),
      '',
    );

    query = query.split('/').first;

    try {
      final encodedQuery =
          Uri.encodeComponent(query);

      final uri = Uri.parse(
        'https://atlas.ipinfo.app/api/v2/ip/$encodedQuery',
      );

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 15),
          );

      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return IpGeolocationResult.failure(
          ip: query,
          message:
              data['error']?.toString() ??
              'Server returned HTTP ${response.statusCode}.',
        );
      }

      if (data['error'] != null) {
        return IpGeolocationResult.failure(
          ip: query,
          message:
              data['error'].toString(),
        );
      }

      return IpGeolocationResult.fromJson(
        data,
      );
    } on TimeoutException {
      return IpGeolocationResult.failure(
        ip: query,
        message:
            'The geolocation server timed out.',
      );
    } on FormatException {
      return IpGeolocationResult.failure(
        ip: query,
        message:
            'The server returned invalid JSON data.',
      );
    } catch (e) {
      return IpGeolocationResult.failure(
        ip: query,
        message:
            'IP geolocation failed: $e',
      );
    }
  }
}