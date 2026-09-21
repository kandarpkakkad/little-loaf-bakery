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

### D11 · Invoices are WhatsApp text, not PDFs — **reversed by D30**
**Chose:** a formatted message with a monospace block.
**Bought:** no PDF pipeline, no file storage, no share sheet, no contact picker — and the one
mechanism that reliably pre-selects the chat.
**Cost:** no logo on anything the customer receives; ≤26 characters per line.
**Reversed by D30:** there is no invoice at all now, in any format.

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
> **Superseded.** Distribution is GitHub Releases, built and signed by the tag-driven
> pipeline. The reason this decision existed — a Drive download URL contains a file id, so a
> new file each release would need the address of an APK that does not exist yet — does not
> apply to a release page whose URL is `/releases/latest`. Every release keeps its own
> assets, which is a better rollback than the 30 days Drive was giving.

**Because:** a Drive download URL contains the file id, and the URL is baked into the build —
so a new file each release would need the address of an APK that does not exist yet.
**Bonus:** Drive keeps 30 days of prior versions, which is a free rollback.

### D25 · A line is scheduled, not the order
Built — schema v10 for the schedule, v11 for the rest.

**Everything about an item is the item's**, not just when it goes: the message
piped on it, its special requirements, its dietary flags and what its journey
costs all moved down in v11. They had been asked for at both levels, which
meant asking twice and letting the two answers disagree. An order of a piped
birthday cake and a plain box of buns has one message, on one of them.

The order still carries these as columns, rewritten from the items after any
change — NOT NULL and read by v9 peers, so they survive as a cache the way
`status` does.

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
**Chose:** payments and the discount stay order-level even though lines are scheduled
separately. One sale, one balance, one invoice.

**The delivery charge is the exception, and it proves the rule.** It is stored per item but
**counted per journey**: items sharing a day, a time, a fulfilment and an address go out
together, and `dropsOf` already grouped them for the clubbed messages. Two cakes in one van
are charged once; a Friday and a Sunday delivery are charged twice. The order's own
`delivery_charge` is the sum over journeys, so there is still one balance and one invoice.
A drop's price is the **maximum** its items name — deterministic where last-writer-wins is
not, and it errs toward charging rather than silently under-charging.
**Because:** a customer pays for an order, not for a line. Splitting the balance per line
would make "what do they owe?" a sum across rows that are delivered on different days.
**Consequence:** a cancelled line leaves the total — so cancelling a line after payment can
put the order in credit, which §2 makes explicit rather than letting it read as a negative
balance.

### D28 · An order holds sub-orders; sub-orders hold items
**Chose:** three levels. An **order** is one sale to one customer. A **sub-order** is one
journey — everything going out on the same day, at the same time, to the same place. An
**item** is one thing that gets made.

**Because:** the grouping already existed and was derived on the fly from a key of
`date · time · fulfilment · address`. A derived key can be grouped by, but it cannot *hold*
anything: not a status the kitchen moves, not a delivery charge, not a courier link, not an id
somebody can say out loud. Every one of those had to be faked onto the items and kept in step
by hand, and each was a place for two items in one van to disagree.

**A sub-order is maintained, never authored.** Nobody creates one. The order form still asks
each item when and where it goes, exactly as before; the repository finds the sub-order that
matches and puts the item in it, making one if none exists and removing one left empty. It
surfaces in the **kitchen**, where the unit of work really is "this lot, going here, then" —
and nowhere in taking or editing an order.

**Called a Delivery on screen**, or a Pickup when that is what it is. It carries an id of
`<order-no>-<n>` for the kitchen to refer to. **That id never goes in a customer message**:
the customer bought one order, and telling them it has been filed as three is the bakery's
paperwork leaking.

**Cost:** three status machines instead of two, and a table that is written by the system
rather than by a person — so its correctness rests on the maintenance being right rather than
on somebody looking at it.

### D29 · Three status machines, each derived from the one below
**Chose:**

| | Moves | Derivation |
|---|---|---|
| **Item** | `created → confirmed → in production → ready → delivered` | The kitchen moves it to in production and ready. Delivered arrives from its sub-order |
| **Sub-order** | `created → confirmed → in production → ready → [out] → delivered` | In production as soon as **any** item is. Ready when **every** live item is. Out and delivered are moved by a person — out is skipped for a pickup |
| **Order** | `created → confirmed → in production → delivered → completed` | In production as soon as **any** sub-order is. Delivered when **every** live sub-order is. Completed is manual and needs a zero balance |

**Because:** each level answers a different question. "Is this cake baked" is the item's. "Is
this van loaded" is the sub-order's. "Is this sale finished" is the order's. Deriving upward
means they cannot disagree, and the only things a person moves are the ones a person actually
decides: start it, it is ready, it has gone, it arrived, we are square.

**The order has no ready and no out.** Half a ready order is not a thing, and an order does
not travel — its sub-orders do.

**Cancelling stays at the order and the item** (D28): those are the levels where a reason
exists. A sub-order is cancelled when every item in it is, because nobody cancels a journey —
they cancel what was on it.

### D30 · No invoicing
**Chose:** the bakery does not raise bills. A payment is acknowledged over WhatsApp and that
is the whole of it. The `invoices` table, its GST columns, `FrozenTotals`, the bill message
and the settings that fed it (`gstin`, `gst_enabled`, `logo_path`, `terms_line`,
`invoice_seq`) are gone in schema v13.
**Because:** none of it was reachable. An issued invoice could not be voided from any screen,
carried no date, and dropped the business phone and terms line the settings screen collected.
Finishing it was work nobody had asked for; the payment-received message already does the job.
**Kept:** `invoice_prefix`, which despite the name prefixes **order** numbers, and
`MessageKind.paymentReceived`.
**Cost:** a delivered sale can no longer be un-counted. Voiding the invoice was the only
mechanism, and `kAllowedTransitions` allows a delivered order to become completed and nothing
else. The window for "this was not trade" now closes at the door.
**Revisit when:** GST arrives, or a customer asks for a document. Rebuild from D11's reasoning,
not from the old code.

### D31 · The discount belongs to the item
**Chose:** `discount_type` and `discount_value` on `order_items`. An order's discount is the
**sum of what came off each item**.
**Because:** an offer runs on a thing — ten percent off cakes — and an order-level percentage
made that somebody's arithmetic. Per item it is just a field.
**Bought:** reporting gets it for free. `OrderLine.total` is net of the discount and
`topItems` already sums that, so revenue per product is what it sold for rather than what it
was listed at.
**Cost:** a percentage now applies to its own item's **gross**, add-ons included, not to the
basket. Ten percent off a ₹1530 cake is ₹153, where the same figure on a ₹1890 order was
₹189. Nothing applies to delivery, which was a rule before and is now true by construction —
a courier is not an item.
**Kept:** `orders.discount_type` / `discount_value` / `discount_amount`, written from the
items as a flat amount. It is the only shape that can stand for a basket of mixed percentages
and amounts, and a v13 peer still reads a sensible number.
**Not backfilled:** an existing order keeps its discount on the order. Splitting one figure
across its items would invent a per-item price nobody agreed to.