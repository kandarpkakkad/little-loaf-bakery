# Payments — HLD

## Purpose
Record money as it arrives, from any device, without the two ever disagreeing.

## Responsibilities
- Payment records against an order.
- The derived payment status.
- The outstanding report.
- The UPI QR shown when collecting in person.
- Refunds against cancelled orders.

## Owns
`payments`.

## Depends on
orders (what is owed), config (UPI id).

## Key decisions
- **Append-only.** A payment is an insert. There is no update path, so two devices recording
  money at the same moment cannot conflict — the amounts simply add.
- **Status is derived, never typed:** Unpaid / Advance paid / Paid / Refunded.
- **Unpaid is a legitimate confirmed state** (D9). Nothing in the UI treats it as a warning.
- **The QR lives on the payment sheet**, not in messages — a `upi://pay` link is not reliably
  tappable inside WhatsApp, and a QR held up at the door is where it is actually useful.
- **Advance and balance are the same thing** — payments with a type. There is no separate
  advance field to keep in step.

## Failure modes
| Case | Behaviour |
|---|---|
| Two devices record the same cash payment | Two rows, doubled total. **A human deletes one** — tombstoned, not edited. There is no automatic dedupe, because two genuine payments of the same amount are common |
| Overpayment | Allowed. Balance goes negative and is shown as *Refund due* |
| Payment recorded against a cancelled order | Allowed; it is what a refund reverses |
| Refund larger than paid | Rejected |

## Non-goals
No payment gateway (v2, Razorpay links). No reconciliation with a bank feed. No partial
refunds against specific lines — a refund is against the order.
