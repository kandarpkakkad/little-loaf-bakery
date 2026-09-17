# Storage — LLD

## 1. Value types

```dart
/// Integer paise. Never a double, anywhere.
extension type const Money(int paise) {
  static const zero = Money(0);
  Money operator +(Money o) => Money(paise + o.paise);
  Money operator -(Money o) => Money(paise - o.paise);
  Money times(int n)        => Money(paise * n);
  /// Percent of, rounded half-up to the nearest rupee (D10, invoicing).
  Money percentRounded(int bp) => Money(((paise * bp / 10000).round() / 100).round() * 100);
  bool get isZero => paise == 0;
}

/// Hybrid logical clock. Sorts as (wallMs, counter, deviceId).
class Hlc implements Comparable<Hlc> {
  final int wallMs; final int counter; final String deviceId;
  /// Monotonic: never emits a value <= the last one issued or seen.
  static Hlc issue(int nowMs, Hlc last) => nowMs > last.wallMs
      ? Hlc(nowMs, 0, myDeviceId)
      : Hlc(last.wallMs, last.counter + 1, myDeviceId);
  /// Called for every received op, so our clock never lags a peer's.
  static void observe(Hlc remote) { /* raise local wallMs/counter to match */ }
}
```

`Uuid7.generate()` — 48-bit ms timestamp, 74 bits random. Stored as `TEXT` (36 chars) for
readability in Drive journals; indexed as the primary key.

## 2. Schema

**Source of truth: [`schema.md`](schema.md)** — common columns, conventions, the `settings` singleton and the migration ladder. Each module's own tables live in that module's `schema.md`.

## 4. The write transaction

The only sanctioned way to mutate anything.

```dart
Future<T> mutate<T>(String entity, String entityId, T Function(Batch) body) =>
  db.transaction(() async {
    final hlc = Hlc.issue(nowMs, lastHlc);
    final result = await body(batch);          // 1. the row(s)
    await stampRow(entity, entityId, hlc);     // 2. device_id + updated_at_hlc
    await outbox.insert(Op(                    // 3. the op — same transaction
      opId: Uuid7.generate(), hlc: hlc,
      entity: entity, entityId: entityId,
      payload: await serialiseChangedFields(entity, entityId),
    ));
    return result;
  });
```

**Invariant:** a committed row always has a committed op. If the transaction rolls back,
neither exists. There is no reconciliation job, because there is nothing to reconcile.

## 5. Migrations

```dart
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  beforeOpen: (d) async {
    if (d.wasUpgraded) await Backup.snapshotNow(reason: 'pre-migration');  // D5
    await customStatement('PRAGMA foreign_keys = ON');
    if (uncleanShutdown) await integrityCheckOrRestore();
  },
  onUpgrade: (m, from, to) async {
    for (var v = from; v < to; v++) await _steps[v](m);   // one step per version, in order
  },
);
```

**Rules**
- Additive by default: new columns nullable or defaulted.
- Never rename or drop in the same release that stops writing a column. Empty it in release
  *n*, drop it in *n+1*, so a rollback survives.
- Every migration is tested against a **seeded database of 30,000 orders**, not an empty one.
- Bump `min_supported_version` (versioning module) **only** when a migration makes old ops
  unreadable.

## 6. Encryption

- SQLCipher, 256-bit key generated on first launch.
- Key stored in Android Keystore, `setUserAuthenticationRequired(false)` — the app lock is a
  separate, optional UI gate, not the DB key.
- **The key never leaves the device and is never in a snapshot.** A snapshot is written
  decrypted, because it must be restorable on a *different* device with a *different* key.
  It is protected by the Drive account, not by SQLCipher.

## 7. Edge cases

| Case | Handling |
|---|---|
| Two rows race for `phone_e164` | Partial unique index rejects; the domain merges into the existing customer |
| HLC observed from the future (peer clock ahead) | `Hlc.observe` raises our wall clock; never rejected, causality preserved |
| `order_no` sequence gap after a crash | Allowed. Gap-free is a per-device *intent*, not an invariant the DB enforces |
| Tombstoned row receives a later op | Op applies; row stays deleted unless the op un-deletes it explicitly |
| Clock moves backwards (NTP correction) | HLC counter increments; monotonicity holds |

## 8. What to test

- `Money` arithmetic and percent rounding at the half-rupee boundary.
- HLC monotonicity under: clock jump forward, clock jump backward, 10k ops in the same ms.
- `mutate()` rolls back the op when the row write throws — and vice versa.
- Each migration step against the seeded 30k-order database, timed.
- `integrity_check` path: corrupt the file, confirm the restore prompt rather than a crash loop.
