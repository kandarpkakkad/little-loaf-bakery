# Little Loaf Bakery

An order book for a small bakery, built for a phone in a kitchen: offline first,
sync between devices through the owner's own Google Drive, and no server of ours
anywhere in the picture.

Android only. Flutter 3.38, Dart 3.10.

---

## What it does

**Orders.** Take an order against a customer, with any number of lines — item
from the menu, flavour, weight, quantity, price, and add-ons priced for the line
rather than per unit. Discounts as a percentage or an amount, a delivery charge,
and an advance. The total updates as it is typed, because the number a customer
is about to be quoted should never be a surprise at the end.

**Kitchen.** Two readings of the same orders: a board of what to make next,
grouped by status, and a bake sheet of totals to hold while weighing.

**Stock.** Materials with a low-stock threshold and an opening balance. Stock in
(with a price, so the last rate is known), waste with a reason, and stocktakes
that set the level absolutely.

**Customers.** Created by taking an order rather than as a separate chore. Each
keeps an address book — home, office, a relative's flat — with an optional
Google Maps pin.

**WhatsApp.** Confirmation, out-for-delivery, delivery, payment and invoice
messages, composed as text and handed to WhatsApp through a `wa.me` link. The
app never sends anything itself; it opens the chat with the message ready.

**Sync.** Every device writes its own change journal into a folder in the
owner's Drive and reads everyone else's. No account of ours, no server, and
nothing to configure beyond signing in once.

## What it deliberately is not

- **No GST.** The columns exist and are unused until a bakery needs them.
- **No recipes or bills of material.** Stock is counted, not derived.
- **No server.** Losing the developer does not strand the data; it is in the
  owner's Drive and on the owner's phone.
- **No analytics, no crash reporting, no third-party SDKs** beyond Google
  Sign-In and the Drive API.

---

## Design

Four layers, each depending only on the one below it.

```
ui/          screens, shell, theme, reusable form widgets
domain/      orders, customers, menu, stock, messaging — the rules
platform/    storage, sync, security, device identity
common/      money, phone numbers, HLC clock, ids
```

A few decisions worth knowing before reading the code. The long form lives in
[`docs/00-overview/decisions.md`](docs/00-overview/decisions.md).

**Money is integer paise.** `Money` never holds a double. Percentages are basis
points. Totals are derived from lines every time and never stored, so two
devices cannot disagree about a number neither of them holds.

**Every write goes through one door.** `Mutations.record` writes the row and the
sync op in the same transaction, so a crash can never leave a change that is
visible here and invisible everywhere else.

**Prices live in history, not on records.** The menu carries no price: what a
thing cost is a property of the order that was taken, because customisation
changes it.

**The phone number is the customer.** One number, one customer, enforced by a
partial unique index. Stored canonically as `+919876543210` and shown grouped;
the split is what stops the same person being saved twice.

### Storage

SQLite through [drift](https://drift.simonbinder.eu), 20 tables, schema
version 15. Encrypted at rest with **SQLCipher** — selected through a build hook
in `pubspec.yaml`:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: sqlcipher
```

The key is 256 bits from the Android Keystore, and `connection.dart` asserts
`PRAGMA cipher_version` at open time. That assertion is not decoration: on plain
SQLite, `PRAGMA key` is a silently ignored no-op, so without it a cleartext
database is indistinguishable from an encrypted one.

### Sync

Drive stores files; it does not merge databases. So each device writes only its
own journal and merges everyone else's locally.

```
Little Loaf Bakery/
  journal/
    <device-id>/
      ops.jsonl      header line, then one op per line
      device.json    cursors and last-seen
```

- **Ordering** is a hybrid logical clock — `(wallMs, counter, deviceId)` — so a
  wrong device clock cannot reorder history, and the device id breaks ties
  identically everywhere.
- **Merging** is last-writer-wins **per field**, so two people editing different
  fields of the same order both keep their change.
- **Applying** is idempotent through `applied_ops`, and an op that cannot apply
  yet (an edit whose creating op has not arrived) is left unapplied so it
  retries in order rather than vanishing.
- **Forward compatibility**: unknown fields and unknown entities are skipped, so
  an older build survives a newer one.
- The scope is `drive.file`, which reaches only files this app created. The
  folder is visible in the owner's Drive; nothing else in the account is.

Details in [`docs/01-platform/sync/`](docs/01-platform/sync).

### Backup

Sync keeps two phones agreeing with each other. It does not protect against
both of them agreeing on something wrong — a bad migration, a corrupt file, a
row deleted last Tuesday. Backup is the separate answer to that, and it has two
halves that are only complete together:

| | Covers | Written by |
|---|---|---|
| **Journals** | The tail — everything since the last snapshot | Every device, continuously |
| **Snapshot** | Everything before that | One device, at 00:02 IST |

```
Little Loaf Bakery/
  snapshot/
    owner.json       { device_id, claimed_at, last_snapshot_at, through_seq }
    <yyyy-mm-dd>.db  the whole database, 14 kept
```

- **One device takes the nightly snapshot.** `owner.json` says which. A device
  that finds the file missing claims it — so the first install to run is the
  owner, and a bakery with one phone is never left without backups waiting for
  a second device that does not exist. Handing the job over is manual: delete
  the file. Automatic hand-off would need timeouts and heartbeats to solve
  something that happens once every few years and takes ten seconds by hand.
- **The snapshot is written decrypted**, and this is deliberate. The database
  is SQLCipher-encrypted with a key that lives in *this* phone's Keystore and
  never leaves it, so an encrypted copy would be restorable only onto the
  device that is already gone. The copy is made with `sqlcipher_export` rather
  than `VACUUM INTO`, which on a keyed database would faithfully reproduce the
  one property the file must not have. It is protected by the Drive account.
- **Restore is snapshot plus a replay of every journal**, which is why
  compaction may only drop an op once a snapshot contains it.
- **Restore is staged, not live.** The file is downloaded and checked
  immediately, parked beside the database, and swapped in at the next launch —
  before any screen, stream or background isolate is holding a handle to a file
  that is about to stop existing. So the drill is two steps: restore, reopen.

Restoring runs the same migrations as an upgrade, so it is re-tested after
every schema change, not only when the backup code moves.

Details in [`docs/01-platform/backup/`](docs/01-platform/backup).

---

## Running it

```bash
flutter pub get
flutter run
```

On the emulator, use the helper — it passes the software-rendering flag without
which the window stays blank on an Intel Mac:

```bash
./tool/start_emulator.sh                    # phone
./tool/start_emulator.sh oneplus_pad_a16    # tablet
flutter run -d emulator-5554
```

### Tests

```bash
flutter test      # 159 tests
flutter analyze
```

Widget tests that mount a screen must call `drain(tester)` before finishing.
Drift schedules a timer per stream query as `StreamBuilder`s unsubscribe, and
the binding reports those as pending in whichever test runs next.

### Google Drive setup

Sync needs three OAuth clients in one Google Cloud project — two Android and one
**Web**, whose id is the `serverClientId` in
`lib/platform/sync/drive_auth.dart`. Android clients carry no secret; the
pairing of package name and signing certificate is the credential.

The two Android clients differ in **both** halves of that pair, because a debug
build is a different application:

| | Package name | Certificate |
|---|---|---|
| Release | `com.littleloaf.little_loaf` | the upload key |
| Debug | `com.littleloaf.little_loaf.debug` | the shared debug key |

That suffix is what lets both install side by side, and it is why a debug build
also uses its own Drive folder — `Little Loaf Bakery (debug)` — so trying
something out can never touch the real bakery's records.

Enable the Drive API and add the `drive.file` scope. While the consent screen is
in *Testing*, Google expires the grant every seven days and the app shows
**Reconnect needed** rather than failing silently.

---

The homepage and privacy policy the OAuth consent screen points at live in
[`site/`](site/) and are published by
[`pages.yml`](.github/workflows/pages.yml) to
<https://kandarpkakkad.github.io/little-loaf-bakery/>.

## Working on this

[`AGENTS.md`](AGENTS.md) is the contract for anyone — person or agent — making
changes here: design in `docs/` first, then build to it, plus the conventions
this codebase has actually paid for.

## Releasing

Signing is not in this repository. `android/key.properties` and
`upload-keystore.jks` are ignored, and CI restores them from encrypted secrets.

**Run the Release workflow** — Actions → Release → *Run workflow*, level
`minor`. It bumps the version, commits it, tags it, and builds that one number
twice: a debug APK to try it on, and the signed release APK to install. Nothing
to remember and nothing to type.

[`release.yml`](.github/workflows/release.yml) then analyzes, tests, builds the
debug APK, **checks it carries the debug certificate Google was told about**,
restores the keystore, builds the release APK, **verifies that signature is not
the debug fallback**, publishes to a GitHub release, removes the APKs from
releases older than the newest ten, and shreds both keys even if the build
failed.

Both fingerprint checks exist because the failure they catch is otherwise found
on a phone, as a sign-in that dies with a number: an Android OAuth client is
matched on package name **and** signing certificate, so an APK signed by the
wrong key installs and runs perfectly and simply cannot reach Drive.

Release APKs live on the **Releases** page and stay there. Debug APKs from
`debug.yml` are run artefacts instead, kept 14 days — long enough to try a
change, short enough not to accumulate.

Pushing a `v*` tag by hand still works, for re-running a publish that failed
after the tag was cut. It builds the tag exactly as it stands and refuses if
the tag and `pubspec.yaml` disagree.

Every push to `main` runs [`debug.yml`](.github/workflows/debug.yml), which
**bumps the patch version**, commits it back with `[skip ci]`, and uploads
arm64 and x86_64 debug APKs named for that version. So the version always goes
up, and the app agrees with its own file name.

The version lives in two files that must never disagree — `pubspec.yaml` and
`lib/platform/versioning/version.dart`, because the update gate compares
against the constant. Move them with the script, never by hand:

```bash
tool/bump_version.sh patch      # 0.1.1+2 -> 0.1.2+3
tool/bump_version.sh minor      # 0.1.1+2 -> 0.2.0+3
tool/bump_version.sh set 0.3.0  # 0.1.1+2 -> 0.3.0+3
```

A test fails the build if the two ever drift.

### Who can push to main

Only this account. `main` is protected against force-pushes and deletion, and
the built-in Actions token — which is what commits the version bump — is scoped
to this repository and expires with the job. The bump step runs on `push`
events only, and a pull request from a fork gets a read-only token, no secrets,
and needs approval before it runs at all.

There is deliberately **no long-lived credential** in the repository's secrets
for pushing. One would be strictly worse than the ephemeral token already doing
the job, and it would buy nothing: the only thing it enables is a
require-approval rule, and with a single collaborator there is nobody for that
rule to stop.

Releases are consumed on-device by [Obtainium](https://github.com/ImranR98/Obtainium),
which watches the repo and offers each new tag.

> **The signing key cannot be replaced.** Android identifies an app by package
> name *and* certificate, so losing `upload-keystore.jks` means the app can never
> be updated again — every install would have to be removed. It is backed up
> outside this repository, and it needs to stay that way.

Build locally with:

```bash
flutter build apk --release --split-per-abi
```

Split per ABI, always. A universal APK is 68 MB against 25 MB for arm64, and its
version code would be *lower* than the split builds' — Android would refuse it
as an update.

---

## Still missing

- **iOS.** Nothing prevents it; nothing has been done for it.

Three things that were listed here have since been built or dropped: journal
compaction runs (`sync_engine.dart` `_compact()`), reporting and the app lock
exist, and invoicing was removed outright rather than finished — see D30. The
app sends a WhatsApp message when a payment is recorded; it does not produce a
document.

The `docs/` tree describes the whole product, including parts that do not exist
yet. Treat it as intent, not as a description of the code.
