import 'dart:io';

import '../models/traceroute_result.dart';

class TracerouteService {
  /// Runs Windows tracert with faster timeout settings.
  ///
  /// Default:
  /// - Maximum hops: 20
  /// - Timeout per probe: 1 second
  Future<TracerouteResult> traceroute(
    String destination, {
    int maxHops = 20,
    int timeoutSeconds = 1,
  }) async {
    final target = destination.trim();

    if (target.isEmpty) {
      return const TracerouteResult(
        destination: '',
        hops: [],
        completed: false,
        error: 'Destination cannot be empty.',
      );
    }

    try {
      final result = await Process.run(
        'tracert',
        [
          '-d',
          '-h',
          '$maxHops',
          '-w',
          '${timeoutSeconds * 1000}',
          target,
        ],
        runInShell: true,
      );

      final stdout = result.stdout.toString();
      final stderr = result.stderr.toString();

      if (result.exitCode != 0 && stdout.trim().isEmpty) {
        return TracerouteResult(
          destination: target,
          hops: const [],
          completed: false,
          error: stderr.trim().isNotEmpty
              ? stderr.trim()
              : 'Windows tracert failed with exit code ${result.exitCode}.',
        );
      }

      final hops = _parseOutput(stdout);

      final completed = _destinationReached(
        stdout,
        hops,
      );

      return TracerouteResult(
        destination: target,
        hops: hops,
        completed: completed,
        error: completed
            ? null
            : 'Traceroute did not reach the destination.',
      );
    } on ProcessException catch (e) {
      return TracerouteResult(
        destination: target,
        hops: const [],
        completed: false,
        error: 'Unable to execute Windows tracert: ${e.message}',
      );
    } catch (e) {
      return TracerouteResult(
        destination: target,
        hops: const [],
        completed: false,
        error: 'Traceroute error: $e',
      );
    }
  }

  // ============================================================
  // PARSE TRACERT OUTPUT
  // ============================================================

  List<TracerouteHop> _parseOutput(String output) {
    final lines = output.split(RegExp(r'\r?\n'));

    final List<TracerouteHop> hops = [];

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        continue;
      }

      final hop = _parseHopLine(trimmed);

      if (hop != null) {
        hops.add(hop);
      }
    }

    return hops;
  }

  // ============================================================
  // PARSE INDIVIDUAL HOP
  // ============================================================

  TracerouteHop? _parseHopLine(String line) {
    final hopMatch = RegExp(
      r'^\s*(\d+)\s+(.*)$',
    ).firstMatch(line);

    if (hopMatch == null) {
      return null;
    }

    final hopNumber = int.tryParse(
      hopMatch.group(1)!,
    );

    if (hopNumber == null) {
      return null;
    }

    final data = hopMatch.group(2)!.trim();

    // ----------------------------------------------------------
    // TIMEOUT
    // ----------------------------------------------------------

    if (data.contains('*') &&
        data.toLowerCase().contains('timed out')) {
      return TracerouteHop(
        hop: hopNumber,
        address: '*',
        latencyMs: const [],
        timedOut: true,
      );
    }

    // ----------------------------------------------------------
    // LATENCIES
    // ----------------------------------------------------------

    final latencyMatches = RegExp(
      r'(\d+)\s*ms',
      caseSensitive: false,
    ).allMatches(data);

    final latencies = latencyMatches
        .map(
          (match) => int.tryParse(
            match.group(1)!,
          ),
        )
        .whereType<int>()
        .toList();

    // ----------------------------------------------------------
    // ADDRESS
    // ----------------------------------------------------------

    final address = _extractAddress(data);

    return TracerouteHop(
      hop: hopNumber,
      address: address.isEmpty ? '*' : address,
      latencyMs: latencies,
      timedOut: latencies.isEmpty,
    );
  }

  // ============================================================
  // EXTRACT ADDRESS
  // ============================================================

  String _extractAddress(String data) {
    final withoutLatency = data.replaceAll(
      RegExp(
        r'\d+\s*ms',
        caseSensitive: false,
      ),
      '',
    );

    final cleaned = withoutLatency
        .replaceAll('*', '')
        .replaceAll(
          RegExp(
            r'Request timed out\.',
            caseSensitive: false,
          ),
          '',
        )
        .trim();

    if (cleaned.isEmpty) {
      return '*';
    }

    return cleaned
        .split(RegExp(r'\s+'))
        .last
        .trim();
  }

  // ============================================================
  // DETERMINE COMPLETION
  // ============================================================

  bool _destinationReached(
    String output,
    List<TracerouteHop> hops,
  ) {
    if (hops.isEmpty) {
      return false;
    }

    if (output.toLowerCase().contains('trace complete')) {
      return true;
    }

    final lastHop = hops.last;

    return lastHop.success;
  }
}