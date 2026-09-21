# Little Loaf Bakery — Order & Stock App

**v1.0 · 21 September 2026 · Kandarp Kakkad**
Android · Flutter · SQLite on the phone · Google Drive for sync and backup · no server

> **This describes the app as it is built**, not as it was first imagined. Where the two
> differ the code won, and the reasons are in
> [`00-overview/decisions.md`](00-overview/decisions.md) — numbered D1…D30 and cited from the
> code. Design detail lives in the per-system `hld` / `schema` / `lld` documents;
> [`README.md`](README.md) says what is built and what is not.

---

## 1. What it is

Custom cake and bake pre-orders, taken over phone and Instagram, that used to live in chat
threads and notebooks. This app is where an order is recorded, produced, delivered and paid
for — on two Android phones, with no server.

**Scale:** ~10 orders/day now, ~30 at peak. Two people. India, INR, no GST.

---

## 2. Non-goals

| Not doing | Why |
|---|---|
| Server, web app, hosting | Everything runs on the phone |
| WhatsApp Business API | Messages are shared from the existing number |
| Recipes / bill-of-materials | No per-order ingredient cost, and so no true COGS. v2 |
| **Invoicing, in any form** | Removed in schema v13 (D30). A payment is acknowledged over WhatsApp and that is the whole of it |
| **GST** | Below threshold. Removed with invoicing rather than carried unused — a migration when it arrives is cheaper than columns nobody can explain |
| Seasonality on menu items | Removed. A bakery that makes a thing makes it |
| iOS | Android only |
| Login, accounts, roles | Two owners, both see everything |
| Analytics, telemetry, crash reporting | Nothing leaves the bakery's Google account |
| Counter POS, wholesale, customer login, payroll | Out of scope |

---

## 3. Users

Two owners, two phones, one Google account. **Identical access.** No permission model.

**Nothing in the design assumes two.** Devices are discovered, not configured (§4.2), so a
third or fourth phone is an install, not a change.

---

## 4. Architecture

### 4.1 Shape

```
Device 0192f3…a41c            Device 0192f4…7b02            (…any number)
  Flutter UI                    Flutter UI
  SQLite (drift + SQLCipher)    SQLite (drift + SQLCipher)
  outbox (pending ops)          outbox (pending ops)
       └────────────┬────────────────┘
                    ▼
        Google Drive — one folder, one account
          journal/0192f3…a41c/device.json     name, cursors, version, last seen
          journal/0192f3…a41c/ops.jsonl       one file, fixed name
          journal/0192f4…7b02/ops.jsonl
          snapshot/owner.json                 which device takes snapshots
          snapshot/2026-09-20.db              nightly, by the owner only
```

**A device id is a UUID v7 generated at install**, and it never changes for that
installation. Nothing is named "phone A" or numbered — the folder name *is* the id.

Every write commits to local SQLite first. The UI never waits on the network.

### 4.2 Sync

Drive stores files; it does not merge databases. Each device writes **only its own
journal** and reads the others', replaying ops into its own SQLite. Nothing is ever
overwritten.

| | |
|---|---|
| Journal | **One file per device, fixed name** — `ops.jsonl`. Only this device ever writes it |
| Upload | Debounced ~5s. Drive has no append, so the file is re-uploaded whole — viable only because it stays small (see compaction) |
| Download | On app resume, on pull-to-refresh, and **on the wall-clock 5-minute grid** — `:00, :05, :10 … :55`. **Lists `journal/` and pulls every folder that is not its own** |
| Devices | Discovered, never configured. A new install is a new folder, picked up on the next sync. Removing one is deleting a folder |
| Cursors | Each device publishes how far it has read each peer, in its own `device.json`, **after** the pull — a read-only device that published first could never unblock compaction |
| Volume | ~240 ops/day, a few hundred KB a month |
| Scope | Google Sign-In, `drive.file` only — the app sees only files it created |
| Offline | Everything works. Changes queue in the outbox |

**Pulls are aligned to the clock, not to the last pull.** Every device checks at the same
instants, so a change uploaded at `:03` is on every other device by `:05` — the lag is
bounded and predictable rather than drifting with whenever each app happened to start.
Uploads stay event-driven, because your own changes should leave immediately; only the
listening is scheduled.

**The applier is generic over the entity name**, not a typed switch per table. It reads a
table's columns from the database and drops any field it does not recognise — which is what
lets an older reader survive a newer writer, and what let the `invoices` table be deleted
without a single line of compatibility code.

**Compaction — why a fixed filename works**

`ops.jsonl` is a **delivery buffer, not an archive.** An op leaves it once it is no longer
needed, so the file stays at roughly a day's work — tens of kilobytes — and re-uploading it
whole costs nothing.

An op is dropped only when **both** are true:

1. **Every live peer has read past it**, according to the cursors each publishes.
2. **It is already inside the latest snapshot.**

Either alone would be unsafe. Without (1) a peer loses ops it never saw; without (2) a
restore loses them. Together, anything dropped is provably somewhere else.

**A device silent for 30 days stops being waited for.** Otherwise one lost phone makes every
journal grow forever. That device catches up by restoring from a snapshot instead.

### 4.3 Conflicts

- Every op carries a **hybrid logical clock** — total ordering without trusting phone clocks.
- **Inserts never conflict.** Stock movements and status events are append-only.
- **Field updates: last-writer-wins, per field.** Two people editing different fields both keep their change.
- **Deletes are tombstones.** Every delete in the app is soft.

| Divergence | Behaviour |
|---|---|
| Status moved backwards by an incoming op | Surfaced in the conflict log, not applied silently |
| Devices offline for days | Merge on reconnect; every overwrite recorded in the conflict log |
| No sync for 24h | Persistent stale-sync banner, manual retry |
| One device re-prices a journey while another adds an item to it | A journey's charge is the **maximum** of its items' — deterministic, and it errs toward charging rather than silently under-charging |

### 4.4 Identity and numbering

**Two ids per order, doing two different jobs.**

| | |
|---|---|
| **`id`** | **UUID v7**, generated on the device. The primary key — what ops, foreign keys and sync all reference. Never shown to anyone |
| **`order_no`** | `LLB-0148-K7QP`. Human-facing: printed, spoken on the phone, searched for. **An attribute, not a key** |

**UUID v7 is time-ordered, and monotonic within a millisecond.** The generator follows RFC
9562 method 1 — a 12-bit counter in the rand_a field, incremented when two ids are minted in
the same millisecond — so sorting by id is sorting by creation even for rows made in the same
instant. It is not only cosmetic: the opening-stock calculation sorts by id to break ties,
and did so wrongly before the counter existed.

**The human number carries a hash, so it is unique too.**

```
LLB-0148-K7QP
 │    │    └── 4 characters derived from the order's UUID
 │    └─────── this device's sequence
 └──────────── fixed prefix (settings.invoice_prefix — the name outlived invoicing)
```

- The sequence is **per device**, because it has to be generated offline with no
  coordination. It stays consecutive and gap-free on that device.
- The **hash** is derived from the order's own UUID — deterministic, needs no coordination,
  and makes the whole number unique even if two devices ever ran the same sequence.
- **Crockford base32** for the hash: digits plus letters, with `I`, `L`, `O` and `U` removed.
  These numbers get read aloud on the phone, and those four are the ones people mishear.
- A number is **immutable once issued**.
- **A device id is never reused.** A replacement phone, or a reinstall after a wipe, is a new
  install with a new UUID — so it starts its own sequence at 0001. The old series simply ends;
  its numbers stay valid forever and nothing renumbers.

**A journey inside an order is `LLB-0148-K7QP-2`** — the order's number and the journey's
sequence within it. Spent, never reused: a number that comes back meaning something else is
worse than a gap. It is for the kitchen, and never appears in a customer message.

**First run.** The app **creates its own database on the device** — every table, every index
and a default settings row — the first time it opens. Nothing is bundled and nothing is
fetched. It is usable immediately, offline, before Google Sign-In has been touched. Drive is
offered on first launch rather than buried in a settings screen, and the folder is created on
the first sync.

### 4.5 Backup & restore

- The journal covers the recent tail; the snapshot covers everything before it. **Restore is
  snapshot + replay of every journal**, so the two together are always complete.
- **Restore is staged and applied at the next launch** — swapping a database underneath a
  running app is how you lose one.
- **Tested before launch and quarterly after.**

**One device uploads the snapshot, at 00:02 IST.** It writes **the whole database**, not a
delta. `snapshot/owner.json` records which device that is.

| At 00:02, a device reads `owner.json` | Then |
|---|---|
| **Missing** | It **claims it** — writes its own id — and uploads the snapshot |
| **Matches this device** | Uploads the snapshot |
| **Names another device** | Skips. Nothing else changes |

That's the whole rule. It needs no locking: **the check happens on every upload, not just at
claim time**, so if two devices ever claimed at once, last write wins and the loser simply
skips from the following night onward. It corrects itself.

The snapshot is **decrypted** — a backup you cannot open without the phone that made it is
not a backup.

**Android will sometimes miss 00:02** — the phone may be dozing or off. The snapshot is then
taken at the first opportunity after, and `last_snapshot_at` records when it actually
happened, not when it was due. Charger and unmetered network are preferred, never required.

**Releasing ownership is manual.** If the owning device is uninstalled or retired, delete
`snapshot/owner.json` from Drive by hand — the next device to reach 00:02 claims it. This
is deliberate: automatic hand-off would need timeouts and heartbeats to solve a problem that
happens once every few years and takes ten seconds to fix.

**The one consequence to watch.** No snapshots means compaction never advances, so journals
grow. **Sync & backup warns when the last snapshot is more than 3 days old**, naming the
owning device. That is the signal to delete the file.

Keep the last 14 snapshots; prune older.

### 4.6 Upgrades

- SQLite lives in app-private storage. Android keeps it across an APK update **only if the package name and signing key are unchanged**.
- **Never uninstall to upgrade.** Install over.
- Migrations: versioned, forward-only, run on first launch. Tested against a real database of
  the previous version — built with raw sqlite3 and reopened through `AppDatabase`, so
  `onUpgrade` genuinely runs.
- **Schema v13** is current: v12 made the journey a row of its own (D28); v13 removed
  invoicing (D30).

**Devices will be on different versions.**

| Case | Behaviour |
|---|---|
| Op has fields this build doesn't know | Ignore them. Ops are additive |
| Op names a table this build doesn't have | Skipped and marked applied, never retried forever |
| App below `min_supported_version` | **Hard block.** Outbox flushed first, so nothing is lost |
| App below the latest release | Dismissible banner |
| No source answered | **Never blocks.** Cached values used |

The GitHub release tag says what exists; each peer's `device.json` carries its `app_version`
and the floor it requires. Nobody hand-edits JSON, and there is no separate `app.json` — the
file that already describes a device is the file that describes its version.

**Publishing an update** is Actions → **Release**, level `minor` or `major`. CI bumps the
version, commits it, tags, and builds the same version twice — a debug APK and a signed
release APK. Every push to `main` that touches code bumps the patch version and builds a
debug APK; documentation-only pushes build nothing.

> **A debug APK built by CI cannot sign in to Google.** No debug keystore is committed, so the
> runner generates one per build, and Android OAuth clients are matched on package name **and**
> signing certificate SHA-1. Test Drive on a locally built debug APK, or on a release build.

### 4.7 What this costs

| Given up | Because | Mitigation |
|---|---|---|
| WhatsApp delivery receipts | A human taps send | The log records the share, and when |
| Enforced permissions | Every device holds the whole database | Not attempted. Owners only |
| Web / desktop access | No server | CSV export |
| Instant consistency | Drive can't push without a server | Seconds to five minutes |
| Un-counting a delivered sale | Voiding an invoice was the only mechanism, and invoicing is gone (D30) | Cancel before it goes out. After that, the sale stands |

---

## 5. The menu

**Every order item comes from the menu.** Item names are never typed onto an order, so the
same thing is always called the same thing — which is what makes "sales by product" a real
number rather than a spelling survey.

- **Menu item:** name, lead time in days, active. The item *is* the category (D16).
- **No price, no flavour list.** Both are decided per item (§6.3).
- **No seasonality.** It was removed: a bakery that makes a thing makes it.
- Maintained under **More › Menu items**.

**Flavour is free text.** The menu says *what it is*; flavour and special requirements say how
this one differs.

An order item keeps a **copy of the item name** as it was when ordered, so renaming a menu
item never rewrites what an old order says.

---

## 6. Orders

### 6.1 Three levels, three status machines

An order is not a flat list of items (D28). It is:

```
Order  LLB-0148-K7QP
  ├── Journey -1   Fri 25 Sep, 4:00 pm · Delivery · 14 Turner Rd   ₹80 delivery
  │     ├── Cake · Chocolate · 500 g × 1    "Happy Birthday Janvi", eggless
  │     └── Cake · Vanilla · 500 g × 1
  └── Journey -2   Sun 27 Sep · Pickup                              no charge
        └── Cake · Butterscotch · 500 g × 1
```

**A journey is a handover** — one day, one time, one way out, one place. Two cakes going to
the same door at the same hour are one doorbell.

**Nobody creates a journey.** An item says when and where it goes, and the journey matching
that is found or opened. Change an item's date and it moves between journeys by itself; a
journey with nothing left on it disappears. The order form never asks about journeys — they
are how the kitchen reads the order, not something to fill in.

**Each level has its own status, and each is derived from the one below (D29).**

| Level | States | Derived from |
|---|---|---|
| **Item** | Created → Confirmed → In production → Ready → Delivered · Cancelled | Typed by a person in the kitchen. **Never "out"** — an item does not travel on its own |
| **Journey** | Created → Confirmed → In production → Ready → Out → Delivered · Cancelled | Its items — until a person sends it out or marks it arrived. Nothing about a cake can tell you the van has left. A **pickup** goes straight from Ready to Delivered |
| **Order** | Created → Confirmed → In production → Delivered → Completed · Cancelled | Its journeys. **Never reads Ready or Out** — half a ready order is not a thing, and an order does not travel |

**Every step is taken by a person.** The app never advances an order itself — not on a
payment, not on a share, not on the delivery date. It offers; it does not move.

Delivering a journey **delivers everything on it**: the items travelled together, so they
arrived together. That cascade is why an item has no delivered button of its own.

**Status is computed, never typed.** `orders.status` exists as a column because it is NOT
NULL and an older peer still reads it — it is written from the derivation after every change
and never read back as truth. This was the most expensive mistake the codebase has made:
for a while the Confirm button wrote that column and every screen read the derivation, so
confirming an order did nothing at all.

### 6.2 Two dates, and what each is for

| | |
|---|---|
| **Due** | The **latest** outstanding journey — when the order *finishes*. What the order shows |
| **Next** | The **earliest** outstanding journey — when somebody has to do something. What every list sorts and groups by |

They differ on a multi-day order and both are needed. A cake on Friday and a box on Sunday
finishes Sunday but needs someone on Friday; sorting by the due date buries Friday's cake
behind everything due earlier in the week, and nobody bakes it.

**Whatever a row is grouped by, everything else on that row comes from the same journey.**
A card filed under Friday shows Friday's time and Friday's way out, never the finishing
journey's.

**Sort order everywhere:** `next date → next time → order created time`. Untimed journeys go
to the end of their day under *Any time*. Created time breaks every tie.

### 6.3 An item

| Field | | |
|---|---|---|
| **Item** * | | **From the menu.** Not typed |
| **Flavour** | free text | Past flavours suggested |
| **Weight** | g · kg · ml · l | Blank for anything not sold by weight or measure. **Not** pcs or dozen — how many there are is the quantity |
| **Quantity** * | | Defaults to 1. A stepper you can also **type into** — a hundred buns is not a hundred taps |
| **Base price** * | ₹ | Typed. Last 3 prices shown; the customer's own last price first |
| **Add-ons** | 0..n | Name + price each. Priced for the item, not multiplied by quantity |
| **Note** | | Internal |
| **Date** * · **Time** · **Delivery or pickup** · **Address** | | What decides which journey it joins. **Never in the past** — the picker starts at today, and the repository refuses it outright |
| **Message on the item** | | Piped, iced, written on the box. Proofread on its own |
| **Special requirements** | free text | |
| **Dietary** | chips | Eggless, nut-free, gluten-free, sugar-free |
| **Delivery charge** | ₹ | One per **journey**, not per item (§6.4) |

**"Same as another item"** copies the whole schedule — date, time, way out, place — from any
sibling, so the second item joins the first one's journey. It is a copy, not a link: editing
the first afterwards leaves the second alone.

**What an item *is* stays editable until a baker starts on it.** Once it is in production the
tin has been weighed. When and where it goes stays editable until it has gone.

**The address is remembered.** A new address typed while taking an order is saved against the
customer when the order is written — so the next order offers it, and it shows on their page.
Typed twice with different capitals or spacing, it is one address. A pickup saves nothing.

**The pin** is captured by pasting the location link the customer shared on WhatsApp. Lat/lng
extracted where present; the original link kept either way. **The app never asks for location
permission** — nothing is read from the phone's GPS.

### 6.4 Money

```
item total   = base price × quantity + add-ons
subtotal     = Σ item totals, cancelled items excluded
discount     = flat ₹, or % × subtotal
delivery     = Σ over JOURNEYS, each counted once
total        = subtotal − discount + delivery
balance due  = total − payments
```

| Field | Rules |
|---|---|
| **Discount** | ₹ **or** %, **set on the item** (D31). A % applies to that item's price and its add-ons, never to delivery — a courier is not an item. The order's discount is the sum of them. Rounds to the nearest rupee |
| **Delivery charge** | **Per journey.** Two cakes in one Friday delivery are charged once; a Friday and a Sunday delivery are charged twice. Seeds from the default for its delivery type; a pickup is never charged. Set on the item, in the item editor — there is deliberately **no order-level delivery charge** |
| **Advance** | Optional. Confirming with nothing collected is normal, not an error |

**Cancelled items leave the total entirely** (D27) — which is what can put a paid-up order
into credit. Anything that lists items beside a total lists only the live ones, or the two
disagree.

**Zero never shows.** A ₹0 row is absent everywhere — messages, order detail, totals, cards.
Not printed as zero, and never interpolated into a sentence, which once put the literal word
"null" in front of a customer.

### 6.5 Special requirements

Custom orders are the business, so this is a first-class field, not a note at the bottom —
and it belongs to **the item**, not the order. An order of a piped birthday cake and a plain
box of buns has one message, and printing it under "your order" left the customer to guess
which one it was for.

- **Special requirements** — free text, any length.
- **Message on the item** — stored separately so it can be proofread on its own.
- **Dietary flags** — eggless, nut-free, gluten-free, sugar-free. Chips, so they're filterable.
- **Allergy note** — pulled forward automatically from the customer onto every order. Not
  copied into the order's own requirements: it belongs to the person, and editing it should
  update it everywhere.
- **Reference photos** — what the customer sent.

**Where they must appear:** verbatim and untruncated on the kitchen card; in the confirmation
message, under the item they belong to; on order detail **above the money**.

**⚑ Edited after confirming** → the card is flagged until the kitchen acknowledges it.

### 6.6 Rules

- Confirming needs: a valid WhatsApp number, ≥1 item, a date on every item. **No advance required.**
- **Confirming hands the order to the kitchen** — every created item becomes confirmed, and
  the board starts at confirmed rather than at in-production.
- Cancelling needs a reason, at order level and at item level.
- Every edit after Confirmed is audit-trailed — who, which device, when, what, why.
- **Duplicate order in one tap.**

---

## 7. WhatsApp

**Four messages. All plain text. All open that customer's chat with the message typed —
one tap to send.**

| Trigger | Message | Sent when |
|---|---|---|
| **Confirmed** | Items, requirements, dates, addresses, money | Always. Also on a later edit, as "your order has been updated" |
| **Out for delivery** | *"On its way"* + the tracking link | **Only if that journey has a tracking link** |
| **Journey delivered** | What arrived, and what is still to come | Always, once per journey |
| **Payment received** | What was received, and what is still owed | After **every** payment, partial included |

**One journey, one message.** A two-day order gets two delivery messages, each naming only
what was on that trip. A drop with anything still outstanding says *"part of your order has
arrived"* and lists the rest; only the last one says the order is delivered.

**A collected order is collected, not arrived.** Nothing "arrives" when the customer drove to
the bakery for it.

**Money is quoted only on the final drop.** Asking for the balance while a box is still to
come reads as a demand for something not yet delivered.

**Tracking links belong to the journey**, not the order — a two-trip order can have two, and
sending Friday's van off must not quote Sunday's link.

| Case | Behaviour |
|---|---|
| Balance remains on the last drop | Message carries amount owed + UPI ID + phone |
| No tracking link | No "on its way" message is offered. The link is what the message is *for* |
| Nothing owed | Same message, money lines simply absent |
| Payment settles the order | *"That settles it — paid in full"* |
| Payment leaves the order in credit | Says what is to be refunded |
| UPI ID / phone not set | Payment lines omitted, message still reads fine |
| WhatsApp not installed | Falls back to the generic Android share sheet |

**What the app can know:** that it handed the message to WhatsApp. **Not** whether you
pressed send, nor whether it was delivered or read. The log says *"Shared 7:12 pm"*, never
"delivered ✓✓".

**Implementation:** `https://wa.me/<E164>?text=…`. Numbers must be E.164 — validate on entry,
and strip everything that is not a digit, not just the `+`. **No attachments anywhere**
(D12): a deep link can pre-select the chat but cannot attach; an attachment intent can attach
but cannot pre-select. Only one is available at a time.

**Identity:** no verified business display name, so the message body carries it — every
message opens with "Little Loaf Bakery".

---

## 8. Payments

- Amount, date, mode (UPI / cash / transfer), reference, which device recorded it.
- Multiple partial payments. Advance and balance are just payments with a type.
- Status is derived, never typed: **Unpaid / Advance paid / Paid / Refunded.** Unpaid is a
  legitimate confirmed state — nothing should treat it as a warning.
- **A ledger on the order**, collapsed by default, oldest first, each row carrying the day the
  money arrived. The Paid line answers the question most of the time; this is what you open
  when that number looks wrong.
- **Correctable and removable.** A payment edited into a negative number becomes a refund,
  because the schema requires it to. Removal is soft, like every delete here.
- The edit deliberately **does not check the amount against the balance** the way recording
  one does — this is the screen for fixing a number that was already wrong, and refusing the
  correction because the wrong number is in the way would be circular.
- **Recording money is its own trigger** for the receipt message: a part-paid order sits at
  the same status before and after, so nothing status-driven would ever fire for it.
- **Outstanding report:** everything delivered with money owed.

---

## 8b. Reminders

**Local notifications, no push server.** Every reminder is a moment the device
can work out from an order it already holds, so it is scheduled on the phone
and survives the app being closed or the phone rebooting.

| When | Covers | Why |
|---|---|---|
| **6 am**, on any day with work or shopping | the whole day | What today looks like, before the day starts. Tapping it opens the **Kitchen** |
| **30 minutes before** a journey's time | one journey | Leave now. If that mark has already gone — a rush order, or one that arrived on a sync after it — **it fires at once and says how long is really left** |
| **1 hour after**, if it has not been handed over | one journey | Nobody has moved it |

**Two per journey, not three.** A two-hour warning was built and removed: two
hours out is not a moment anybody acts on, and at thirty orders a day it was a
third of the day's notifications saying nothing new. At ten orders a day the
set above is about twenty-two notifications; at thirty it is sixty-two. That
number is the constraint every addition has to answer to — a phone that buzzes
every ten minutes gets its notifications turned off, and then the one that
mattered does not arrive either.

**What is low is on the morning too**, as one line — "Low: Butter, Flour" — and
a morning with nothing due but something to buy still speaks, because that is
exactly the morning you would want to know. It appears on the **next** morning
only: the order book is known days ahead, how much butter there will be on
Thursday is not. The schedule is rebuilt whenever stock moves, so by the time
Thursday is tomorrow its line is current.

The six o'clock digest is **not a daily repeat** — it is scheduled only on days
that actually have a handover, which the order book already knows in advance. A
notification on a quiet morning is how people learn to swipe them away without
reading.

It also covers untimed journeys, which is why they have no reminder of their
own: an "any time Friday" journey used to get its own 6 am ping, and on a day
that had a digest too, that was two notifications at the same instant saying
overlapping things.

Plus a **warning on the journey itself**, shown for as long as it is past its
time and not handed over — on the order screen and on the Kitchen board. A
notification is easy to miss and impossible to come back to; a line on the
journey is still there when you next look.

**Both phones raise the same reminder**, because both hold the same orders.
With no server there is nobody to decide whose phone should ring, and for a
delivery both owners want to know.

**Cleared by handing it over or cancelling it**, and by nothing else — a
journey marked *out* is still one the customer has not received.

**Handing over more than 4 hours late asks once**, and records the time it
actually happened. It is never refused: a van that broke down still has to be
recorded, and a handover the app will not accept is a journey that can never be
closed. The question does not apply to an untimed journey — there is no hour
for it to be four hours past.

The schedule is rebuilt wholesale whenever the orders change — cancel
everything, lay it out again — rather than tracked notification by
notification. A stale reminder for a cake already delivered is exactly what
makes somebody turn notifications off.

---

## 9. Stock

**Stock in, stock out, an alert when it's low. No recipes.**

### 9.1 The materials list

- **Material:** name, category (raw material / packaging), unit, **threshold**, active.
- **That's the whole record.** No price, no supplier, no shelf life, no batch tracking.
- **Threshold** = the "buy more" line. The one number that's decided rather than observed.
- **Price comes from history**, never the record. Last paid is derived from stock-ins.
- **Current stock is never stored** — it's summed from movements, so two phones can't disagree.

### 9.2 The bar

**No configured maximum.** The bar fills to the level the material stood at right after stock
was last added — the **reference**. Add 2 kg onto 2.5 kg and the reference becomes 4.5 kg, so
the bar is full again and reads `4.5 / 4.5 kg`.

**The threshold is the notch.** Where the fill sits relative to it is the whole reading.

| Case | Bar |
|---|---|
| Normal (reference ≥ threshold) | Scale = reference. Notch inside the bar |
| Last restock fell short | **Scale = threshold.** Notch hard at the right edge — reads as *that restock didn't get you there* |

Colour carries urgency, but **position is the real signal** — whether the fill reaches the
notch survives being colour-blind, in sunlight, or photocopied. **Nothing sits under the bar
but the bar.**

### 9.3 Movements

**Adding stock** — a sheet from the material's own row. No purchase document, no supplier, no
bill number, no photo.

| Field | |
|---|---|
| **Quantity** * | |
| **Amount** | ₹ paid. **Optional** — skipping it just means no contribution to "last paid" |
| **Use last price** | Checkbox, only if stocked before, **unchecked by default**. Shows its working: `₹520/kg × 5 kg = ₹2,600` |

**A stock-in should reach the threshold.** The sheet shows the result live and **warns** when
it falls short. It does not block; sometimes 2 kg is all there was.

**Also:** consumption (daily log, recent items first), wastage (quantity + reason, reported
separately), stock count (sets the value, records the variance).

**Purchase list:** one tap, everything below its threshold, shareable as text.

> **Accepted limitation:** without recipes, consumption isn't linked to orders. No per-cake
> ingredient cost. Reports show material spend against revenue for a period.

---

## 10. Reporting

Orders and money by month, and what sells.

- **Over time** — orders and order value as **two stacked line charts** sharing one
  month axis, over the last 3 / 6 / 12 / 24 / 36 months. Six by default.
- **This month, in three figures** — orders, order value, and what is still pending,
  side by side.
- **Any month in the past** — pick a month and year and read that month's orders.
- **By product** — quantity and revenue per menu item, grouped on `menu_item_id` so a renamed
  item still aggregates, and labelled with its newest name so the report reads in today's words.
- **Money owed**, and money owed *back* where an order is in credit.
- **Stock value** at last-paid prices.

**One rule for which month a sale belongs to:** when the last item actually went, falling
back to the promised date while anything is still outstanding. Every figure on the screen
uses it, and so does the date on every row — a list and a chart that disagree about what
"September" means are worse than no report.

A split order counts **once**, in the month its last journey lands. Splitting its value across
months would make the count and the value disagree about what they are counting.

**Profit is deliberately absent.** Without recipes there is no true COGS, and a profit line
computed from material spend against revenue would be confidently wrong.

**Computed in Dart over `OrderTotals`, not in SQL.** `OrderTotals` is the single definition of
a total; a SQL view would be a second one, and two definitions of "total" is a bug with a
schedule. The charts are a `CustomPainter`, not a dependency.

**Two charts, never two lines on one axis.** A count of orders and a pile of rupees
are different kinds of measure. Sharing an axis flattens the orders line along the
bottom; giving them an axis each makes the apparent correlation a function of where
the scales were pinned. Stacked over one month axis, both are readable and neither
claims anything about the other.

---

## 11. Screens

**One shell, four tabs**, identical on every device.

| Tab | Holds |
|---|---|
| **Orders** | Every order, grouped by the day it is next needed, with search and the alerts that used to live on Today |
| **Kitchen** | The board — journeys from **confirmed** onward. **Opens on the week**, because a cake due Thursday is started on Monday. On a **tablet** the four stages are columns read left to right; on a **phone** they stack, reversed, so what is nearest the door is at the top of the scroll |
| **Stock** | Levels, add stock, consumption, wastage, count, purchase list |
| **More** | Customers, reports, share log, sync & backup, menu items, raw materials, business settings |

**There is no Today tab.** Kitchen is the day's view, and the alerts moved to Orders.

**New order** is on Orders and Kitchen only — not Stock, not More.

**No prices on the Kitchen board** — noise in a kitchen, not a secret.

**Setup is not a login.** The app works offline from first launch; Drive is offered, and can
be connected later from Sync & backup.

### States every screen defines

| State | Behaviour |
|---|---|
| Empty | Explains what goes here and offers the action that fills it |
| Loading | Local reads are instant. A skeleton appears only during restore |
| Offline | Normal. A strip shows pending uploads; nothing is blocked |
| Sync stale | After 24h, a persistent warning with manual retry |
| Sync failed | **The reason, not just the fact** — a generic "could not connect" sent somebody looking at their wifi when the answer was a signing key |
| Merge conflict | In the conflict log, both values shown, never silent |
| Requirements changed | ⚑ until the kitchen acknowledges |
| No delivery time | Sorts to the end of its day under *Any time* |
| Zero-value row | Absent, not rendered as ₹0 |
| No tracking link | The tracking row and its message are absent — the same rule as a zero |
| Restock below threshold | Warned, not blocked |
| Update required | Full-screen block, outbox flushed first |
| App locked | Full-screen, device PIN or biometric, on cold start and after five minutes away |

### Conventions

- **`*` marks required.** Optional fields say nothing.
- **Zero never shows.**
- **Date first, everywhere.**
- Primary actions at the bottom — one-thumb reach.
- Nothing waits on the network.
- **Confirm is the only weighty button** — it's when an order becomes real.

---

## 12. Data model

```
Every entity: UUID v7 primary key + its own human-facing number where it has one.

Customer
   ├──< CustomerAddress          label, text, pin; learned from orders
   └──< Order   (id, order_no)
          ├──< SubOrder  (seq, date, time, fulfilment, address, pin,
          │       │       delivery_charge, tracking_url)   — the journey
          │       └──< OrderItem >── MenuItem   (required — items come from the menu)
          │               └──< OrderItemAddon   (name, price)
          ├──< Payment              correctable, soft-deletable
          ├──< OrderStatusEvent     append-only, audit trail
          ├──< Attachment           reference photos
          └──< ShareLog             composed, shared, when, which device

Material ──< StockTransaction   append-only: stock-in | consumption | wastage | count

Device      (id UUIDv7, name, app_version, first_seen)   one row per known device
PeerCursor  (peer_device_id, last_seq)                   local only, one per peer
Outbox      (op_id, hlc, entity, entity_id, payload, uploaded_at)
Setting (singleton)
```

- **UUID v7 primary keys throughout** — time-ordered and monotonic, so id order is creation order.
- Money as **integer paise**, never float. Percentages are basis points.
- Every row carries `device_id` (UUID v7) and `updated_at_hlc`. Timestamps UTC, shown in
  Asia/Kolkata.
- **Soft deletes only** — tombstones.
- `OrderItem` holds **`menu_item_id` (not null)** plus a **copy of the item name** at the time
  of ordering, so renaming a menu item never rewrites what an old order says.
- **The schedule lives on the journey**, not the item — one date, one place, one charge for
  everything travelling together.
- **`orders.status`, `fulfilment`, `delivery_charge`, `delivery_date`, `address_text` and
  `tracking_url` are caches**, written from the journeys and never read back as truth. Each
  describes the **finishing** journey, so anything acting on a *particular* journey must ask
  that journey. They survive because they are NOT NULL and an older peer reads them.
- **Current stock is derived**, never stored.
- **There is no `Invoice`.** Removed in schema v13 (D30).

---

## 13. Non-functional

| | |
|---|---|
| Platform | Flutter, Android 8+, tested on a mid-range phone |
| Performance | Cold start < 2s. 60fps lists at **30,000 orders** — three years at peak |
| APK | ~25 MB, worked down from 68. Reference photos downscaled to ~1600 px |
| Sync | Pull on the `:00/:05` grid, upload debounced ~5s, snapshot at 00:02 IST. Never on the main isolate. WorkManager + sync-on-resume, so Doze is never the only path |
| Auth | The Drive token is cached with its expiry and requested single-flight. Asking Credential Manager on every sync put a "Signing you in" sheet over the app every five minutes |
| Storage | Journals a few hundred KB/month; snapshots ~14 × DB; photos dominate. Usage shown in Sync & backup |
| Security | Optional PIN/biometric lock, off by default. SQLCipher at rest, key in Keystore. `drive.file` scope only |
| Privacy | DPDP 2023 — data stays in the bakery's own account, deletable on request. **A pin is a home to the metre** — stored only in Drive, deleted with the order |
| Lost phone | Remove the account remotely; treat the local copy as exposed until wiped. **The device is the credential** |
| Localization | English v1, strings externalised. ₹ with Indian digit grouping |

---

## 14. What shipped

Built and in use: storage, sync, conflict log, backup, restore, journal compaction, app lock,
the update gate, customers, menu, orders, the kitchen board, stock, payments, messaging and
reporting. Schema v13.

**Not built, and deliberately so:** recipes and true costing, GST, invoicing, a server,
accounts, analytics, iOS.

**Not built, and still open:** reference-photo pruning, CSV export, the location-chooser deep
links beyond Google Maps.

**Testing is scoped deliberately.** There are no end-to-end tests — the owner tests on a
device. Unit and widget tests run against the real schema in memory, so a constraint the UI
can violate fails in the suite rather than in someone's kitchen. That leaves one failure mode
very cheap to hit, and it has been hit: a repository method with 27 tests and **zero callers
in the app**, while the button called something else entirely. When you fix behaviour a screen
triggers, check the screen calls the thing you tested.

---

## 15. Success metrics

**Launch:** 100% of orders in the app · median create-to-confirm < 2 min · ≥95% of
confirmations shared within 5 min · zero numbering gaps.

**Sync:** a change visible on every other device within 5 min when their apps are open,
instantly on opening · **zero lost writes** in the soak test · restore drill under 5 min ·
≤1 conflict a week.

**Month 3:** ≤1 stockout/month · 100% of delivered orders have payment recorded same day ·
outstanding over 14 days under ₹5,000 · *the weekly spreadsheet stops being maintained*.

---

## 16. Open questions

1. **Advance nudge** — should the app *suggest* one above some value, as a non-blocking note?
2. **Cancellation and refund policy** — what happens to an advance, and who decides.
3. **Reference photos** — cap per order, prune from Drive after delivery? The only thing that
   grows without bound.
4. **Consumption logging** — will it happen daily? If not, inventory degrades to stock-ins
   plus counts.
5. **Low-stock alerts** — designed as local notifications, not built. Worth it, or is the
   Stock tab enough?
6. **Reversing a delivered sale** — nothing can, now that invoicing is gone. Does that ever
   need a transition of its own?

*Answered since v0.50:* delivery charge is per journey and seeds from a per-type default ·
addresses are learned from orders rather than retyped · the repo is public, with the
bakery's data nowhere near it.

---

## 17. Risks

| Risk | Mitigation |
|---|---|
| **Sync bugs lose or corrupt data** | Append-only journals, idempotent ops, nightly snapshots, conflict log, quarterly restore drills |
| **Upgrade installed after an uninstall** | Never uninstall; keep the signing key safe |
| **Bad build sets `min_supported` too high** | Only devices actually running it raise the floor, so it spreads as fast as installs do rather than all at once; the block screen always carries the update link |
| **A derived value read back from its cache** | The rule is written down and checkable: for every column the cache-refresh writes, there should be no setter and no reader outside it. Three features once wrote caches nothing read, and each silently did nothing |
| Devices offline for days | Field-level LWW limits the blast radius; overwrites logged |
| A device is lost | Nothing to transfer — the others keep working. Its replacement is a **new device with a new id**. The old journal stays readable and ages out after 30 days |
| Journals grow without bound | Compaction needs both peer cursors and snapshot inclusion; a peer silent 30 days stops being waited for |
| **Snapshot owner retired without releasing it** | Sync & backup warns after 3 days without a snapshot. Fix: delete `snapshot/owner.json` |
| Google auth expires / Drive fills | Fully usable offline; stale banner at 24h; the real error is shown, not a generic one |
| Android background limits kill the worker | Sync on resume too; pending count always visible |
| Someone forgets to tap send | Unshared confirmations are flagged on Orders |
| Bakery hires staff who shouldn't see money | Accepted. Two or three owner devices is the design point |

---

## Appendix A — Stack

| Concern | Choice |
|---|---|
| Framework | Flutter, Android only |
| Database | SQLite via `drift` |
| Encryption | SQLCipher, key in Keystore |
| Sync | Drive REST v3, `drive.file` |
| Background | WorkManager + sync-on-resume |
| Clocks | Hybrid logical clock per op |
| Documents | **None.** No invoices, no PDFs |
| Charts | A `CustomPainter`. No chart package |
| Sharing | `wa.me` deep link via `url_launcher` |
| Lock | `local_auth` — device PIN or biometric |
| Reminders | `flutter_local_notifications` + `timezone`, scheduled locally |
| Distribution | Signed APK from GitHub Releases, installed over the previous one |

**Deliberately absent from the dependency list:** any chart library, any QR package, any
analytics SDK. The APK was worked down from 68 MB to ~25 MB and stays
there on purpose.

## Appendix B — Message drafts

These are the real composed messages, not sketches.

**Confirmation** — a single-journey order

> Hi Meera, your order with Little Loaf Bakery is confirmed 🍞
>
> Order: LLB-0148-K7QP
> Cake · Chocolate · 500 g × 1
>   Piped: "Happy 40th Aarav"
>   Eggless
> Cake · Vanilla · 500 g × 1
>
> Delivery: Sat 29 Aug, 4:00 pm
> 14 Turner Rd, Bandra West, Mumbai 400050
>
> Total ₹1,890 · Advance received ₹800 · Balance due ₹1,090
>
> Please check the details above and tell us if anything is wrong.

*No advance:* `Total ₹1,890 · Payable on delivery ₹1,890`
*A pickup says* `Collect: Sat 29 Aug` *and prints no address.*

**Confirmation** — two journeys, so one heading each

> Hi Meera, your order with Little Loaf Bakery is confirmed 🍞
>
> Order: LLB-0148-K7QP
>
> **Delivery: Fri 25 Sep, 4:00 pm**
> 14 Turner Rd
> Cake · Chocolate · 500 g × 1
>
> **Collect: Sun 27 Sep**
> Cake · Vanilla · 500 g × 1
>
> Total ₹1,600 · Payable on delivery ₹1,600
>
> Please check the details above and tell us if anything is wrong.

**On its way** — only when that journey has a tracking link

> Hi Meera, your order is on its way 🚚
>
> Order: LLB-0148-K7QP
> Track it here: https://track.example.com/AB12345
>
> — Little Loaf Bakery

**Part of the order arrives**

> Hi Meera, part of your order has arrived 🎂
>
> Order: LLB-0148-K7QP
> Cake · Chocolate · 500 g × 1
> Cake · Vanilla · 500 g × 1
>
> Still to come: Cake · Butterscotch · 500 g
>
> We will let you know when the rest is on its way. Thank you for ordering from Little Loaf Bakery.

*Collected instead of delivered:* `part of your order has been collected 🎂`

**The last journey arrives, with money owed**

> Hi Meera, your order has been delivered 🎂
>
> Order: LLB-0148-K7QP
> Cake · Butterscotch · 500 g × 1
>
> Total ₹1,890 · Paid ₹800
> *Balance due ₹1,090*
>
> Pay by UPI to littleloaf@okaxis
> or to +91 98… 1102
>
> Thank you for ordering from Little Loaf Bakery

*Nothing owed* — same message, money lines absent, ending:

> Thank you for ordering from Little Loaf Bakery. We hope you enjoyed it — we would love to
> bake for you again.

**Payment received** — after every payment, partial included

> Hi Meera, we have received ₹800. Thank you!
>
> Order: LLB-0148-K7QP
> Still to pay: ₹1,090
>
> — Little Loaf Bakery

*Settled:* `That settles it — paid in full.`
*In credit:* `That leaves ₹200 to refund to you.`

## Appendix C — Brand

Everything derives from the logo's two colours.

| Token | Light | Dark | Use |
|---|---|---|---|
| `slate` | `#507991` | `#92BBD3` | The logo colour, used literally on the app bar |
| `slate-text` | `#46728B` | `#92BBD3` | Same hue, 3% darker, so body-size links clear 4.5:1 |
| `cream` | `#F8F0D8` | `#293338` | Card fills, grounds |
| `ink` | `#1A2A32` | `#F1ECDF` | Text — slate-biased, never pure black |
| `ink-2` / `ink-3` | `#435660` · `#5C6F7A` | `#A9B5BC` · `#8D9CA5` | Secondary and tertiary text |
| `good` | `#3B7259` | `#81BBA0` | Semantic only |
| `warn` | `#826026` | `#D6B171` | |
| `bad` | `#A34B3E` | `#D68F85` | |

The semantic trio is pitched at the slate's own saturation and lightness so it belongs to the
same set.

**Every pair clears WCAG AA (4.5:1) on every ground it sits on**, in both themes — checked
against the paper, the white cards *and* the cream fill, not just one background. Where the
logo slate fell a hair short as body text (4.48:1) it is darkened 3% for text and kept exact
on the app bar, which passes as-is. The logo appears in the app bar and as the launcher icon
— **never on anything the customer receives**.

## Appendix D — Google setup

One-time, ~20 minutes. No billing account, no Maps SDK, no service account, no Play Console.

1. **Google Cloud project** — any account can own it.
2. **Enable the Drive API.**
3. **OAuth consent screen** — app name, support email, developer contact. External.
4. **Scope:** `.../auth/drive.file` only.
5. **Publish the consent screen.** ⚠ In *Testing*, refresh tokens expire after 7 days — the
   app silently loses Drive access weekly, and the bakery account must be an explicit test
   user or sign-in fails outright. `drive.file` is non-sensitive, so publishing shouldn't
   trigger verification.
6. **OAuth client ID, type Android** — needs the package name and SHA-1 (debug **and**
   release). No client secret exists for Android clients.
7. **A Web client ID** as well: that is what the app passes as `serverClientId`. It ships
   inside the APK and is not a secret.
8. **Release keystore, backed up off the build machine**, and in GitHub Actions secrets.

> **Android OAuth clients are matched on package name *and* signing certificate SHA-1.**
> Nothing else identifies the app, which is why neither the Android client id nor the package
> name appears in the code — and why a CI-built debug APK, signed with a keystore the runner
> generated, can never sign in. Register your local debug SHA-1 and build debug locally when
> testing Drive.

```
keytool -list -v -keystore ~/.android/debug.keystore \
        -alias androiddebugkey -storepass android -keypass android
```
