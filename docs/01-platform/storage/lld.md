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

## 5b. v9 → v10 — scheduling moves to the line (D25–D27)

> **Not built.** Written now because this is the first migration that has to run
> against real data on two devices at once, and the order of the steps is the
> whole difficulty.

**Why it cannot be a wipe.** Every migration before this one ran on a database
nobody had typed into. This one runs on live orders, on two devices, with a
shared journal that both are still writing to — so the migration has to leave
every existing order meaning exactly what it meant before.

### The steps

```dart
9: (m) async {
  final db = m.database as AppDatabase;

  // 1 ── additive only. Every new column is nullable or defaulted, so a v9
  //      build that reads this file after a rollback still works.
  await m.addColumn(db.orderItems, db.orderItems.status);
  await m.addColumn(db.orderItems, db.orderItems.deliveryDate);
  await m.addColumn(db.orderItems, db.orderItems.deliveryTime);
  await m.addColumn(db.orderItems, db.orderItems.fulfilment);
  await m.addColumn(db.orderItems, db.orderItems.deliveryType);
  await m.addColumn(db.orderItems, db.orderItems.addressText);
  await m.addColumn(db.orderItems, db.orderItems.pinLat);
  await m.addColumn(db.orderItems, db.orderItems.pinLng);
  await m.addColumn(db.orderItems, db.orderItems.pinUrl);
  await m.addColumn(db.orderItems, db.orderItems.trackingUrl);
  await m.addColumn(db.orderItems, db.orderItems.deliveredAt);
  await m.addColumn(db.orderItems, db.orderItems.cancelReason);
  await m.createTable(db.orderItemStatusEvents);

  // 2 ── every existing line inherits its order's schedule. This is what makes
  //      a one-date order still a one-date order afterwards.
  await db.customStatement('''
    UPDATE order_items SET
      delivery_date = (SELECT o.delivery_date FROM orders o WHERE o.id = order_id),
      delivery_time = (SELECT o.delivery_time FROM orders o WHERE o.id = order_id),
      fulfilment    = (SELECT o.fulfilment    FROM orders o WHERE o.id = order_id),
      delivery_type = (SELECT o.delivery_type FROM orders o WHERE o.id = order_id),
      address_text  = (SELECT o.address_text  FROM orders o WHERE o.id = order_id),
      pin_lat       = (SELECT o.pin_lat       FROM orders o WHERE o.id = order_id),
      pin_lng       = (SELECT o.pin_lng       FROM orders o WHERE o.id = order_id),
      pin_url       = (SELECT o.pin_url       FROM orders o WHERE o.id = order_id),
      tracking_url  = (SELECT o.tracking_url  FROM orders o WHERE o.id = order_id)
  ''');

  // 3 ── and its order's status, mapped down. The order-level vocabulary is
  //      wider than the line's, so two values collapse:
  //        created / confirmed  -> in_production  (not started; the order's own
  //                                status still says which, and it is what the
  //                                derivation reads)
  //        in_production        -> in_production
  //        ready                -> ready
  //        out                  -> out
  //        delivered/completed  -> delivered
  //        cancelled            -> cancelled
  await db.customStatement('''
    UPDATE order_items SET status = CASE
      (SELECT o.status FROM orders o WHERE o.id = order_id)
        WHEN 'ready'     THEN 'ready'
        WHEN 'out'       THEN 'out'
        WHEN 'delivered' THEN 'delivered'
        WHEN 'completed' THEN 'delivered'
        WHEN 'cancelled' THEN 'cancelled'
        ELSE 'in_production'
      END
  ''');

  // 4 ── the two columns the CHECKs pair with a status.
  await db.customStatement('''
    UPDATE order_items
       SET delivered_at = (SELECT o.delivered_at FROM orders o WHERE o.id = order_id)
     WHERE status = 'delivered'
  ''');
  await db.customStatement('''
    UPDATE order_items
       SET cancel_reason = COALESCE(
             (SELECT o.cancel_reason FROM orders o WHERE o.id = order_id),
             'cancelled before per-line cancellation existed')
     WHERE status = 'cancelled'
  ''');

  // 5 ── confirmed_at / completed_at, which the derivation needs and the old
  //      model never stored. Recovered from the status history where there is
  //      one; from the row's own timestamps where there is not.
  await m.addColumn(db.orders, db.orders.confirmedAt);
  await m.addColumn(db.orders, db.orders.completedAt);
  await db.customStatement('''
    UPDATE orders SET confirmed_at = COALESCE(
      (SELECT MIN(e.at) FROM order_status_events e
        WHERE e.order_id = orders.id AND e.to_status = 'confirmed'),
      CASE WHEN status IN ('created') THEN NULL ELSE created_at END)
  ''');
  await db.customStatement('''
    UPDATE orders SET completed_at = (
      SELECT MIN(e.at) FROM order_status_events e
       WHERE e.order_id = orders.id AND e.to_status = 'completed')
  ''');

  await db.customStatement(
    'CREATE INDEX ix_items_due ON order_items(delivery_date, delivery_time) '
    "WHERE deleted_at IS NULL AND status NOT IN ('delivered','cancelled')");
}
```

### What is deliberately *not* done

- **`orders.delivery_*` is not dropped.** It becomes the default a new line
  copies (schema.md), and dropping a column the previous release still writes
  breaks a rollback. If it is ever dropped it happens in v11, per the rule above.
- **`orders.status` is not dropped either**, even though it is now derived.
  A v9 device still writes it, and the value is still what step 3 reads.
- **No CHECK is tightened on `order_items` in this step.** SQLite cannot add a
  constraint to an existing table without rewriting it, and a rewrite mid-migration
  on a live database is the one thing worth avoiding here. The CHECKs in
  schema.md apply to tables created fresh; enforcement for migrated rows is the
  repository's job until a v11 table rebuild.

### The part that is not SQL

Two devices will be on different versions for a while, and that is the risk
this migration carries:

| | |
|---|---|
| **v9 writes, v10 reads** | Fine. The order-level fields still arrive and step 2's mapping is the same logic the applier would run. |
| **v10 writes, v9 reads** | The line-level columns are unknown to v9 and **dropped on apply** (`apply.dart` filters by the local column list). A v9 device shows the order at its *order-level* date — which after v10 is only the default, so a line moved to a different day looks unmoved there. |

That second row is the reason to bump `min_reader_version` **to 2** in the same
release: a v9 device should stop reading v10 journals rather than read them
half-right. It is the first time that mechanism earns its place.

- Test this step against a database with: a single-line order, a multi-line
  order, one of each status including cancelled, an order with no status events,
  and an order delivered before `delivered_at` was populated.

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
