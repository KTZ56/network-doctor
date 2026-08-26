import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/asn_result.dart';

class AsnService {
  Future<AsnResult> lookup(
    String input,
  ) async {
    var query = input.trim();

    if (query.isEmpty) {
      return AsnResult.failure(
        message: 'Please enter an ASN.',
      );
    }

    // Accept both:
    // AS22612
    // 22612
    if (query.toUpperCase().startsWith('AS')) {
      query = query.substring(2);
    }

    query = query.trim();

    if (!RegExp(r'^\d+$').hasMatch(query)) {
      return AsnResult.failure(
        message:
            'Invalid ASN. Enter a number such as 22612 or AS22612.',
      );
    }

    try {
      final uri = Uri.parse(
        'https://atlas.ipinfo.app/api/v2/asn/$query',
      );

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 15),
          );

      Map<String, dynamic> data;

      try {
        data =
            jsonDecode(response.body)
                as Map<String, dynamic>;
      } catch (_) {
        return AsnResult.failure(
          message:
              'The ASN server returned invalid JSON data.',
        );
      }

      if (response.statusCode != 200) {
        return AsnResult.failure(
          message:
              data['error']?.toString() ??
              'ASN server returned HTTP ${response.statusCode}.',
        );
      }

      if (data['error'] != null) {
        return AsnResult.failure(
          message:
              data['error'].toString(),
        );
      }

      return AsnResult.fromJson(data);
    } on TimeoutException {
      return AsnResult.failure(
        message:
            'The ASN server timed out.',
      );
    } on FormatException {
      return AsnResult.failure(
        message:
            'The ASN server returned invalid data.',
      );
    } catch (e) {
      return AsnResult.failure(
        message:
            'ASN lookup failed: $e',
      );
    }
  }
}