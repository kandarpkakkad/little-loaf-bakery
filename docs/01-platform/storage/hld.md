# Storage — HLD

## Purpose
Own the local SQLite database: schema, access, migrations, and the invariants every other
module relies on. **Nothing else touches SQLite directly.**

## Responsibilities
- **Creating the database on first run** — every table, every index, and the settings row. See [`schema.md`](schema.md).
- The schema, and its versioned migrations.
- The single transaction wrapper that writes a row **and** its op together (see sync).
- Stamping `device_id` and `updated_at_hlc` on every write.
- Value types: `Money`, `Hlc`, `Uuid7`, `DeviceId`.
- Reactive queries — drift streams the UI subscribes to.
- Encryption at rest.

## Owns
Every table. The migration ladder. The `Money` and `Hlc` types.

## Depends on
`drift`, `sqlcipher_flutter_libs`, Android Keystore. Nothing in `02-domain`.

## Key decisions
- **UUID v7 primary keys everywhere** (D7). Time-ordered, so `ORDER BY id` is creation order.
- **Money is integer paise.** The domain layer never sees a raw `int` for money — only `Money`.
- **Append-only tables have no UPDATE path.** `payments`, `stock_transactions`,
  `order_status_events`, `share_log` are insert-only by construction, not by convention.
- **Soft deletes.** `deleted_at` nullable; every read filters it. A hard delete cannot replicate.
- **Derived values are never stored.** Current stock, order totals and payment status are
  computed. Two devices cannot disagree about a number neither one stores.
- **Migrations are forward-only.** A snapshot uploads before any migration runs.

## Failure modes
| Failure | Behaviour |
|---|---|
| Migration throws | Roll back the transaction, keep the old schema, surface a blocking error with the pre-migration snapshot offered |
| Keystore key missing (device restored oddly) | Database unreadable — offer restore from Drive rather than a crash loop |
| Disk full | Writes fail loudly; the outbox is unaffected because it is in the same DB |
| Corrupt DB file | `PRAGMA integrity_check` on launch after an unclean shutdown; failure → restore path |

## Non-goals
- No ORM beyond drift. No repository caching layer — drift streams are the cache.
- No cross-device transactions. Consistency is eventual, by design.
