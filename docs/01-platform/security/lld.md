# Security & privacy — LLD

## 1. Database encryption

```dart
Future<Uint8List> dbKey() async {
  const alias = 'llb_db_key';
  var key = await keystore.read(alias);
  if (key == null) {
    key = randomBytes(32);
    await keystore.write(alias, key,
        userAuthenticationRequired: false);   // app lock is separate, and optional
  }
  return key;
}
// drift: NativeDatabase(file, setup: (db) => db.execute("PRAGMA key = \"x'$hex'\""))
```

**`PRAGMA key` alone is not encryption, and its failure is silent.** On a plain
SQLite build the pragma is an unrecognised no-op: the database opens, reads back
perfectly, and is written in cleartext. This shipped once — see below.

Two things are required together:

1. **Select the SQLCipher build.** In `sqlite3` 3.x that is a build hook in
   `pubspec.yaml`, not a package:

   ```yaml
   hooks:
     user_defines:
       sqlite3:
         source: sqlcipher
   ```

   The old route — adding `sqlite3_flutter_libs` and `sqlcipher_flutter_libs` —
   is worse than useless now. Both install a native library called
   `libsqlite3.so`, one silently overwrites the other, and the plain build wins.
   `sqlcipher_flutter_libs` 0.7.0+eol does nothing at all; its own source says so.

2. **Assert it loaded, at open time.**

   ```dart
   final v = db.select('PRAGMA cipher_version');
   if (v.isEmpty || '${v.first.values.first}'.trim().isEmpty) {
     throw StateError('SQLCipher is not loaded — the database would be cleartext.');
   }
   ```

   `cipher_version` returns nothing on plain SQLite, and it is the **only** cheap
   check that separates the two. `SELECT count(*) FROM sqlite_master` cannot: an
   unencrypted file answers it happily.

   Failing loudly is the point. An app that will not start is recoverable; a
   cleartext customer database that looks fine is not.

**`userAuthenticationRequired: false` is deliberate.** Tying the DB key to biometrics would
make the app unopenable after a fingerprint reset, and the background sync worker could not
run at 00:02 with the screen locked.

## 2. App lock

Built — `lib/platform/security/app_lock.dart`, the cover in
`ui/shell/lock_gate.dart`, the switch in Business details, 12 tests.

Two notes from building it:

- **The prompt goes through a `DeviceAuth` seam**, not `local_auth` directly.
  The plugin does not export the types on its own call signature, so nothing
  can fake it — and ask-and-get-a-yes is the whole of what the app needs.
- **Anything that throws unlocks.** No hardware, no enrolled credential, a
  vendor plugin that threw: none of these may lock someone out of their own
  orders. A refusal keeps the lock up; a failure to *ask* does not.
- **The lock is a cover over the navigator**, not a route, so unlocking returns
  to the half-typed order that was there before. `MainActivity` extends
  `FlutterFragmentActivity` because the biometric prompt is a fragment.

| | |
|---|---|
| Default | **Off** |
| Options | Device PIN, or biometric with PIN fallback |
| Applies | On cold start and on resume after 5 minutes in the background |
| Does not apply | To the sync worker, the snapshot job, or the version gate |
| Failure | No lockout counter. This is a shopkeeping app, not a bank; the real protection is the device lock |

## 3. Google Sign-In

```dart
final scopes = ['https://www.googleapis.com/auth/drive.file'];
```
- Silent sign-in on launch; interactive only on first run or after a revoke.
- Tokens are held by Play Services, not by the app.
- On failure: **carry on offline.** Set `syncState = unauthenticated`, banner after 24h.
  Never a blocking dialog — an auth hiccup must not stop someone taking an order.

## 4. Data classification

| Class | Fields | Handling |
|---|---|---|
| Personal | customer name, phone, address text | Encrypted at rest, in the private folder |
| **Sensitive** | `pin_lat`, `pin_lng`, `pin_url` | As above, plus: never logged, never in an error report, deleted with the order |
| Business | orders, prices, stock | As personal |
| Operational | device ids, cursors, HLCs | Not personal; safe to show in Sync & backup |

## 5. Deletion request

```
tombstone(customer)                       // deleted_at set, op replicated
  → tombstone every order for that customer
  → null out address_text, pin_*, notes on those orders   // an explicit erase op
  → delete attachment files from Drive media/
  → keep invoices with the name replaced by "Deleted customer"   // financial record
```
Invoices survive with the name scrubbed: the money has to stay auditable, the identity does not.

## 6. Retention

```dart
// monthly, on the snapshot device only
final cutoff = now.minus(years: 3);
for (final c in customersWithNoOrderSince(cutoff)) {
  await anonymise(c);   // name → "Customer 0148", phone → null, notes → null
}
```
Anonymise rather than delete, so historical totals stay correct.

## 7. Logging rules

- **Never logged:** phone numbers, addresses, pins, customer names, message bodies.
- **Logged:** op ids, entity ids, device ids, HLCs, counts, error types.
- Crash reports are local only — there is no reporting service, because there is no server.

## 8. Edge cases

| Case | Handling |
|---|---|
| Biometric enrolment changes | App lock falls back to PIN. The DB key is unaffected — see §1 |
| Account removed from the phone | Sync stops, local data intact, banner shown |
| `drive.file` scope revoked mid-session | Next call fails → `unauthenticated` → banner |
| Restore onto a phone with an existing key | The snapshot is decrypted; a fresh key is generated for the new DB |
| Two apps, same account, different phones | Expected. That is the whole design |

## 9. What to test

- Kill the app during first-run key generation; confirm no half-initialised database.
- Revoke Drive access; confirm the app still opens, still takes orders, and warns after 24h.
- Confirm no personal field appears in any log line, by grepping a full session's logs.
- Deletion request: confirm the customer and orders tombstone, media is removed, and the
  invoice remains with the name scrubbed.
