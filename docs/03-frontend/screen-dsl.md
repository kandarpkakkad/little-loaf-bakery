# Screen DSL

A declarative notation for describing every screen from the design system's primitives. Terse
enough to read in one sitting, precise enough to build from, and it makes divergence explicit
— every `when` is a branch that must be designed, not discovered.

---

## 1. Grammar

```
screen <Name>                       # S-number in a comment
  route   <path>
  tab     <Today|Orders|Kitchen|Stock|More|—>
  appbar  title=".." [sub=".."] [back] [action=..]
  body
    <primitive> <args>              # from design-system §4
    when <condition>                # a branch. Indented block applies only then
    else                            # its complement
  actions
    <Button> -> <effect>
```

**Conventions**
- `@x` — a value from the domain layer.
- `*` — required field.
- `∅` — renders nothing at all when the condition holds (not empty, *absent*).
- `⚑` — the requirements-changed flag.
- Every `when` without an `else` means: absent otherwise.

---

## 2. Shell

```
shell App
  tabs   Today · Orders · Kitchen · Stock · More
  fab    "New order" -> /orders/new          # on every tab
  strip  when @sync.syncing        -> info  "Syncing…"
         when @sync.pending > 0    -> warn  "Offline · @sync.pending waiting"
         when @sync.staleHours>=24 -> warn  "Not synced since @sync.lastAt" action="Retry"
```

---

## 3. Screens

### S01 · Setup
```
screen Setup
  route /setup   tab —
  appbar title="Little Loaf Bakery"
  body
    Text body "Connect the Google account this bakery uses."
    Button primary "Sign in with Google" -> auth.signIn
    when @auth.ok
      Field  "Name this device *"  hint="Kitchen, Counter, Riya's phone"
      Text   caption "Device id @device.id — generated once, never changes"
      when @drive.hasSnapshots
        Card  "Existing data found"
          Button ghost   "Restore from backup" -> /more/sync/restore
          Button primary "Start fresh"         -> home
      else
        Button primary "Start" -> home
  notes  Not a login. Runs once. Generates the UUID v7 device id.
```

### S02 · Today
```
screen Today
  route /today   tab Today
  appbar title="Today" sub=@date.today
  body
    Kpis [ "@count.deliveries DELIVERIES", "@count.inOven IN OVEN", "@money.toCollect TO COLLECT" ]
    when @stock.belowCount > 0
      Alert warn "@stock.firstName below threshold · @stock.firstLevel left" -> /stock
    when @share.unsentCount > 0
      Alert bad  "@share.unsentCount confirmation not sent" action="Send" -> /orders?unshared=1
    when @orders.flaggedCount > 0
      Alert warn "⚑ @orders.flaggedCount changed after confirming" -> /orders
    Micro "NEXT UP"
    List @orders.todayNext
      Card
        Row  strong @o.customer.name          | @o.deliveryTimeOrAnyTime
        Row  caption "@o.firstItem · @o.flavour" | Money @o.balanceDue
        Chips @o.dietaryFlags + @o.addressShort
    when @orders.todayNext.isEmpty
      Empty "Nothing due today." action="New order"
```

### S03 · Orders list
```
screen Orders
  route /orders   tab Orders
  appbar title="Orders" action=search
  body
    Chips filter [ All, Confirmed, "In prod", Unpaid, "Not shared" ]
    GroupedList @orders.byDeliveryDate        # date → time → created (D-sort)
      GroupHeader micro @group.dateLong
      Card -> /orders/:id
        Row  strong @o.orderNo | when @o.flagged: Chip warn "⚑"
        Row  caption "@o.firstItem · @o.flavour"
        Row  caption "@o.timeOrAnyTime · @o.status" | Money @o.balanceDue
        when @o.unshared: Chip bad "✕ not sent"
    when @orders.isEmpty
      Empty "No orders yet." action="New order"
```

### S04 · New / edit order
```
screen OrderEdit
  route /orders/new · /orders/:id/edit   tab Orders
  appbar title="New order" back action="Save draft"
  body
    Micro "CUSTOMER *"
    CustomerPicker  by=phone dedupe=e164 createInline
    when @customer.allergyNote
      Alert warn "⚠ @customer.allergyNote"
    when @customer.orderCount > 0
      Chip "Repeat · @customer.orderCount orders"

    Repeat @order.items as item, index i          # one or more lines
      Micro "ITEM @i" action=remove
      Card
        ItemPicker "Item *" source=menu           # dropdown only, no inline create
        Field    "Flavour"  suggestions=@menu.flavourHistory
        Row      Field "Weight" | NumField "Qty *" default=1
        NumField "Base price *" prefix=₹
        when @price.customerLast   Text caption "@customer.firstName last paid @price.customerLast"
        when @price.recent.any     Chips @price.recent -> fill
        Micro "ADD-ONS" action="+"
        Repeat @item.addons as a
          Row Field @a.name | NumField @a.price prefix=₹
        Row strong "Line total" | Money @item.lineTotal

        # ── each line carries its own when and where (D25) ──
        Micro "WHEN AND WHERE"
        when i > 0
          # A new line opens ALREADY carrying the one above's schedule — most
          # multi-item orders go to one place on one day, so the common case
          # needs no typing. This button puts it back after a change. A copy,
          # not a link: editing line 1 afterwards leaves line 2 alone.
          Button ghost "Same as above" -> copySchedule(from: i-1)
        Row      DateField "Delivery date *" | TimeField "Time"
        Segmented fulfilment [ Delivery, Pickup ]
        when @item.fulfilment == Delivery
          Segmented deliveryType [ Local, Outstation ]
          AddressRow @item.address -> pickAddress(@customer)
        when @item.status                       # editing an existing order
          Row Micro "STATUS" | Chip @item.status

    Button ghost "+ Add another item"          # a new line copies the one above

    Micro "SPECIAL REQUIREMENTS"
    TextArea @order.requirements
    Field    "Message on the item"
    Chips    dietary [ Eggless, Nut-free, Gluten-free, Sugar-free ]
    Photos   @order.attachments max=5

    Micro "DELIVERY"
    # Defaults the FIRST item copies, not facts about the order (D25). There is
    # no date here: each item has its own, and the order's is whatever the last
    # of them is — a picker at this level would set something the items
    # overwrite. The screen shows the derived date instead.
    Seg      [ Delivery, Pickup ]
    Text caption "Due @order.dueDate — the last item to go"
    when @order.isRush
      Alert warn "Rush — @order.leadDays days lead time"
    when @order.fulfilment == delivery
      Seg   "Where *" [ "Inside city", "Out of city" ]   # drives the default charge
      Micro "ADDRESS"
      when @customer.lastAddress
        Check "Same as last order" default=off sub=@customer.lastAddressShort
      TextArea "Address" empty                  # starts empty EVERY time (D20)
      Button ghost "📍 Paste location link" hint="from their WhatsApp"
      Field "Tracking link" keyboard=url        # usually filled in later, from the run
    else
      ∅                                          # pickup: the block does not exist

    Divider
    Row "Subtotal"                | Money @order.subtotal
    when @order.discount.isSet
      Row "Discount" Seg[₹|%] NumField @order.discountValue | Money -@order.discount
    else
      Button text "+ Add discount"
    when @order.deliveryCharge.nonZero
      Row "Delivery" NumField @order.deliveryCharge | Money @order.deliveryCharge
    Row strong "Total"            | Money @order.total
    when @order.advance.nonZero
      Row "Advance" Seg[UPI|Cash|Transfer] NumField | Money @order.advance
    else
      Button text "+ Record advance"
    Row strong "Balance due"      | Money @order.balanceDue
  actions
    Button primary "Confirm & share on WhatsApp" -> orders.confirm + messaging.offer(confirmation)
      enabled when @order.hasCustomer && @order.items.any && @order.hasDate
```

### S04d · Discount control
```
component Discount
  when unset      Button text "+ Add discount"
  when set        Row "Discount" Seg[₹|%] selected=@type NumField @value | Money -@resolved
  rules
    unit switch CLEARS the value and refocuses   # ₹100 and 100% are never the same intent
    % applies to subtotal, never to delivery
    resolved updates per keystroke; Total follows
    clearing the field removes the row and restores "+ Add discount"
```

### S05 · Order detail
```
screen OrderDetail
  route /orders/:id   tab Orders
  appbar title=@o.orderNo back action=overflow[Edit, Duplicate, Cancel]
  body
    Pipeline [ Created, Confirmed, "In prod", Ready, Out, Delivered, Completed ] at=@o.status
    Card
      Row strong @o.customer.name | caption @o.source
      Row caption "@o.deliveryDateLong · @o.timeOrAnyTime"
      when @o.addressText
        Row caption @o.addressText
        Row caption "@o.deliveryTypeLabel"
        Button text "📍 Open in…" -> sheet:Location
      when @o.trackingUrl
        Row caption "Tracking @o.trackingHost" | Button text "Copy"
      else when @o.fulfilment == delivery
        Button text "+ Add tracking link"
    when @o.flagged
      Alert warn "⚑ Requirements changed @o.requirementsChangedAt" action="Acknowledge"
    when @o.requirements || @o.itemMessage || @o.dietaryFlags
      Card                                      # ABOVE the money, always
        Micro "REQUIREMENTS"
        Text  body @o.requirements
        Row   "Message:" strong @o.itemMessage
        Chips @o.dietaryFlags + "📷 @o.photoCount"
    Card
      Repeat @o.items as i
        Row strong @i.name | Money @i.basePrice
        Row caption "@i.flavour · @i.weight · ×@i.qty"
        Repeat @i.addons as a: Row caption "+ @a.name" | Money @a.price
    Card
      Row "Subtotal" | Money @o.subtotal
      when @o.discount.nonZero  Row "Discount" | Money -@o.discount
      when @o.delivery.nonZero  Row "Delivery" | Money @o.delivery
      Row "Total" | Money @o.total
      Repeat @o.payments as p: Row "@p.kind · @p.dateShort · @p.mode" | Money @p.amount
      Divider
      Row strong "Balance due" | Money @o.balanceDue
    when @o.shareLog.any
      Alert good "✓ @lastShare.kind shared @lastShare.at"
    when @o.unshared
      Alert bad  "Confirmation never sent" action="Open WhatsApp"
  actions
    when @o.status == delivered && @o.balanceDue.nonZero
      Button ghost "Record payment" -> sheet:Payment
    when @o.status == delivered && @o.balanceDue.isZero
      Button primary "Mark completed" -> orders.transition(completed)
    when @o.canSendTracking
      Button text "Send tracking link" -> messaging.offer(outForDelivery)
    when @o.invoice
      Button text "Send invoice" -> messaging.offer(invoice)
    Text caption "Edited @o.editCount times · view history"
```

### S12 · Record payment (sheet)
```
sheet Payment
  title "Record payment"
  body
    Row  "Balance due" | Money @o.balanceDue
    Divider
    NumField "Amount *" prefix=₹ default=@o.balanceDue
    Seg      "Mode"     [ UPI, Cash, Transfer ]
    Field    "Reference"
    when @config.upiId
      Divider
      QR   @upi.uri(@amount)  caption="₹@amount pre-filled, for collecting in person"
  actions
    Button primary "Record payment" -> payments.record
  notes  Does NOT advance the order (D15). "Mark completed" is a separate tap on S05.
```

### S13 · Invoice preview
```
screen InvoicePreview
  route /orders/:id/invoice   tab Orders
  appbar title=@inv.invoiceNo back
  body
    Bubble                                   # exactly what the customer will receive
      Mono @invoicing.render(@inv)           # ≤26 chars per line, right-aligned to 26
  actions
    Button ghost   "Copy"            -> clipboard
    Button primary "Send on WhatsApp"-> messaging.offer(invoice)
```

### S14 · Share log
```
screen ShareLog
  route /more/share-log   tab More
  appbar title="Share log" sub="Last 7 days" back
  body
    List @share.recent
      Card
        Row strong @s.orderNo | when @s.sharedAt: Chip good "Shared" else: Chip bad "Not sent"
        Row caption "@s.kindLabel · @s.customerName"     # Confirmation | On its way | Delivery | Payment received
        Row caption "@s.at · @s.deviceName"
        when !@s.sharedAt
          Button primary "Open WhatsApp" -> messaging.offer(@s.kind)
    Text caption "The app knows a message was handed to WhatsApp. It cannot know whether you pressed send."
```

### S10 · Production board
```
screen Board
  route /kitchen/board   tab Kitchen
  appbar title="Production" segmented=[Board, Sheet, Deliveries]
  body
    DateStrip [ Today, +1, +2, +3 ] selected=@day
    Columns [ Confirmed, "In production", Ready, "Out for delivery" ]
      Card draggable -> orders.transition
        Row strong @o.customer.firstName | when @o.flagged: Chip warn "⚑ changed"
        Text caption "@i.name · @i.flavour · @i.weight"
        Text caption @o.requirements            # IN FULL, never truncated
        Chips @o.dietaryFlags + @o.timeOrAnyTime
  notes  NO price is selected by this screen's query. Absent, not hidden.
```

### S11 · Production sheet
```
screen Sheet
  route /kitchen/sheet   tab Kitchen
  appbar title="Production · @day.long" sub="@n items across @m orders"
  body
    List @kitchen.groupedByProduct
      Check
        Row strong "@g.name · @g.weight" | strong "×@g.qty"
        when @g.dietaryCounts  Text caption "@g.eggless eggless, @g.nutFree nut-free"
        when @g.notes          Text caption "⚑ @g.notes"      # in full
    Text caption "@rushCount orders marked rush · no prices on this sheet"
```

### S22 · Delivery run
```
screen Deliveries
  route /kitchen/deliveries   tab Kitchen
  appbar title="Deliveries" sub=@day.short segmented=[Board, Sheet, Deliveries]
  body
    List @delivery.today                        # time order, untimed last
      Card
        Row strong "@o.timeOrAnyTime · @o.customer.name" | Icons[📍,📞]
        Text caption @o.addressText
        when @o.status != delivered
          Row "Delivery" NumField @o.deliveryCharge | Button text "edit"
          Field "Tracking link" keyboard=url value=@o.trackingUrl
          when @o.trackingUrl
            Button text "Send link" -> messaging.offer(outForDelivery)
          Row strong "To collect" | Money @o.balanceDue
          Row Button ghost "Open in…" -> sheet:Location
              Button primary "Delivered" -> orders.transition(delivered)
        else
          Chip good "Done" ; Text caption "collected @o.collected @o.mode"
```

### S28 · Open location in… (sheet)
```
sheet Location
  title @o.customer.name
  body
    Text caption @o.addressText
    Divider
    when installed(maps)    Row "🗺  Google Maps" -> geo:@pinOrQuery
    when installed(uber) && @o.hasPin
                            Row "🚗  Uber"        -> uber://…
    when installed(rapido)  Row "🛵  Rapido"      -> deepLink ?? copyThenOpen
    when installed(porter)  Row "📦  Porter"      -> deepLink ?? copyThenOpen
    Divider
    Row "📋  Copy address" -> clipboard          # always last, always present
  notes  Only installed apps listed. Every entry degrades to "app opens, address on clipboard".
```

### S15 · Stock list
```
screen Stock
  route /stock   tab Stock
  appbar title="Stock" sub="@n items"
  body
    Search
    Micro "BELOW THRESHOLD · @belowCount"
    List @stock.below
      Card
        Row strong @m.name | Money-free "@m.level / @m.reference @m.unit" | Button text "+"
        Bar fill=@m.fillFraction notch=@m.notchFraction state=@m.state
    Divider
    Micro "OK · @okCount"
    List @stock.ok       … same card …
    Legend "┊ threshold, editable per material · + add stock"
  actions
    Button primary "Generate purchase list" -> /stock/purchase-list
    Button ghost   "All items · Manage list" -> /more/config/materials
  notes  Nothing sits under the bar. Category and last price live on the material.
```

### S17 · Add stock (sheet)
```
sheet AddStock
  title "Add stock"
  body
    Text strong @m.name
    Row  "In stock now" | "@m.level @m.unit"
    Divider
    NumField "Quantity *" suffix=@m.unit
    NumField "Amount"     prefix=₹                 # optional (D19)
    when @m.lastRate
      Check "Use last price" default=off
      when checked  Text caption "@m.lastRate/@m.unit × @qty @m.unit = ₹@computed"
    Divider
    Row strong "After this" | "@after @m.unit"
    when @after < @m.threshold
      Alert warn "Still below your @m.threshold @m.unit threshold"     # warns, never blocks
    else
      Alert good "✓ above your @m.threshold @m.unit threshold"
  actions
    Button primary "Add stock" -> stock.addIn
```

### S18–S21 · Consumption · Wastage · Count · Purchase list
```
screen Consumption                      # S18
  route /stock/consume   tab Stock
  appbar title="What was used" sub=@day.short back
  body
    List @stock.mostUsedFirst
      Row @m.name | NumField suffix=@m.unit        # numeric keypad, no navigation
  actions Button primary "Save" -> stock.consume

screen Wastage                      # S19
  route /stock/waste    tab Stock
  body  MaterialPicker ; NumField "Quantity *" ; Seg "Reason *" [Expired,Spoiled,Spilled,"Failed bake"]
  actions Button primary "Record wastage"

screen Count                      # S20
  route /stock/count    tab Stock
  appbar title="Stock count"
  body
    List @stock.all
      Row @m.name | caption "system @m.level" | NumField "counted"
      when @counted != @m.level  Text caption warn "variance @variance"
  actions Button primary "Save count" -> stock.count      # a reset point, not a delta

screen PurchaseList                      # S21
  route /stock/purchase-list   tab Stock
  body  List @stock.belowThreshold: Row @m.name | "@m.shortfall @m.unit short"
  actions Button primary "Share as text" -> share
```

### S06–S09 · Customers · Menu
```
screen Customers                      # S06
  route /more/customers   tab More
  body  Search by=name|phone ; List: Row strong @c.name | caption @c.phone
                                    | caption "@c.orderCount orders"

screen CustomerDetail                      # S07
  route /more/customers/:id
  body
    Card Row strong @c.name | @c.phone
         when @c.allergyNote  Alert warn "⚠ @c.allergyNote"
    Row "Lifetime value" | Money @c.lifetimeValue      # completed only
    Row "Outstanding"    | Money @c.outstanding        # delivered only
    when @c.lastAddress  Text caption "Last delivered to @c.lastAddress"   # reference, not a default
    List @c.orders -> /orders/:id

screen Menu                      # S08
  route /more/config/menu   tab More
  body  List @menu.items: Row strong @m.name | Switch @m.active
                          | when !@m.active: strikethrough
  actions Button primary "+ New item"

screen MenuItemEdit                      # S09
  route /more/config/menu/:id
  body  Field "Name *" ; Field "Category *" ; Photo ; NumField "Lead time (days)"
              Switch "Active"
  notes  NO price field. NO flavour list. Both are per order (D17).
```

### S16 · S27 · Materials
```
screen Materials                      # S27
  route /more/config/materials   tab More
  body  Seg [ "Raw material", Packaging ] ; List: Row @m.name | caption @m.unit
  actions Button primary "+"

screen MaterialEdit                      # S16
  route /more/config/materials/:id
  body
    Field    "Name *"
    Seg      "Category *" [ "Raw material", Packaging ]
    Seg      "Unit *"     [ kg, g, L, ml, pcs, box ]   # locked once movements exist
    NumField "Threshold *" suffix=@m.unit
    Divider
    Row "In stock"  | "@m.level @m.unit"
    Row "Last paid" | "₹@m.lastRate / @m.unit"
    Button ghost "View movement history" -> /stock/:id
  notes  Four fields, and two facts it works out for itself.
```

### S23 · S24 · Reports · Business
```
screen Reports                      # S23
  route  More > Reports
  appbar title="Reports"
  body
    when @reports.empty  Empty "Nothing to report yet. Deliver an order and it appears here."
    Section "Money"                   -> Still to collect · To refund
    Section "By month"                -> month | orders · outstanding | revenue
    Section "What sells"              -> item | qty sold | revenue     (by revenue, desc)
    Section "What the shelf is worth" -> material | on hand | value at last price paid
  notes  Four questions, in the order they get asked. A material never bought at a
         known price reads "price unknown", never zero — zero says worthless.

screen Business                     # S24
  route  More > Business
  appbar title="Business" action="Save"
  body
    Section "Identity"                -> name* · phone · address
    Section "Payments"                -> UPI ID · invoice footer line
    Section "Default delivery charge" -> inside city · out of city
    Section "This device"             -> device name · device id
    Section "Lock"                    -> Switch "Ask before opening"
  notes  Nothing here is touched during a working day. The lock switch saves on
         the switch, not on Save: a lock that needs a second button is a lock
         that is off.
```

**More is a flat list, not a Config screen**: Customers · Menu items · Materials · Business ·
Reports · Google Drive sync. There is no `gst_enabled` toggle — GST is out of scope for v1
and the column stays unread.

### S25 · S26 · Sync & backup · Restore
```
screen Sync                      # S25
  route  More > Google Drive sync
  appbar title="Google Drive sync" back
  body
    Card status
      when busy            "Syncing…"
      when needsReconnect  warn "Reconnect needed" + why, action="Reconnect"
      when !connected      "Not connected" + what connecting buys
      when lastRunFailed   warn "Last sync failed · it will try again on its own"
      else                 "Connected" | @auth.email | "Last synced @sync.ago"

    when !connected  Button primary "Connect Google Drive"
    else             Button outline "Sync now" · Button text "Disconnect"

    Section "Backup"                     # only when connected
      Row "Last backup" | @owner.lastSnapshotAt else "never"
      Row "Taken by"    | when mine: "this device" else @owner.deviceId.short
                          else "nobody yet"
      when @owner.staleAt(now)
        Alert warn "No backup since @owner.lastSnapshotAt. @who is the backup device.
                    If that phone is gone, delete snapshot/owner.json in the Little Loaf
                    Bakery folder in Drive, and the next device to try will take over."
      Button outline "Back up now" · Button outline "Restore"

    Row "Other devices found" | @report.peersSeen
    Row "Read successfully"   | @report.peersRead
    Repeat @report.peerVersions as p
      Row "@p.id.short… is on" | @p.version
    when @report.isolated
      Alert warn "sees its own folder and nobody else's" + same-account, same-build advice
    Repeat @report.peerErrors as e
      Alert warn "Could not read @e.id.short…: @e.error"

    Row "Waiting to upload" | @mutations.pending
    Row "This device"       | @device.id
    Row "Version"           | "@app.version (@app.build)"
  notes  Sync is invisible by design, so this screen exists for the two moments it
         is not: setting it up, and working out why it has stopped. Peer versions
         are here because a tablet three versions behind looks exactly like a
         tablet that is not syncing.

flow Restore                     # S26 — a sheet and a dialog, not a screen
  sheet  List @drive.snapshots newestFirst, first marked "Most recent" -> pick
  dialog "Restore this backup?"
         "Everything on this device is replaced with the backup from @date, and
          anything since then that has not reached Drive is lost.
          The backup is downloaded now and put in place the next time the app starts."
  then   Snackbar "Downloaded. Close and reopen the app to finish."
  notes  Staged, not live: downloaded and checked now, swapped in at the next
         open before anything holds the old database. A refusal — damaged file,
         or a snapshot from a newer app — leaves the device with what it had.
```

### S29 · Update to carry on
```
screen Blocked
  route —                         # a cover above the navigator, no back, no way past
  body
    Icon system_update warn
    Text title "Update to carry on"
    Text body  "This device is on @app.version, and the bakery has moved to
                @remote.latest. An older build can no longer read what the others
                write, so it stops here rather than showing you a half-picture.

                Everything on this device has already been sent to Drive."
    Button primary "Download the update" -> browser
    Text caption "Install it over this one — your orders stay where they are."
  notes  The outbox is flushed BEFORE this renders. The download button is always
         present, falling back to the releases page: a build that set the floor
         too high would otherwise strand every device with no way forward.
```

---

## 4. Divergences, gathered

Every branch above, in one place — so none is discovered during build.

| # | Where | Branches |
|---|---|---|
| 1 | Order fulfilment | delivery → address block · **pickup → ∅** |
| 2 | Address | first order → empty · repeat with address → *Same as last order* checkbox, off |
| 3 | Delivery time | set → shown · **unset → "Any time", sorts last** |
| 4 | Rush | date < lead time → warning, non-blocking |
| 5 | Discount | unset → "+ Add discount" · ₹ · % (shows its percentage on the invoice) |
| 6 | Delivery charge | zero → ∅ · non-zero → row · editable until Delivered |
| 7 | Advance | zero → "+ Record advance" · non-zero → row |
| 8 | Price hints | this customer's last · recent three · none |
| 9 | Item picker | menu empty → "add them under More › Menu items" · one item · many |
| 10 | Requirements | none → ∅ · present → card above the money · ⚑ changed after confirm |
| 11 | Order status | 7 states + cancelled; each gates different actions on S05 |
| 12 | Completed | offered only when balance is zero |
| 13 | Messages | confirmation always · **on-its-way only if a tracking link exists** · delivery always, **two shapes** · payment-received **only if there was a balance** |
| 13b | Delivery type | inside city · out of city · **∅ for pickup**. Drives the default charge |
| 13c | Tracking link | absent → row and message both ∅ · present → row, Copy, and Send link · addable until Delivered |
| 14 | Payment lines | UPI set · phone set · both · **neither → omitted** |
| 15 | WhatsApp | installed → `wa.me` · absent → generic share sheet |
| 16 | Invoice | %/flat discount · no advance → `AMOUNT DUE` · fully paid → `PAID` · zero rows absent |
| 17 | Stock bar | reference ≥ threshold → scale=reference · **short restock → scale=threshold, notch at the edge** |
| 18 | Add stock | last rate known → checkbox · unknown → hidden · result below threshold → warn, not block |
| 19 | Location | pin+address · pin only · address only · **neither → chooser not offered** |
| 20 | Location apps | installed only; Rapido/Porter deep link **unverified** → clipboard fallback |
| 21 | Sync strip | syncing · offline+N · stale ≥24h · otherwise ∅ |
| 22 | Peer | normal · needs upgrade · silent >30 days |
| 23 | Snapshot | mine · another device's · **stale ≥3 days → warning naming the owner** |
| 24 | Version gate | ok · banner · **blocked** · no source answered → **never blocks** |
| 25 | Setup | fresh · existing snapshots found → restore offered |
| 26 | Menu item | active · inactive |
| 27 | Material unit | editable when no movements · **locked once movements exist** |
| 28 | Empty states | every list has one, naming the action that fills it |
