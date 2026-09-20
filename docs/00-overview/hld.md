# Overview — High Level Design

## 1. What this system is

A Flutter Android app, installed on a handful of phones, that runs a custom-order bakery.
**There is no server.** Each installation holds a complete SQLite database and replicates
through one Google Drive folder.

Everything about the architecture follows from that one choice.

## 2. Module map

```
┌─────────────────────────────── UI (03-frontend) ───────────────────────────────┐
│  Shell · five tabs · 29 screens · design system · screen DSL                    │
└───────────────────────────────────────┬────────────────────────────────────────┘
                                        │ reactive streams (drift)
┌───────────────────────────────── Domain (02) ──────────────────────────────────┐
│  orders   menu   customers   invoicing   payments                              │
│  stock    messaging   fulfilment   reporting                                   │
└───────────────────────────────────────┬────────────────────────────────────────┘
                                        │ repositories · every write emits an op
┌──────────────────────────────── Platform (01) ─────────────────────────────────┐
│  storage      SQLite · drift · migrations · HLC stamping                       │
│  sync         outbox · journals · merge · compaction · cursors                 │
│  backup       snapshot ownership · nightly write · restore                     │
│  versioning   gate · GitHub Releases · APK distribution                        │
│  security     Drive auth · SQLCipher · app lock · privacy                      │
└───────────────────────────────────────┬────────────────────────────────────────┘
                                        ▼
                            Google Drive (one folder)
```

**Dependency direction is strictly downward.** Domain modules never call each other's
internals; they talk through repositories and domain events. Platform never imports domain.

## 3. The write path

Every mutation, without exception:

```
UI action
  └─ domain use-case validates
       └─ ONE SQLite transaction:
            1. write the row(s)
            2. stamp device_id + updated_at_hlc
            3. append the op to `outbox`
       └─ transaction commits → UI updates from the drift stream
  ... later, off the main isolate ...
       └─ sync worker uploads the outbox into this device's journal
```

**The op and the row commit together or not at all.** There is no window where the database
has a change the outbox does not know about.

## 3b. First run

The app creates its own database. Nothing is bundled, nothing is fetched.

```
first launch
  └─ open the encrypted SQLite file (created if absent)
       └─ onCreate: 18 tables · 19 indexes · the settings singleton
  └─ app is usable immediately — offline, empty, no sign-in
  └─ Setup (S01) connects Drive afterwards; the Drive folder is created on first sync
```

**Taking an order must never wait on a network call**, and that starts here: the very first
launch is fully functional before Google Sign-In has been touched.

## 4. The read path

```
Drive journals (peers)
  └─ sync worker pulls each peer folder that is not this device
       └─ ops applied in HLC order, idempotent by op_id
            └─ SQLite updated → drift streams → UI re-renders
```

## 5. Cross-cutting rules

| Rule | Enforced by |
|---|---|
| Local-first — no UI blocks on network | Every repository writes locally, always |
| UUID v7 primary keys | `IdGen` in storage; enforced by schema |
| Money is integer paise | `Money` value type; no raw ints in domain APIs |
| Append-only for payments, stock, status events | No `UPDATE` statements exist for those tables |
| Soft delete only | `deleted_at` column; every query filters it |
| Ops are idempotent | `op_id` primary key on the applied-ops table |
| Zero never shows | A single `formatMoneyRow()` returns null for zero |
| Nothing auto-advances an order | Status transitions only from explicit user intent |

## 6. Failure modes, and what happens

| Failure | Behaviour | Owner |
|---|---|---|
| No network | Everything works. Ops queue in the outbox | sync |
| Drive auth expired | Local work continues; stale banner after 24h | security |
| Peer journal unreadable | That peer is skipped; others still sync | sync |
| Peer needs a newer app | That journal stops applying, with a message. Others continue | versioning |
| App below `min_supported_version` | Hard block after flushing the outbox | versioning |
| Snapshot owner gone | Snapshots stop; warning after 3 days; released by hand | backup |
| Migration fails | Snapshot was taken first; restore from it | storage |
| Clock skew between devices | HLC preserves causality regardless | sync |
| Two devices edit the same field | Last-writer-wins by HLC; overwrite recorded | sync |
| WhatsApp missing or changed | The launch returns false and `share_log.shared_at` stays null, so it shows as unsent. **No share-sheet fallback is built** — the message text is composed and visible in the app either way | messaging |

## 7. Concurrency and threading

- **UI isolate** never does I/O beyond drift's own async reads.
- **Sync worker** runs in a background isolate via WorkManager, plus an opportunistic run on
  app resume so Doze is never the only path.
- **Only one sync run at a time**, guarded by a local lock. A second trigger is dropped, not
  queued — the next scheduled tick will pick up anything missed.
- **Snapshot writing** is its own worker on a 24-hour schedule aimed at 00:02 IST, registered
  beside the sync worker in `sync/background.dart`. The two do not coordinate: a snapshot is
  `sqlcipher_export`, which is transactional, so a sync writing underneath it simply lands in
  the next one. See [backup](../01-platform/backup/hld.md).

## 8. What is deliberately absent

| Not built | Because |
|---|---|
| A server of any kind | The whole premise |
| User accounts, roles, permissions | Owners only; every device holds everything anyway |
| Real-time collaboration | Drive cannot push; polling on a 5-minute grid is enough |
| Recipes / BOM | v2. No per-order ingredient costing until then |
| PDF generation | Invoices are WhatsApp text |
| Push notifications | Local notifications only |
| Analytics / telemetry | Nothing leaves the bakery's Google account |

## 9. Build order

Platform first, because everything sits on it, and because sync bugs are the ones that are
invisible until they are catastrophic.

```
storage → sync → backup → versioning → security
   └─ then: menu, customers → orders → invoicing, payments
        └─ then: stock, messaging, fulfilment, reporting
```

This matches the milestones in PRD §14.
