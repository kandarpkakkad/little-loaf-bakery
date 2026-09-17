# Customers — schema

Common columns: [`01-platform/storage/schema.md`](../../01-platform/storage/schema.md)

## customers

```sql
CREATE TABLE customers (
  id           TEXT NOT NULL PRIMARY KEY,
  name         TEXT NOT NULL,
  phone_e164   TEXT NOT NULL,     -- +919876543210 — the dedupe key
  alt_phone    TEXT,
  allergy_note TEXT,              -- pulled forward onto every order they place
  notes        TEXT,
  tags         TEXT               -- comma-separated
  -- common columns
);
CREATE UNIQUE INDEX ux_cust_phone ON customers(phone_e164) WHERE deleted_at IS NULL;
CREATE INDEX        ix_cust_name  ON customers(name)       WHERE deleted_at IS NULL;
```

## customer_addresses

```sql
CREATE TABLE customer_addresses (
  id           TEXT NOT NULL PRIMARY KEY,
  customer_id  TEXT NOT NULL REFERENCES customers(id),
  label        TEXT NOT NULL,     -- Home, Office, …
  address_text TEXT NOT NULL,
  pin_lat      REAL,
  pin_lng      REAL,
  pin_url      TEXT,              -- the shared link, kept verbatim (D21)
  is_default   INTEGER NOT NULL DEFAULT 0,
  -- common columns
  CHECK ((pin_lat IS NULL) = (pin_lng IS NULL))
);
CREATE INDEX ix_addr_cust ON customer_addresses(customer_id) WHERE deleted_at IS NULL;
```

One person orders to several places, so the address book lives here (D20, amended). The
**order still snapshots** `address_text` and the pin it was placed against: editing or deleting
an address later must never rewrite where a delivered order actually went.

A new order's address field still starts empty — a saved address is *offered*, never inherited.

The partial unique index is what makes offline dedupe work: two devices can both create the
same person, and the second op to arrive triggers the merge — older UUID wins, deterministically,
so every device reaches the same survivor.

**On deletion request:** the row tombstones, orders tombstone with it, address and pin are
explicitly nulled, and invoices survive with the name replaced by "Deleted customer". The
money stays auditable; the identity does not.
