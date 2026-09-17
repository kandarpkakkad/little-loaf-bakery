/// Hybrid logical clock — `(wallMs, counter, deviceId)`.
///
/// Gives ops a total order without trusting device clocks, and the device id as
/// the final tie-break makes the outcome identical on every device, so
/// convergence never depends on arrival order.
///
/// See docs/01-platform/sync/lld.md §7.
class Hlc implements Comparable<Hlc> {
  final int wallMs;
  final int counter;
  final String deviceId;

  const Hlc(this.wallMs, this.counter, this.deviceId);

  /// Issue the next local timestamp. Never emits a value <= [last].
  factory Hlc.issue({
    required int nowMs,
    required Hlc last,
    required String deviceId,
  }) =>
      nowMs > last.wallMs
          ? Hlc(nowMs, 0, deviceId)
          : Hlc(last.wallMs, last.counter + 1, deviceId);

  /// Fold in a timestamp seen from a peer, so our clock never lags theirs.
  /// Called for **every** received op.
  factory Hlc.observe({
    required int nowMs,
    required Hlc last,
    required Hlc remote,
    required String deviceId,
  }) {
    final wall = [nowMs, last.wallMs, remote.wallMs].reduce((a, b) => a > b ? a : b);
    if (wall == last.wallMs && wall == remote.wallMs) {
      return Hlc(wall, (last.counter > remote.counter ? last.counter : remote.counter) + 1, deviceId);
    }
    if (wall == last.wallMs) return Hlc(wall, last.counter + 1, deviceId);
    if (wall == remote.wallMs) return Hlc(wall, remote.counter + 1, deviceId);
    return Hlc(wall, 0, deviceId);
  }

  static Hlc parse(String s) {
    final i = s.indexOf(':');
    final j = s.indexOf(':', i + 1);
    return Hlc(
      int.parse(s.substring(0, i)),
      int.parse(s.substring(i + 1, j)),
      s.substring(j + 1),
    );
  }

  @override
  int compareTo(Hlc o) {
    final w = wallMs.compareTo(o.wallMs);
    if (w != 0) return w;
    final c = counter.compareTo(o.counter);
    if (c != 0) return c;
    return deviceId.compareTo(o.deviceId);
  }

  bool operator >(Hlc o) => compareTo(o) > 0;
  bool operator <(Hlc o) => compareTo(o) < 0;
  bool operator >=(Hlc o) => compareTo(o) >= 0;
  bool operator <=(Hlc o) => compareTo(o) <= 0;

  @override
  String toString() => '$wallMs:$counter:$deviceId';

  @override
  bool operator ==(Object other) => other is Hlc && other.toString() == toString();

  @override
  int get hashCode => toString().hashCode;
}
