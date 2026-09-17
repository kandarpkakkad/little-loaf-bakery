# Sync — HLD

## Purpose
Keep every device's SQLite converging on the same state, through a Drive folder, with no
server and no coordination.

## The core idea
**Drive stores files; it does not merge databases.** So each device writes only its own
append-only journal of *operations*, and reads everyone else's. Nothing is ever overwritten,
so nothing can be lost by two devices acting at once.

## Responsibilities
- Upload this device's outbox into `journal/<device-id>/ops.jsonl`.
- Discover peers by listing `journal/`, and pull every folder that is not this device.
- Apply ops idempotently, in HLC order, with field-level last-writer-wins.
- Maintain cursors, publish them, and compact the journal once ops are safely elsewhere.
- Surface conflicts rather than resolving them silently.

## Owns
`outbox`, `applied_ops`, `peer_cursors`, `devices`, the conflict log, and the sync worker.

## Depends on
storage (the write transaction, HLC), security (Drive credentials), backup (snapshot
inclusion, for compaction).

## Schedule
| | |
|---|---|
| Upload | Debounced ~5s after any change |
| Pull | On resume, on pull-to-refresh, and on the wall-clock 5-minute grid `:00 :05 … :55` |
| Why aligned | Every device checks at the same instants, so lag is bounded and predictable rather than drifting with whenever each app started |

## Key decisions
- **One fixed-name file per device** (D3). Drive has no append, so it is re-uploaded whole —
  viable only because compaction keeps it at roughly a day's work.
- **Compaction needs two conditions** (D4): every live peer has read past the op **and** it is
  in the latest snapshot. Either alone loses data.
- **Devices are discovered, never configured** (D6). A new install is a new folder.
- **Field-level LWW.** Two people editing different fields of the same order both keep their
  change.
- **Inserts never conflict.** Payments, stock movements and status events are append-only, so
  the common case has no decision to make.

## Failure modes
| Failure | Behaviour |
|---|---|
| Offline | Ops queue. Nothing blocks |
| One peer's journal is corrupt | That peer is skipped and logged; others still apply |
| A peer's journal needs a newer app | **That journal** stops applying, with a message. Others continue |
| Upload fails mid-way | Whole-file upload is atomic in Drive — either the old or the new version, never a splice |
| Two devices claim the same order number | Both rows exist and merge; only the display collides (D7) |
| Status moved backwards by a peer | Applied, but written to the conflict log rather than silently accepted |
| Clock skew | HLC preserves causality; no op is ever rejected for being "too old" |

## Non-goals
- No operational transform, no CRDT beyond LWW registers. At two to four devices doing
  different jobs, true conflicts are rare; the design's job is to never corrupt, not to be clever.
- No real-time. No push. No presence.
