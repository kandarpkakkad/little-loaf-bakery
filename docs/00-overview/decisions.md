# Decisions

Each decision, what it bought, and what it cost. Numbered for reference from other documents.
Where a decision reversed an earlier one, that is recorded — the reversal is usually the more
interesting half.

---

### D1 · No server
**Chose:** local SQLite on each device, replicating through one Google Drive folder.
**Bought:** zero running cost, full function offline, data inside the bakery's own account.
**Cost:** no delivery receipts, no enforced permissions, no web access, eventual consistency.
**Revisit when:** a third person needs restricted access, or a second outlet appears.

### D2 · Drive stores files; it does not merge databases
**Chose:** per-device append-only journals of operations, replayed by every peer.
**Rejected:** uploading `bakery.db` and letting the last upload win — which silently destroys
whatever the other device did that day.

### D3 · One journal file per device, fixed name
**Chose:** `ops.jsonl`, re-uploaded whole.
**Consequence:** Drive has no append, so the file must stay small — hence compaction (D4).

### D4 · The journal is a delivery buffer, not an archive
**Chose:** drop an op once **every live peer has read it** *and* **it is in the latest
snapshot**. Either condition alone loses data.
**Cost:** a device silent 30 days stops being waited for and must restore from a snapshot.

### D5 · One device writes snapshots, claimed by first-come
**Chose:** `snapshot/owner.json`; missing → claim it; names someone else → skip.
**Bought:** no locking, no heartbeats. The check runs on every write, so a double-claim
self-corrects at the next attempt.
**Cost:** release is manual — delete the file. Mitigated by a warning after 3 days without a
snapshot.

### D6 · Devices are discovered, not configured
**Chose:** UUID v7 per install; sync reads every journal folder that is not its own.
**Reversed:** an earlier design named devices `phone-a` / `phone-b` and assumed two.
**A device id is never reused.** It identifies an installation, so a replacement phone or a
reinstall is a new device with a new id and a fresh number sequence. The old journal stays
readable and ages out of the live-peer set after 30 days.

### D7 · Two ids per entity
**Chose:** UUID v7 primary key + a separate human-facing number.
**Bought:** the human number can never break the data — a collision would still be two
distinct rows.
**Also:** UUID v7 is time-ordered, so id order is creation order, which is the tie-break the
order list already needed.

### D8 · Order numbers carry a hash
**Chose:** `LLB-0148-K7QP` — per-device sequence plus 4 Crockford-base32 characters derived
from the order's UUID.
**Reversed:** a device-letter prefix, which only worked if every device reached Drive at setup.
**Cost:** GST caps invoice numbers at 16 characters; this is 19, so the series shortens at
GST time.

### D9 · Advance payment is optional
**Chose:** confirming with nothing collected is normal, not an error state.

### D10 · Zero never shows
**Chose:** one rule instead of a special case per field. A ₹0 row is absent from the invoice,
the messages, order detail, totals and cards.

### D11 · Invoices are WhatsApp text, not PDFs
**Chose:** a formatted message with a monospace block.
**Bought:** no PDF pipeline, no file storage, no share sheet, no contact picker — and the one
mechanism that reliably pre-selects the chat.
**Cost:** no logo on anything the customer receives; ≤26 characters per line.
**Revisit when:** GST arrives — PDFs then, with portal filing.

### D12 · No attachments anywhere
**Chose:** every message goes through `wa.me`, text only.
**Because:** a deep link can pre-select the chat but cannot attach; an attachment intent can
attach but cannot pre-select. Only one is available at a time.

### D13 · Three messages, with variants
Confirmed → confirmation. Delivered → delivery message, always, two shapes. Completed →
payment-received note, **only if there was a balance**.

### D13b · Delivery type, and a tracking message
**Chose:** `delivery_type` of *inside city* or *out of city*, each with its own default charge,
and an optional `tracking_url` on the order.
**The message fires at Out for delivery, and only when a link exists** — that is when tracking
is useful, and a message with no link has nothing to say. It is deliberately bare: order number
and link, nothing else.
**Also available from order detail**, because the link is usually pasted in after the order has
already left.

### D14 · Delivered and Completed are separate states
**Chose:** keep them apart, so a cake handed over Saturday and paid Monday is visible all
weekend in the outstanding report.
**Reversed:** an earlier draft made Delivered terminal and treated payment as an attribute.

### D15 · Every transition is manual
**Chose:** the app offers the next step; a person takes it. Nothing advances on a payment, a
share, or the delivery date.

### D16 · Order items come from the menu
**Chose:** `menu_item_id` not null. The order line picker is a dropdown of existing
menu items — nothing else.
**Reversed:** free-typed item names, which made "sales by product" a spelling survey.
**Kept:** the line stores a copy of the name, so renaming a menu item never rewrites history.
**Cost:** an item that is not on the menu means leaving the order form for
*More › Menu items* and coming back. Accepted deliberately — the menu is short and
changes rarely, and an inline create inside the picker was judged not worth the
second way to write a menu row.

### D17 · Prices live in history, not on records
**Chose:** no price on a menu item, no price on a material. Both are typed at the moment, with
the last three shown as hints.
**Because:** customization changes what a thing costs, so there is no such thing as *the*
price of a chocolate truffle cake.

### D18 · The stock bar has no configured maximum
**Chose:** it fills to the level right after stock was last added — the *reference*. The
**threshold** is a separate editable number, drawn as a notch.
**Reversed:** a bar scaled to twice the reorder level.

### D19 · A material is four fields
name, category, unit, threshold. No price, no supplier, no shelf life, no batch tracking, no
storage location — each was either already known or would go stale.

### D20 · Address belongs to the order, not the customer
**Chose:** starts empty every time, with a *Same as last order* checkbox.
**Because:** cakes go somewhere different almost every time, and a stale inherited address is
worse than an empty field.

**Amended:** customers now keep an address *book* (`customer_addresses`) because one person
genuinely does order to several places — home, office, a relative's flat — and retyping the
same three addresses was the cost of the original rule. What D20 was protecting is kept: the
order still **snapshots** the address and pin it was placed against, and the field still starts
empty on a new order. Nothing is inherited without being chosen.

### D21 · Map pins are pasted, never sensed
**Chose:** paste the location link the customer shared. **The app never requests location
permission.**
**Bought:** no Maps SDK, no API key, no billing account.

### D22 · Menu and materials live in Config
**Because:** nothing in Config is touched during a working day; everything in the other four
tabs is.

### D23 · The palette derives from the logo's two colours
slate `#507991`, cream `#F8F0D8`. The semantic trio is pitched at the slate's own saturation
and lightness. **Every pair clears WCAG AA on every ground it sits on** — the slate is
darkened 3% for body text and kept exact on the app bar.

### D24 · The APK lives in Drive, replaced in place
**Because:** a Drive download URL contains the file id, and the URL is baked into the build —
so a new file each release would need the address of an APK that does not exist yet.
**Bonus:** Drive keeps 30 days of prior versions, which is a free rollback.

### D25 · A line is scheduled, not the order
Built — schema v10, `OrderRepository`, and every screen that reads a date.

**Chose:** delivery date, time, type, address and status move **down to `order_items`**.
One order can put a cake at the house on Friday and a snack box at the office on Sunday.
**Because:** the old model forced one date per order, so a customer wanting two dates had to
place two orders — which split the total, the discount and the payment across records that
were really one sale.
**Cost:** almost every read that used to ask an order for its date now has to ask its lines.

Two derivations, because the order needs to answer two different questions:

| | |
|---|---|
| **Due date** — what the order shows | its **last** outstanding line: when the order finishes |
| **Sort key** — where it sits in a list | its **earliest** outstanding line: when it next needs someone |

A cake on Friday and a box on Sunday reads as due Sunday and sorts on Friday. Sorting by the
due date would bury Friday's cake behind everything due earlier in the week.

**The order's delivery date is never editable** — not on create, not on edit. It is a copy of
the first derivation, maintained by the repository. A picker at order level would be writing a
value the next item change silently overwrote, which is a control that looks like it works and
does not.

### D26 · The order's status is computed, never typed
Built — `deriveOrderStatus` in `domain/orders/model.dart`.

**Chose:** you move **lines**; the order follows. `in_progress` once any line is in
production, `delivered` only when every live line is delivered.
**Because:** two hand-maintained statuses disagree eventually, and the disagreement is
invisible until someone reads an order marked delivered while a cake is still in the oven.
**Kept manual:** `confirmed` (a conversation with the customer, not a fact about lines) and
`completed` (deliberate, and still requires a zero balance).
**Cost:** you can no longer drag the whole order forward in one tap when every line moves
together. §4.3 keeps a bulk action for exactly that.

### D27 · Money stays on the order
**Chose:** payments, discount and delivery charge stay order-level even though lines are
scheduled separately. One sale, one balance, one invoice.
**Because:** a customer pays for an order, not for a line. Splitting the balance per line
would make "what do they owe?" a sum across rows that are delivered on different days.
**Consequence:** a cancelled line leaves the total — so cancelling a line after payment can
put the order in credit, which §2 makes explicit rather than letting it read as a negative
balance.
