import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/whois_result.dart';

class WhoisService {
  Future<WhoisResult> lookup(
    String domain,
  ) async {
    try {
      domain = domain
          .replaceFirst(
            RegExp(r'^https?://'),
            '',
          )
          .split('/')
          .first
          .trim();

      final response = await http
          .get(
            Uri.parse(
              'https://rdap.org/domain/$domain',
            ),
          )
          .timeout(
            const Duration(
              seconds: 15,
            ),
          );

      if (response.statusCode != 200) {
        return WhoisResult.failure(
          domain: domain,
          message:
              'WHOIS server returned ${response.statusCode}.',
        );
      }

      final data =
          jsonDecode(response.body);

      String registrar = 'Unknown';

      if (data['entities'] != null) {
        final entities =
            data['entities'] as List;

        for (final entity in entities) {
          final roles =
              entity['roles'] as List?;

          if (roles != null &&
              roles.contains(
                'registrar',
              )) {
            registrar =
                entity['handle'] ??
                'Unknown';
            break;
          }
        }
      }

      String created = 'Unknown';
      String expires = 'Unknown';

      final events =
          data['events'] as List? ?? [];

      for (final event in events) {
        if (event['eventAction'] ==
            'registration') {
          created =
              event['eventDate'] ??
              'Unknown';
        }

        if (event['eventAction'] ==
            'expiration') {
          expires =
              event['eventDate'] ??
              'Unknown';
        }
      }

      final nameServers =
          ((data['nameservers'] ?? [])
                  as List)
              .map<String>(
                (e) =>
                    e['ldhName']
                        .toString(),
              )
              .toList();

      return WhoisResult(
        success: true,
        domain: domain,
        registrar: registrar,
        creationDate: created,
        expiryDate: expires,
        nameServers: nameServers,
        message:
            'WHOIS lookup completed successfully.',
      );
    } on TimeoutException {
      return WhoisResult.failure(
        domain: domain,
        message:
            'WHOIS server timed out.',
      );
    } catch (e) {
      return WhoisResult.failure(
        domain: domain,
        message: e.toString(),
      );
    }
  }
}