class TracerouteHop {
  final int hop;
  final String address;
  final List<int> latencyMs;
  final bool timedOut;

  const TracerouteHop({
    required this.hop,
    required this.address,
    required this.latencyMs,
    required this.timedOut,
  });

  /// Whether this hop responded.
  bool get success {
    return !timedOut && latencyMs.isNotEmpty;
  }

  /// Average latency for this hop.
  double get averageLatency {
    if (latencyMs.isEmpty) {
      return 0;
    }

    final total = latencyMs.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    return total / latencyMs.length;
  }

  /// Lowest latency recorded for this hop.
  int get minLatency {
    if (latencyMs.isEmpty) {
      return 0;
    }

    return latencyMs.reduce(
      (a, b) => a < b ? a : b,
    );
  }

  /// Highest latency recorded for this hop.
  int get maxLatency {
    if (latencyMs.isEmpty) {
      return 0;
    }

    return latencyMs.reduce(
      (a, b) => a > b ? a : b,
    );
  }

  /// Number of successful responses.
  int get responseCount {
    return latencyMs.length;
  }
}

// ============================================================
// TRACEROUTE RESULT
// ============================================================

class TracerouteResult {
  final String destination;
  final List<TracerouteHop> hops;
  final bool completed;
  final String? error;

  const TracerouteResult({
    required this.destination,
    required this.hops,
    required this.completed,
    this.error,
  });

  /// Total number of hops discovered.
  int get hopCount {
    return hops.length;
  }

  /// Number of hops that responded.
  int get respondingHopCount {
    return hops.where((hop) => hop.success).length;
  }

  /// Number of hops that timed out.
  int get timeoutCount {
    return hops.where((hop) => hop.timedOut).length;
  }

  /// Whether at least one hop responded.
  bool get hasResponses {
    return respondingHopCount > 0;
  }

  /// Average latency across responding hops.
  double get averageLatency {
    final respondingHops =
        hops.where((hop) => hop.success);

    if (respondingHops.isEmpty) {
      return 0;
    }

    final total = respondingHops.fold<double>(
      0,
      (sum, hop) => sum + hop.averageLatency,
    );

    return total / respondingHopCount;
  }

  /// Fastest responding hop.
  TracerouteHop? get fastestHop {
    final respondingHops = hops
        .where((hop) => hop.success)
        .toList();

    if (respondingHops.isEmpty) {
      return null;
    }

    respondingHops.sort(
      (a, b) => a.averageLatency.compareTo(
        b.averageLatency,
      ),
    );

    return respondingHops.first;
  }

  /// Slowest responding hop.
  TracerouteHop? get slowestHop {
    final respondingHops = hops
        .where((hop) => hop.success)
        .toList();

    if (respondingHops.isEmpty) {
      return null;
    }

    respondingHops.sort(
      (a, b) => a.averageLatency.compareTo(
        b.averageLatency,
      ),
    );

    return respondingHops.last;
  }

  /// Final hop in the route.
  TracerouteHop? get lastHop {
    if (hops.isEmpty) {
      return null;
    }

    return hops.last;
  }

  /// Whether the final responding hop is the destination.
  ///
  /// This is useful for displaying the final destination
  /// in the UI, although the service remains responsible
  /// for determining whether the trace actually completed.
  bool get destinationReached {
    return completed;
  }
}