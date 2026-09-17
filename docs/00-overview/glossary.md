# Glossary

Terms used precisely. Where a word has a loose everyday meaning and a strict meaning here,
the strict one wins.

| Term | Means |
|---|---|
| **Op** | One replicated change. Immutable, idempotent, identified by `op_id`. The unit of sync |
| **Journal** | A device's `ops.jsonl` in Drive. A *delivery buffer*, not an archive |
| **Outbox** | Local table of ops not yet uploaded |
| **Cursor** | How far this device has read a given peer's journal |
| **HLC** | Hybrid logical clock — `(wall_ms, counter, device_id)`. Gives ops a total order without trusting device clocks |
| **Snapshot** | A full copy of the SQLite database in Drive. Taken by one device at 00:02 IST |
| **Snapshot owner** | The device that writes snapshots. Recorded in `snapshot/owner.json`. Confers nothing else |
| **Compaction** | Dropping ops from a journal once every live peer has read them *and* they are in the latest snapshot |
| **Live peer** | A device seen within 30 days. Beyond that it stops being waited for |
| **Device** | One **installation** — not a person or a handset. UUID v7 generated at install, **never reused**. A replacement phone or a reinstall is a new device |
| **Series** | One device's own run of order numbers. Consecutive within that device only |
| **Order number** | `LLB-0148-K7QP` — sequence plus a hash of the order's UUID. Human-facing, not a key |
| **Reference** (stock) | The level a material stood at right after stock was last added. The bar's full mark |
| **Threshold** (stock) | The "buy more" line. Editable per material. Drawn as the notch on the bar |
| **Line** | One row of an order: menu item, flavour, weight, quantity, base price, add-ons |
| **Add-on** | A named charge attached to one line. Priced for the line, not per unit |
| **Share** | Handing a composed message to WhatsApp. **Not** proof it was sent |
| **Config** | The setup area: menu, raw materials, business profile, payment details, defaults |
| **Shell** | The five-tab frame every screen lives in |
