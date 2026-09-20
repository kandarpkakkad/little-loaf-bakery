# Little Loaf Bakery — Order, Stock & Invoicing App

**Draft v0.50 · 27 August 2026 · Kandarp Kakkad**
Android · Flutter · SQLite on the phone · Google Drive for sync and backup · no server

---

## 1. What it is

Custom cake and bake pre-orders, taken over phone and Instagram, currently living in chat
threads and notebooks. This app is where an order is recorded, produced, delivered, billed
and paid — on two Android phones, with no server.

**Scale:** ~10 orders/day now, ~30 at peak. Two people. India, INR, no GST yet.

---

## 2. Non-goals

| Not doing | Why |
|---|---|
| Server, web app, hosting | Everything runs on the phone |
| WhatsApp Business API | Messages are shared from the existing number |
| Recipes / bill-of-materials | No per-order ingredient cost. v2 |
| GST | Below threshold. Schema ready, feature off. v2 |
| iOS | Android only |
| Login, accounts, roles | Two owners, both see everything |
| Counter POS, wholesale, customer login, payroll | Out of scope |

---

## 3. Users

Two owners, two phones today, one Google account (`littleloafbakeryy@gmail.com`).
**Identical access.** No permission model.

**Nothing in the design assumes two.** Devices are discovered, not configured (§4.2), so a
third or fourth phone is an install, not a change.

---

## 4. Architecture

### 4.1 Shape

```
Device 0192f3…a41c            Device 0192f4…7b02            (…any number)
  Flutter UI                    Flutter UI
  SQLite (drift)                SQLite (drift)
  outbox (pending ops)          outbox (pending ops)
       └────────────┬────────────────┘
                    ▼
        Google Drive — one folder, one account
          journal/0192f3…a41c/device.json     name, cursors, last seen
          journal/0192f3…a41c/ops.jsonl       one file, fixed name
          journal/0192f4…7b02/ops.jsonl
          snapshot/owner.json                 which device takes snapshots
          snapshot/2026-08-26.db              nightly, by the owner only
          media/ref-<uuid>.jpg
          releases + device.json              version gate
          releases/little-loaf.apk            replaced in place
```

**A device id is a UUID v7 generated at install**, and it never changes for that
installation. Nothing is named "phone A" or numbered — the folder name *is* the id.

Every write commits to local SQLite first. The UI never waits on the network.

### 4.2 Sync

Drive stores files; it does not merge databases. Each device writes **only its own
journal** and reads the other's, replaying ops into its own SQLite. Nothing is ever
overwritten.

| | |
|---|---|
| Journal | **One file per device, fixed name** — `ops.jsonl`. Only this device ever writes it |
| Upload | Debounced ~5s. Drive has no append, so the file is re-uploaded whole — which is only viable because it stays small (see compaction) |
| Download | On app resume, on pull-to-refresh, and **on the wall-clock 5-minute grid** — `:00, :05, :10 … :55`. **Lists `journal/` and pulls every folder that is not its own** |
| Devices | Discovered, never configured. A new install is a new folder, picked up on the next sync. Removing one is deleting a folder |
| Cursors | Each device publishes how far it has read each peer, in its own `device.json` |

**Pulls are aligned to the clock, not to the last pull.** Every device checks at the same
instants, so a change uploaded at `:03` is on every other device by `:05` — the lag is
bounded and predictable rather than drifting with whenever each app happened to start.
Uploads stay event-driven (debounced ~5s), because your own changes should leave immediately;
only the listening is scheduled.
| Volume | ~240 ops/day, a few hundred KB a month |
| Scope | Google Sign-In, `drive.file` only — the app sees only files it created |
| Offline | Everything works. Changes queue in the outbox |

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
- **Inserts never conflict.** Payments, stock movements and status events are append-only.
- **Field updates: last-writer-wins, per field.** Two people editing different fields both keep their change.
- **Deletes are tombstones.**

| Divergence | Behaviour |
|---|---|
| Status moved backwards by an incoming op | Surfaced in the conflict log, not applied silently |
| Devices offline for days | Merge on reconnect; every overwrite recorded in the conflict log |
| No sync for 24h | Persistent stale-sync banner, manual retry |

### 4.4 Identity and numbering

**Two ids per order, doing two different jobs.**

| | |
|---|---|
| **`id`** | **UUID v7**, generated on the device. The primary key — what ops, foreign keys and sync all reference. Never shown to anyone |
| **`order_no`** | `LLB-0148-K7QP`. Human-facing: printed, spoken on the phone, searched for. **An attribute, not a key** |

Every entity follows this. Invoices carry a UUID `id` plus `invoice_no`; so does everything
else. **UUID v7 is time-ordered**, so sorting by id is sorting by creation — the same
tie-break the rest of the app already uses (§6.4).

**Why the split matters:** the human number can never break the data. Even if two numbers
ever collided, they would still be two distinct rows that merge correctly.

**The human number carries a hash, so it is unique too.**

```
LLB-0148-K7QP
 │    │    └── 4 characters derived from the order's UUID
 │    └─────── this device's sequence
 └──────────── fixed prefix
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

Invoices take the same shape: `LLB/26-27/0148-K7QP`.

**The device code is gone from the visible number.** It was only ever there to keep numbers
apart, and the hash does that better. Which device took an order is still in the data — it
just no longer has to be read aloud.

> **One thing to check when GST arrives:** a tax invoice number is capped at 16 characters.
> `LLB/26-27/0148-K7QP` is 19, so the invoice series will need shortening then — dropping the
> hyphens and the prefix to two letters gets there. Not worth contorting the format now for a
> requirement that is a year or more away.

**First run.** The app **creates its own database on the device** — every table, every index
and a default settings row — the first time it opens. Nothing is bundled and nothing is
fetched. It is usable immediately, offline, before Google Sign-In has been touched; Setup
connects Drive afterwards, and the Drive folder is created on the first sync.

### 4.5 Backup & restore

- The journal covers the recent tail; the snapshot covers everything before it. **Restore is
  snapshot + replay of every journal**, so the two together are always complete.
- **Restore:** install → sign in → pick snapshot → replay all journals. Target under 5 minutes.
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
- Migrations: versioned, forward-only, run on first launch. **Snapshot uploads before any migration.** Tested against a seeded, realistic database.
- Restore of an old snapshot runs the same migrations — re-test after every schema change.

**Devices will be on different versions.**

| Case | Behaviour |
|---|---|
| Op has fields this build doesn't know | Ignore them. Ops are additive |
| A journal needs a newer app (`min_reader_version`) | Stop applying **that journal**, say so. Other devices' journals keep syncing. Never partial-apply |
| App below `min_supported_version` | **Hard block** (S29). Outbox flushed first, so nothing is lost |
| App below `latest_version` | Dismissible banner |
| No source answered | **Never blocks.** Cached values used |
| `apk_url` missing | Block screen drops the Download button |

The GitHub release tag for what exists; each peer's `device.json` for `app_version` and `min_supported`.
The newest app writes it. Nobody hand-edits JSON.

**Publishing an update**

1. Bump `version`. Bump `min_supported_version` only if genuinely breaking.
2. Build a signed APK **with the same keystore as always**.
3. **Replace** `releases/little-loaf.apk` in Drive — *Manage versions → Upload new version*, never a new file. A new file gets a new id, and the URL is baked into the build.
4. Install on one device; it publishes its version to the others on its next sync.

Sharing stays **off** — only the bakery account can see it, and every device is signed in.
Use `https://drive.google.com/uc?export=download&id=<file-id>`. Drive keeps prior versions
30 days, which is a free rollback.

### 4.7 What this costs

| Given up | Because | Mitigation |
|---|---|---|
| WhatsApp delivery receipts | A human taps send | Log records the share, and when |
| Enforced permissions | Every device holds the whole database | Not attempted. Owners only |
| Web / desktop access | No server | CSV export |
| Instant consistency | Drive can't push without a server | Seconds to five minutes |

---

## 5. The menu

**Every order line comes from the menu.** Item names are never typed onto an order, so the
same thing is always called the same thing — which is what makes "sales by product" a real
number rather than a spelling survey.

- **Menu item:** name, category, photo, lead time in days, active, seasonal window.
- **No price, no flavour list.** Both are decided per order (§6.2).
- Maintained in **Config** (§11).

**For something not on the menu yet: add it from the picker.** The item picker has a
Items come from the menu only. One that is not there is added under *More › Menu items*.
Nobody has to abandon a half-typed order and go to Config mid-phone-call — but what gets
created is a real menu item, not a one-off string.

**Flavour is still free text** (§6.2). The menu says *what it is*; flavour and special
requirements say how this one differs.

---

## 6. Orders

### 6.1 Lifecycle

```
Created → Confirmed → In production → Ready → Out for delivery → Delivered → Completed
   │           │             │                                        │
   └───────────┴─────────────┴──────────► Cancelled ◄─────────────────┘
```

**Every step is taken by a person.** The app never advances an order itself — not on a
payment, not on a share, not on the delivery date. It offers; it does not move.

| State | What happens |
|---|---|
| **Created** | Quoted, not committed. Freely editable. Nothing shared |
| **Confirmed** | Committed. Offers the confirmation message. Advance **not required** |
| **In production** | Set by whoever starts baking |
| **Ready** | Out of the oven, boxed |
| **Out for delivery** | Rider or courier has it. **Offers the tracking message when a link exists** |
| **Delivered** | Bill of supply issued. Offers the delivery message and the payment sheet |
| **Completed** | Money is in. Offers the payment-received note **only if there was a balance** |
| **Cancelled** | From any state before Delivered. Needs a reason and a refund decision |

### 6.2 An order line

| Field | | |
|---|---|---|
| **Item** * | | **From the menu.** Not typed, and not created here — the menu is maintained in Config |
| **Flavour** | free text | Past flavours suggested |
| **Weight** | | Blank for anything not sold by weight |
| **Quantity** * | | Defaults to 1 |
| **Base price** * | ₹ | Typed. Last 3 prices shown; the customer's own last price first |
| **Add-ons** | 0..n | Name + price each. Priced for the line, not multiplied by quantity |
| **Note** | | Specific to this line |

**An order has one or more lines**, each independently priced.

```
line total  = base price × quantity + add-ons
subtotal    = Σ line totals
discount    = flat ₹, or % × subtotal
total       = subtotal − discount + delivery
balance due = total − payments
```

### 6.3 Order-level money

| Field | Rules |
|---|---|
| **Discount** | ₹ **or** %. A % applies to the subtotal, never to delivery. Recomputes while editing; **frozen once the invoice is issued**. Rounds to the nearest rupee |
| **Delivery charge** | Pre-fills from Config. **Editable until Delivered**, including from the delivery run — the balance recalculates and the invoice carries what was actually charged |
| **Advance** | Optional. Confirming with nothing collected is normal, not an error |

**Zero never shows.** A ₹0 row is absent everywhere — invoice, messages, order detail,
totals, cards. Not printed as zero.

### 6.4 Date, time, address

| Field | Rules |
|---|---|
| **Delivery date** * | Date picker, defaults to the soonest the lead times allow. A shorter date is allowed but shows a **rush warning** (non-blocking) |
| **Delivery time** | Picker that also accepts typing. Optional. **Editable later** |
| **Address** | Free text + optional map pin. **Starts empty every time** — no pre-fill, no address book |
| **Delivery type** | **Inside city** or **out of city**. Set on the order; the default charge differs per type |
| **Tracking link** | A URL, entered by hand once the rider or courier is booked. Optional, editable until Delivered |

**"Same as last order"** — one checkbox, shown only when that customer has a previous order
with an address, **unchecked by default**.

**Pickup hides the address block entirely** — absent, not empty.

**The pin** is captured by pasting the location link the customer shared on WhatsApp. Lat/lng
extracted where present; the original link kept either way. **The app never asks for location
permission** — nothing is read from the phone's GPS.

**Sort order everywhere:** `delivery date → delivery time → order created time`.
Untimed orders go to the end of their day under *Any time*, ordered among themselves by
created time. Created time breaks every tie.

### 6.5 Special requirements

Custom orders are the business, so this is a first-class field, not a note at the bottom.

- **Special requirements** — free text, any length.
- **Message on the item** — stored separately (`orders.item_message`) so it can be
  proofread on its own. Not only cakes carry one.
- **Dietary flags** — eggless, nut-free, gluten-free, sugar-free. Chips, so they're filterable.
- **Allergy note** — pulled forward automatically from the customer onto every order.
- **Reference photos** — what the customer sent.

**Where they must appear:** verbatim and untruncated on the board card and production sheet;
in the confirmation message so the customer reads them back; on order detail **above the
money**.

**⚑ Edited after confirming** → the board card is flagged until the kitchen acknowledges it.

### 6.6 Rules

- Confirming needs: a valid WhatsApp number, ≥1 line, a delivery date. **No advance required.**
- Every edit after Confirmed is audit-trailed — who, which device, when, what, why.
- **Duplicate order in one tap.**

---

## 7. Invoice

A **formatted WhatsApp message**, not a PDF. Issued at Delivered, sent only on request —
the delivery message already covers the normal case.

Numbered per device (§4.4). Cancelled invoices are voided, never deleted.

```
*Little Loaf Bakery*
+91 98… 1102

*Bill of Supply*
LLB/26-27/0148-K7QP · 29 Aug 2026

To: Meera Shah

```(monospace)
Chocolate Truffle
Belgian dark · 1 kg
  1 x 1,450         1,450
  + Message on item    50
  + Candles            30
Sourdough loaf
  2 x   180           360
--------------------------
Subtotal              1,890
Discount               -100
Delivery                100
TOTAL                 1,890
Advance paid            800
BALANCE DUE           1,090
```(end)

Pay by UPI to littleloaf@okaxis

Not registered under GST.
```

**The monospace block wraps rather than scrolls**, and a wrapped line destroys the alignment.
So: **every line ≤ 26 characters**, amounts right-aligned to column 26, and **a product name
always gets its own line** so it can wrap harmlessly.

| Variant | Renders as |
|---|---|
| % discount | `Discount 10%           -189` |
| Flat discount | `Discount               -100` |
| No advance | Last two rows collapse to `AMOUNT DUE` |
| Fully paid | Collapse to `PAID · thank you`; UPI line dropped |
| No delivery / no discount | Row absent entirely |

**No logo** — the bakery name in bold does that work. **Save as PDF** is v1.5, for the
customer who asks.

**At GST:** generate PDFs and register on the portal. v2 project. Schema already carries
`gstin`, `hsn_code`, `tax_rate`, `cgst`, `sgst`, `igst`, `place_of_supply` behind
`gst_enabled` — no migration. *(Check with an accountant: B2C usually reports in aggregate
in GSTR-1, not invoice by invoice.)*

---

## 8. WhatsApp

**Three messages. All plain text. All open that customer's chat with the message typed —
one tap to send.**

| Trigger | Message | Sent when |
|---|---|---|
| **Confirmed** | Items, requirements, date, time, address, paid, due | Always |
| **Out for delivery** | *"On its way"* + the tracking link | **Only if a tracking link has been entered** |
| **Delivered** | Order details + thank-you; **plus** balance and how to pay | Always — two shapes |
| **Completed** | *"We have received your payment. Thank you."* No amounts | **Only if there was a balance** |

**No attachments anywhere.** That's what keeps everything on `wa.me` — the one mechanism
that reliably pre-selects the chat. An attachment would force a contact picker.

| Case | Behaviour |
|---|---|
| Balance remains at Delivered | Message carries amount owed + UPI ID + phone |
| No tracking link at Out for delivery | No message is offered. The link is what the message is *for* |
| Link added after the order already went out | Still offerable from order detail, until Delivered |
| Nothing owed at Delivered | Same message, money lines simply absent |
| Never had a balance | No Completed message at all |
| UPI ID / phone not set | Payment lines omitted, message still reads fine |
| WhatsApp not installed | Falls back to the generic Android share sheet |
| Customer opted out | Copy message text instead |

**What the app can know:** that it handed the message to WhatsApp. **Not** whether you
pressed send, nor whether it was delivered or read. The log says *"Shared 7:12 pm"*, never
"delivered ✓✓". Unshared confirmations nag on Today until cleared.

**Implementation:** `https://wa.me/<E164>?text=…`. Numbers must be E.164 — validate on entry.
URL-encode carefully: newlines are `%0A`, and `*` `_` and backticks must survive intact.
Cap the line count so a very long order can't overflow the URL.

**Identity:** no verified business display name, so the message body carries it — every
message opens with "Little Loaf Bakery", in bold on the invoice.

---

## 9. Payments

- Amount, date, mode (UPI / cash / transfer), reference, which device recorded it.
- Multiple partial payments. Advance and balance are just payments with a type.
- Status is derived, never typed: **Unpaid / Advance paid / Paid / Refunded.** Unpaid is a
  legitimate confirmed state — nothing should treat it as a warning.
- **Outstanding report:** everything at Delivered with money owed, oldest first.
- **UPI QR lives on the payment sheet**, not in messages — a `upi://pay` link isn't reliably
  tappable in WhatsApp. A QR held up at the door is where it's useful.
- Append-only, so any number of devices can record payments without conflict.

---

## 10. Stock

**Stock in, stock out, an alert when it's low. No recipes.**

### 10.1 The materials list

The stock side of the menu. Maintained in **Config**, alongside the menu — both are setup (§11).

- **Material:** name, category (raw material / packaging), unit, **threshold**, active.
- **That's the whole record.** No price, no supplier, no shelf life, no batch tracking, no storage.
- **Threshold** = the "buy more" line. The one number that's decided rather than observed. Editable.
- **Price comes from history**, never the record. Last paid is derived from stock-ins.
- **Current stock is never stored** — it's summed from movements, so two phones can't disagree.

### 10.2 The bar

**No configured maximum.** The bar fills to the level the material stood at right after stock
was last added — the **reference**. Add 2 kg onto 2.5 kg and the reference becomes 4.5 kg, so
the bar is full again and reads `4.5 / 4.5 kg`.

**The threshold is the notch.** Where the fill sits relative to it is the whole reading.

| Case | Bar |
|---|---|
| Normal (reference ≥ threshold) | Scale = reference. Notch inside the bar |
| Last restock fell short | **Scale = threshold.** Notch hard at the right edge — reads as *that restock didn't get you there* |

Colour carries urgency, but **position is the real signal** — whether the fill reaches the
notch survives being colour-blind, in sunlight, or photocopied. Nothing sits under the bar
but the bar.

### 10.3 Movements

**Adding stock** — a sheet from the material's own row. No purchase document, no supplier, no
bill number, no photo.

| Field | |
|---|---|
| **Quantity** * | |
| **Amount** | ₹ paid. **Optional** — skipping it just means no contribution to "last paid" |
| **Use last price** | Checkbox, only if stocked before, **unchecked by default**. Shows its working: `₹520/kg × 5 kg = ₹2,600` |

**A stock-in should reach the threshold.** The sheet shows the result live and **warns** when
it falls short — *"After this: 4.5 kg, still below your 8 kg threshold"*. It does not block;
sometimes 2 kg is all there was.

**Also:** consumption (daily log, recent items first, numeric keypad), wastage (quantity +
reason, reported separately), stock count (sets the value, records the variance).

**Below-threshold alerts** fire as local notifications. No push server, so **every device would
nag about the same butter** — acknowledging writes an op, so dismissing on one clears the
other.

**Purchase list:** one tap, everything below its threshold, shareable as text.

> **Accepted limitation:** without recipes, consumption isn't linked to orders. No per-cake
> ingredient cost. Reports show material spend against revenue for a period.

---

## 11. Screens

**29 screens, one shell, five tabs**, identical on every device.

**Config is where the app is set up**, and the only place the two lists are maintained:

| Config holds | |
|---|---|
| **Menu** | The fixed list of what the bakery makes (§5) |
| **Raw materials** | The fixed list of ingredients and packaging (§10.1) |
| Business profile | Name, logo, address, phone, invoice prefix, terms |
| Payment details | UPI ID and phone number, used in messages and the QR |
| Defaults | Delivery charge — **one for inside city, one for out of city** |
| Switches | `gst_enabled`, app lock |
| This device | Name, id, and the sequence it is on |

Nothing in Config is touched during a working day. Everything in the other four tabs is.

| Tab | Holds |
|---|---|
| **Today** | Deliveries today, in production, money to collect, alerts |
| **Orders** | List, search, order detail, invoice preview |
| **Kitchen** | Board · Sheet · Deliveries |
| **Stock** | Levels, add stock, consumption, wastage, count, purchase list |
| **More** | Customers, reports, share log, sync &amp; backup, **Config** |

A floating **New order** on every tab. **No prices on the Kitchen screens** — noise in a
kitchen, not a secret.

| # | Screen | Tab | MS |
|---|---|---|---|
| S01 | Setup — connect Drive, name this device, fresh or restore. Generates the device id. **Not a login** | — | M0 |
| S02 | Today | Today | M1 |
| S03 | Orders list | Orders | M1 |
| S04 | New / edit order | Orders | M1 |
| S05 | Order detail | Orders | M1 |
| S06 | Customers list | More | M1 |
| S07 | Customer detail | More | M1 |
| S08 | Menu | Config | M1 |
| S09 | Menu item editor | Config | M1 |
| S10 | Production board | Kitchen | M1 |
| S11 | Daily production sheet | Kitchen | M1 |
| S12 | Record payment — sheet | — | M3 |
| S13 | Invoice preview | Orders | M3 |
| S14 | Share log | More | M3 |
| S15 | Stock list | Stock | M4 |
| S16 | Material detail | Config | M4 |
| S17 | Add stock — sheet | — | M4 |
| S18 | Consumption log | Stock | M4 |
| S19 | Wastage entry | Stock | M4 |
| S20 | Stock count | Stock | M4 |
| S21 | Purchase list | Stock | M4 |
| S22 | Delivery run | Kitchen | M5 |
| S23 | Reports | More | M5 |
| S24 | Config | More | M0/M5 |
| S25 | Sync & backup | More | M2 |
| S26 | Restore | More | M2 |
| S27 | Raw materials list & editor | Config | M4 |
| S28 | Open location in… — sheet | — | M5 |
| S29 | Update required — block | — | M0 |

### States every screen defines

| State | Behaviour |
|---|---|
| Empty | Explains what goes here and offers the action that fills it |
| Loading | Local reads are instant. A skeleton appears only during restore |
| Offline | Normal. A strip shows pending uploads; nothing is blocked |
| Sync stale | After 24h, a persistent warning with manual retry |
| Merge conflict | In the conflict log, both values shown, never silent |
| Not shared yet | Any of the three messages composed but never sent — nagged on Today |
| Requirements changed | ⚑ until the kitchen acknowledges |
| No delivery time | Sorts to the end of its day under *Any time* |
| Zero-value row | Absent, not rendered as ₹0 |
| No tracking link | The tracking row and its message are absent — the same rule as a zero |
| Restock below threshold | Warned, not blocked |
| Update required | Full-screen block, outbox flushed first |

### Conventions

- **`*` marks required.** Optional fields say nothing.
- **Zero never shows.**
- **Date first, everywhere.**
- Primary actions at the bottom — one-thumb reach.
- Nothing waits on the network.
- **Confirm is the only weighty button** — it's when an order becomes real.

### Opening a location — S28

Only installed apps are listed. **Copy address is always last**, and always works.

| App | How | Confidence |
|---|---|---|
| Google Maps | `geo:` intent / universal link | Documented |
| Uber | `uber://?action=setPickup&dropoff[latitude]=…` | Documented |
| Rapido, Porter | Deep link if one works; else open the app with the address on the clipboard | **Unverified — test in M5** |
| No pin at all | Maps with the written address as a search query | — |

Never depends on a third-party deep link succeeding.

---

## 12. Data model

```
Every entity: UUID v7 primary key + its own human-facing number where it has one.

Customer
   └──< Order   (id, order_no, own address text + pin)
          ├──< OrderItem >── MenuItem   (required — lines always come from the menu)
          │       └──< OrderItemAddon   (name, price)
          ├──< Payment              append-only
          ├──< OrderStatusEvent     append-only, audit trail
          ├──< Attachment           reference photos
          ├──1 Invoice            (id, invoice_no)
          └──< ShareLog             composed, shared, when, which device

Material ──< StockTransaction   append-only: stock-in | consumption | wastage | count

Device      (id UUIDv7, name, first_seen)                one row per known device
PeerCursor  (peer_device_id, last_seq)                   local only, one per peer
Outbox      (op_id, hlc, entity, entity_id, payload, uploaded_at)
Setting (singleton)
```

- **UUID v7 primary keys throughout** — time-ordered, so id order is creation order.
- Money as **integer paise**, never float.
- Every row carries `device_id` (UUID v7) and `updated_at_hlc`. Timestamps UTC, shown in
  Asia/Kolkata.
- **Soft deletes only** — tombstones.
- `OrderItem` holds **`menu_item_id` (not null)** plus a **copy of the item name** at the time
  of ordering, so renaming a menu item never rewrites what an old order says — the same rule
  as prices.
- `OrderItem.base_price` is entered on the order; price hints are a query over past rows.
- `Order.delivery_charge` mutable until Delivered.
- `Order` carries `discount_type` (`percent`|`amount`), `discount_value`, `discount_amount`.
- **Current stock is derived**, never stored.

---

## 13. Non-functional

| | |
|---|---|
| Platform | Flutter, Android 8+, tested on a mid-range phone |
| Performance | Cold start < 2s. 60fps lists at **30,000 orders** — three years at peak |
| APK | Under 40 MB. Reference photos downscaled to ~1600 px |
| Sync | Pull on the `:00/:05` grid, upload debounced ~5s, snapshot at 00:02 IST. Never on the main isolate. WorkManager + sync-on-resume, so Doze is never the only path |
| Storage | Journals a few hundred KB/month; snapshots ~14 × DB; photos dominate. Usage shown in Sync &amp; backup |
| Security | Optional PIN/biometric lock, off by default. SQLCipher at rest, key in Keystore. `drive.file` scope only |
| Privacy | DPDP 2023 — data stays in the bakery's own account, deletable on request, 3-year retention then anonymised. **A pin is a home to the metre** — stored only in Drive, deleted with the order |
| Lost phone | Remove the account remotely; treat the local copy as exposed until wiped. **The device is the credential** |
| Localization | English v1, strings externalised. ₹ with Indian digit grouping |

---

## 14. Release plan

| M | Scope | Screens | Est. |
|---|---|---|---|
| M0 | Scaffold, drift schema, HLC + outbox, sign-in, Drive bootstrap, Config shell, app lock, version gate | S01, S24, S29 | 1.5 wks |
| M1 | Customers, menu, order creation, lifecycle, board, sheet | S02–S11 | 3 wks |
| M2 | Sync engine, merge, conflict log, snapshots, restore | S25, S26 | 2 wks |
| M3 | Payments, invoice message, WhatsApp send, share log | S12–S14 | 1.5 wks |
| M4 | Materials, add stock, consumption, wastage, count, alerts, purchase list | S15–S21, S27 | 2 wks |
| M5 | Delivery run, location chooser + deep-link testing, reports, CSV | S22, S23, S28 | 1.5 wks |
| M6 | Restore drill, migration drill, **three-device soak** (to prove nothing assumes two), DPDP review, pilot | all states | 1 wk |

**12.5 weeks.** Sync lands at M2 deliberately — highest risk, least visible bugs, so it gets
six weeks of real use before launch. Run live on the real devices from the end of M3 (~week 8).

**Beyond v1:** delivery-day reminder; repeat-order suggestions; print the production sheet ·
**v2** recipes and true costing; GST with PDFs and portal filing; Razorpay links · **v3** a
real backend if the bakery outgrows two or three people.

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

1. **Whose phones?** Personal or bakery-owned — decides whether app-lock and remote wipe are enforceable.
2. **Advance nudge** — should the app *suggest* one above some value, as a non-blocking note?
3. **Cancellation and refund policy** — needed as invoice terms, and to decide what happens to an advance.
4. **Default delivery charge** — one flat rate, or slabs by area?
5. **Existing data** — a customer list worth importing, or start empty?
6. **Reference photos** — cap per order, prune from Drive after delivery? The only thing that grows without bound.
7. **Consumption logging** — will it happen daily? If not, inventory degrades to stock-ins plus counts, and S18 drops.

---

## 17. Risks

| Risk | Mitigation |
|---|---|
| **Sync bugs lose or corrupt data** | Append-only journals, idempotent ops, nightly snapshots, conflict log, multi-device soak test from M2, quarterly restore drills |
| **Upgrade installed after an uninstall** | Never uninstall; keep the signing key safe; snapshot before every migration |
| **Bad build sets `min_supported` too high** | Only devices actually running it raise the floor, so it spreads as fast as installs do rather than all at once; the block screen always carries the update link and Restore |
| Devices offline for days | Field-level LWW limits the blast radius; overwrites logged |
| A device is lost | Nothing to transfer — the others keep working. Its replacement is a **new device with a new id**, starting a fresh sequence. The old journal stays readable and ages out after 30 days |
| Journals grow without bound | Compaction needs both peer cursors and snapshot inclusion; a peer silent 30 days stops being waited for |
| **Snapshot owner retired without releasing it** | Snapshots stop and journals stop compacting | Sync & backup warns after 3 days without a snapshot. Fix: delete `snapshot/owner.json` |
| Google auth expires / Drive fills | Fully usable offline; stale banner at 24h; usage in Sync &amp; backup |
| Android background limits kill the worker | Sync on resume too; pending count always visible |
| WhatsApp changes text formatting | Verify on the real devices in M3; content stays complete even unformatted |
| Someone forgets to tap send | Unshared confirmations nag on Today |
| Consumption not logged | 15-second entry; weekly count as the correction |
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
| Documents | **None** — invoices are WhatsApp text |
| QR | `qr_flutter`, on the payment sheet |
| Sharing | `wa.me` deep link via `url_launcher` |
| Notifications | `flutter_local_notifications` |
| Distribution | Signed APK from Drive |

## Appendix B — Message drafts

**Confirmation** — at Confirmed

> Hi Meera, your order with Little Loaf Bakery is confirmed 🍞
>
> Order: LLB-0148-K7QP
> Chocolate Truffle · Belgian dark · 1 kg × 1
>   + Message on item, Candles
> Sourdough loaf × 2
> Message on item: "Happy 40th Aarav"
> Notes: gold lettering, pastel blue rosettes, no fondant figures
>
> Delivery: Sat 29 Aug, 4:00 pm
> 14 Turner Rd, Bandra West, Mumbai 400050
>
> Total ₹1,890 · Advance received ₹800 · Balance due ₹1,090
>
> Please check the details above and tell us if anything is wrong.

*No advance:* `Total ₹1,890 · Payable on delivery ₹1,890`

**On its way** — at Out for delivery, only when a tracking link exists

> Hi Meera, your order is on its way 🚚
>
> Order: LLB-0148-K7QP
> Track it here: https://track.example.com/AB12345
>
> — Little Loaf Bakery

Nothing else. The customer wants the link, not a restatement of the order.

**Delivery** — at Delivered, always. *Balance remaining:*

> Hi Meera, your order has been delivered 🎂
>
> Order: LLB-0148-K7QP
> Chocolate Truffle · Belgian dark · 1 kg × 1
>   + Message on cake, Candles
> Sourdough loaf × 2
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

**Payment received** — at Completed, only if there was a balance

> Hi Meera, we have received your payment. Thank you!
>
> — Little Loaf Bakery

No amount, no summary. They know what they paid.

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
on the app bar, which passes as-is. The logo appears in the app bar and as the launcher icon — **never on anything the
customer receives**.

**Still needed:** adaptive launcher icons at every density, and an SVG original if one exists.

## Appendix D — Google setup

One-time, ~20 minutes. No billing account, no Maps SDK, no service account, no Play Console.

1. **Google Cloud project** — any account can own it.
2. **Enable the Drive API.**
3. **OAuth consent screen** — app name, support email, developer contact. External.
4. **Scope:** `.../auth/drive.file` only.
5. **Publish the consent screen.** ⚠ In *Testing*, refresh tokens expire after 7 days — the app silently loses Drive access weekly. `drive.file` is non-sensitive, so publishing shouldn't trigger verification; the console will confirm.
6. **OAuth client ID, type Android** — needs the package name and SHA-1 (debug and release). No client secret exists for Android clients.
7. **Release keystore, backed up off the build machine.**

Have ready: package name (fix it now — changing it invalidates the client), SHA-1 fingerprints, support and developer emails.

```
keytool -list -v -keystore ~/.android/debug.keystore \
        -alias androiddebugkey -storepass android -keypass android
```
