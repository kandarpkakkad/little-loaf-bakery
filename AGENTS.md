# Working on Little Loaf Bakery

An offline-first Flutter app that runs one bakery: orders, the kitchen board,
stock, invoices, and WhatsApp messages. No server. Two devices stay in step
through the owner's own Google Drive.

Read [`docs/README.md`](docs/README.md) first, then
[`docs/00-overview/decisions.md`](docs/00-overview/decisions.md). The decisions
file is numbered (D1, D2 …) and the code cites those numbers in comments. When
you touch something that has a decision behind it, read the decision.

---

## 1. Documents before code

**Write the design down first, then build to it.** Not the other way round, and
not "I will update the docs after".

Every system has three documents under `docs/`:

| | Holds | Never holds |
|---|---|---|
| `hld.md` | Purpose, what it owns, key decisions, failure modes, explicit non-goals | Algorithms, DDL |
| `lld.md` | Algorithms, function contracts, state transitions, validation, edge cases | The schema — it *references* `schema.md` |
| `schema.md` | Tables, constraints, indexes, stored file shapes, what is deliberately **not** stored | Anything repeated from the HLD |

The order of work:

1. **Update `hld.md`** — what is changing and *why*, what it now owns, what it
   still refuses to do.
2. **Update `schema.md`** if any shape changes — columns, constraints, the
   files written to Drive.
3. **Update `lld.md`** — the algorithm, the edge cases, what a person can and
   cannot do.
4. **Then write the code**, to match what you just wrote.
5. Update [`docs/README.md`](docs/README.md) if the built/not-built table moves.

**Code is the source of truth; documents must reflect it.** Those are not in
tension — they mean: design on paper first, and when the implementation has to
diverge from that design, change the document in the *same commit*, saying what
you learned. A document describing something that was never built is worse than
no document, because someone will implement from it.

Two habits that come out of this:

- A section describing unbuilt work says so at the top, in bold, and says what
  exists instead.
- When code deliberately departs from a design, the document records the
  departure and the reason. `docs/02-domain/reporting/hld.md` is the worked
  example: the design called for SQL views, the code computes in Dart, and the
  document explains why rather than quietly disagreeing.

---

## 2. How code is written here

### Comments explain why, never what

The code says what it does. A comment earns its place by saying why it is like
that, what it protects against, or what was tried and failed. Cite the decision
or the document: `(D25)`, `docs/01-platform/sync/lld.md §6`.

```dart
// Only after the write lands. If it threw, these stay pending and the next
// run retries them.
```

not

```dart
// mark the ops as uploaded
```

Match the density of the file you are in. If it explains itself thoroughly,
keep explaining. Do not add a comment to every line of a file that has none.

### A placeholder is guidance; a value is content

Two rules, and both were broken:

- **Style the hint.** `InputDecorationTheme` had a `labelStyle` and no
  `hintStyle`, so every placeholder inherited the body colour and read exactly
  like something already typed.
- **A placeholder must not look like real data.** The phone hint was
  `98765 43210`, which reads as somebody's number. It is `xxxxxxxxxx` now — a
  shape, not a sample. `+91` stays as a **prefix**, because that part really is
  fixed.

And do not seed a field with a literal default to mean "nothing": `'0'` in the
lead-days box and `'Home'` in a new address label are values a person has to
notice and delete. Leave the field empty, say it in the hint, and apply the
default on save.

### Money is integer paise

`Money` wraps an `int`. Never a `double`, never a float. Percentages are basis
points. Formatting belongs to `ui/theme/format.dart`.

### `money()` returns `String?` — null when zero

That is the "zero never shows" rule (D10): a ₹0 row is *absent*, not printed as
zero. It has one trap, and it has been paid for:

```dart
// WRONG. Prints "Paid null" to a customer over WhatsApp.
'Total ${money(t.total)} · Paid ${money(t.paid)}'

// Right: drop the clause, or ask for the zero on purpose.
'Total ${money(t.total, showZero: true)}${..._clause('Paid', t.paid)}'
```

**Never interpolate a nullable into a string.** Dart will happily print `null`.

### Anything that can be rendered must render

A class that reaches a `Text` or a `join()` needs `toString()`, or its call
sites must use an explicit `.label`. `Weight` had neither, a `List<Object>`
joined without complaint, and customers saw `INSTANCE OF 'WEIGHT'` where the
weight should have been.

### An error message says the reason, not the fact

A caught exception is evidence. Putting `Text('Could not connect to Google
Drive')` on screen and dropping the exception into a field nobody renders
costs the owner an afternoon: a signing-certificate mismatch, an unpublished
consent screen and flight mode all produce the identical sentence.

If you catch it, show it — or show something that distinguishes the cases.

### The debug APK from CI is signed with a key Google has never seen

Nothing commits a debug keystore, so the runner's Android plugin makes a fresh
one per build. Android OAuth clients are matched on package name **and**
signing certificate SHA-1, so **Google Sign-In cannot work in a CI debug
build**. Test Drive on a locally built debug APK or on a release APK. This is
not a bug to fix in Dart.

### Never mint a date as a small integer in a test

`date: 1000` is 1 January 1970. Fixtures used it as "some day" and `5000` as
"a later day", and a hardcoded `DateTime(2026, 9, 10)` for the same job — which
worked until scheduling into the past was refused, and then 63 tests failed at
once. A hardcoded date rots on its own schedule too: September 2026 was the
future when those were written.

Use `dayAfter(n)` from the harness. Relative days keep their ordering and
cannot go stale.

### Every "outstanding" derivation goes null on a finished order

`nextDate`, `dueDate` and `nextJourney` all skip journeys that are done, so on
a delivered order they are all null. A list grouped on `nextDate ?? dueDate`
filed every completed order under **"No date"**, and a card reading
`nextJourney` alone showed one as "Any time" with the order's cached
fulfilment.

`OrderView.listDate` and `OrderView.shownJourney` carry the fallback. A
finished order should say what it *was*.

### A row's date and its details must come from the same journey

Whatever a list is grouped, sorted or filed by, everything shown beside it
belongs to that same journey. The orders list groups on the *next* journey and
the card printed the *finishing* one's time and fulfilment; the reports list
files on `soldOn` and the same card printed the promised date. Both put two
different trips on one row.

`OrderView.nextJourney`, `finishingSubOrder` and `OrderView.soldOn` are the
three answers — pick the one the surrounding context is actually about.

### An order-level column describes the *finishing* journey, not the order

`orders.tracking_url`, `address_text`, `delivery_date`, `fulfilment` are caches
written from whichever journey finishes the order (`_refreshOrderCache`). Read
one while acting on a *particular* journey and you get a different trip's
answer: Friday's van went out under Sunday's tracking link, and a two-day order
was confirmed with only the later date.

Acting on one journey? Take the value from that journey.

### One label cannot stand for several journeys

A card that said "Delivery" for an order half of which the customer collected
was reading `orders.fulfilment` — the finishing journey's. Anything summarising
a whole order has to look at every journey, or say which one it means.

### Cancelled lines are excluded from totals, so exclude them from listings too

`OrderTotals` filters `isLive`; nothing else did. The invoice itemised two ₹800
rows above an ₹800 subtotal — a bill the customer can add up, and it was wrong.
Any listing of `lines` beside a sum must filter the same way the sum does.

### Compose a message from state read *after* the write

Every customer-facing message is built from a snapshot, and taking it at the
wrong moment is this codebase's most repeated bug. The receipt said "we have
received ₹1,600" and then "Still to pay: ₹1,600", because the screen passed
the `OrderView` it was already holding instead of re-reading after
`addPayment`.

Re-read, then compose. Where something genuinely must be captured beforehand —
the lines a delivery message is about, which are `delivered` by the time it is
composed — capture it explicitly and **match it by id**, never by object
identity: the re-read returns equal objects, not the same ones.

### Derived values are never read back from their cache

Several columns exist only because they are NOT NULL and an older peer still
reads them — `orders.status`, `orders.fulfilment`, `orders.delivery_charge`.
They are **written from the derivation and never read as truth**.

This is the most expensive mistake this codebase has made. `moveTo()` wrote
`orders.status`; every screen read `deriveOrderStatus(lines, …)`. They drifted,
and confirming an order silently did nothing at all for as long as it took
someone to record a video.

If a value is derived: compute it, cache it in one place
(`_refreshOrderCache`), and make every reader use the derivation.

**The check that catches this:** for every column `_refreshOrderCache` writes,
grep for a setter and for a reader outside it. Both should come back empty.
Three did not, and each was a feature that silently did nothing —
`setDeliveryCharge` wrote a column `OrderTotals` does not read, so the button
never moved the total; `setTrackingUrl` wrote one that reverts at the next
refresh; and the order screen's Delivery card showed the *finishing* journey's
date and address labelled as the order's.

### One entry point per state transition

`moveTo()` dispatches to `confirm()` / `complete()` / `_cancel()`. There is no
second way to confirm an order. When you add a transition, add it to the
dispatcher — never alongside it.

### `kUnchanged` means "not passed"; `null` means "clear it"

Forms pass `kUnchanged` for a field they did not render. Passing `null` would
wipe a value the form never showed.

### Sync payloads carry JSON primitives only

`mutations.record(...)` takes a map that goes over the wire as JSON. Never put
a value object in it — split it (`weight_value`, `weight_unit`). Every write
that must reach the other device needs a matching `record` call in the same
transaction.

---

## 3. Schema changes

- `kSchemaVersion` in `platform/storage/database.dart`, one entry per version
  in `_steps`, forward-only.
- **Additive by default.** A column that must go is emptied in release *n* and
  dropped in *n+1*, so a rollback survives. `season_from` is sitting out that
  wait now.
- A NOT NULL column that an older peer writes cannot be dropped at all yet —
  keep it as a cache and stop reading it.
- Backfill in the same step. Never leave a column that new code requires and
  old rows lack.
- Regenerate drift code with:

```bash
dart run build_runner build --delete-conflicting-outputs --force-jit
```

`--force-jit` is required; without it the build script fails to compile.

- **Verify the migration against a real old database**: build the old schema
  with raw sqlite3, set `PRAGMA user_version` to the old number, close it, then
  reopen through `AppDatabase` so `onUpgrade` genuinely runs. Asserting against
  an already-open executor silently skips the migration and passes. (There is
  no migration test file at the moment — `migration_v10_test.dart` went with
  the v12 rewrite — so this is a scratch check unless you are asked for one.)
- **Grep for the dropped name before you finish.** Removing `invoice_seq` from
  `settings` left `UPDATE settings SET order_seq = 0, invoice_seq = 0` in
  `backup/snapshot.dart` — a raw SQL string the analyser cannot see. Every
  snapshot silently failed, and because compaction waits for a snapshot, the
  journal stopped compacting. `flutter analyze` was clean throughout.

---

## 4. Tests

Run `flutter test` and `flutter analyze` before saying anything is done. Both
must be clean.

**There are no end-to-end tests, by project decision** — the owner tests on a
device. That makes one failure mode very cheap to hit, and it has been hit:

> `orders.confirm()` had 27 callers in tests and **zero in the app**. The
> button called `moveTo()`, which did something else entirely. Every test
> passed.

So: when you fix or add behaviour that a screen triggers, **check the screen
actually calls the thing you tested**. Grep the call sites. A repository method
with good coverage and no caller is not a working feature.

Tests run against the real schema in memory (`test/support/harness.dart`).
Constraints and indexes are real, so a CHECK the UI can violate fails in the
suite rather than in someone's kitchen.

Do not add new test files unless asked — the owner has scoped testing
deliberately. Existing tests that encode behaviour you are removing should be
**rewritten**, not deleted.

---

## 5. Verifying, and what you may claim

**Verify locally. Do not watch CI.** `flutter analyze` and `flutter test` are
the bar — they run the same suite the pipeline does, in seconds rather than
minutes. Pushing and then waiting on a run tells you nothing the local suite
did not already, and it spends the owner's time watching a progress bar.

Do not trigger a pipeline by hand to check your work, and do not block on one
after pushing. Look at a run only when something has actually failed, or when
the change is *to* the pipeline itself and the local suite cannot exercise it.

- `flutter analyze` clean, `flutter test` passing — say the number.
- If something is verified only by tests and CI, **say so**. Nothing in this
  app is proven until it has run on a phone.
- Never describe device behaviour you have not observed. Drive sync, the app
  lock and the biometric prompt have all been written without ever touching
  real Google servers or real hardware.
- Report failures with their output. A skipped step is said out loud.

---

## 6. Build and release

- Every push to `main` **bumps the patch version**, commits it, and builds a
  debug APK named for that version. Docs-only pushes are skipped by
  `paths-ignore`.
- Releasing is Actions → **Release** → level `minor`. It bumps, commits, tags,
  and builds the same version twice — a debug APK and a signed release APK.
- The version lives in **two** files that must never disagree: `pubspec.yaml`
  and `lib/platform/versioning/version.dart`. Move them with
  `tool/bump_version.sh`, never by hand. A test fails the build if they drift.
- `kMinSupported` is moved **by hand and only for a genuine incompatibility**.
  It locks older devices out of the app.

### Do not put the skip-ci marker in a commit message

GitHub reads `[skip ci]` anywhere in a commit message, including the body. A
commit *explaining* the marker by quoting it skipped the very build that would
have tested it. Refer to it by name.

---

## 7. Editing style

- **Surgical diffs.** Never run `dart format` across the repository — it once
  reformatted 18 unrelated files into a change about something else. Match the
  formatting already in the file.
- Do not reorganise code you are not changing.
- Remove dead code you have just orphaned, in the same change.
- Commit messages: a short imperative subject, then prose explaining *why* and
  what was learned — including bugs found along the way. The history of this
  repository is written to be read.

---

## 8. Things that are deliberately absent

Do not add these back without being asked:

| | Why |
|---|---|
| Invoicing, in any form, and GST with it | Removed in schema v13 (D30). The payment-received message is the whole of it |
| Recipes / bill of materials | v2. No per-order ingredient costing, and no true COGS |
| Seasonality on menu items | Removed — a bakery that makes a thing makes it |
| A server, accounts, roles | The whole premise is that there is none |
| Analytics, telemetry, crash reporting | Nothing leaves the bakery's Google account |
| Chart packages | Three line charts are a `CustomPainter`, not a dependency on an APK that was worked down from 68 MB to 25 MB |
