# Payments — HLD

## Purpose
Record money as it arrives, from any device, without the two ever disagreeing.

## Responsibilities
- Payment records against an order.
- The derived payment status.
- The outstanding report.
- The UPI QR shown when collecting in person.

## Owns
`payments`.

## Depends on
orders (what is owed), config (UPI id).

## Key decisions
- **Append-only.** A payment is an insert. There is no update path, so two devices recording
  money at the same moment cannot conflict — the amounts simply add.
- **Status is derived, never typed:** Unpaid / Advance paid / Paid.
- **Money only ever comes in** (30 Sep 2026). `addPayment` refuses anything that is not a
  positive amount, and editing one can no longer turn it into a refund by making it
  negative — which was the only route to a refund and produced one without any of the rules
  a refund needs. A payment typed by mistake is **removed**, not reversed.
- **Nothing is recorded against a closed order.** Not against a completed one, where nothing
  more is owed, and not against a cancelled one, where nothing is owed at all. Both would
  leave credit that nothing could clear.
- **Unpaid is a legitimate confirmed state** (D9). Nothing in the UI treats it as a warning.
- **The QR lives on the payment sheet**, not in messages — a `upi://pay` link is not reliably
  tappable inside WhatsApp, and a QR held up at the door is where it is actually useful.
- **Advance and balance are the same thing** — payments with a type. There is no separate
  advance field to keep in step.

## Failure modes
| Case | Behaviour |
|---|---|
| Two devices record the same cash payment | Two rows, doubled total. **A human deletes one** — tombstoned, not edited. There is no automatic dedupe, because two genuine payments of the same amount are common |
| Overpayment | Allowed. The balance goes negative and is reported as credit — real, and reachable without any refund machinery |
| Payment against a completed or cancelled order | **Refused.** Nothing more is owed, and the credit it would leave has nothing able to clear it |
| Cancelling an order that has taken money | **Refused.** Hand the cash back, remove the payment, then cancel — see orders/hld.md |
| An item cancelled after it was paid for | Allowed, and leaves credit. That credit is the honest record of something paid for and not made |

## Non-goals
No payment gateway (v2, Razorpay links). No reconciliation with a bank feed.

**Refunds, for now.** The `payments` table still has a `refund` kind and a CHECK tying it to
a negative amount — an older peer may still send one, and the shape is kept for that — but
nothing in the app can create one. Refunding is its own feature, not a payment with a minus
sign: it changes what the balance means, what the outstanding total counts, and what the
payment message says. Until those are designed, the honest position is that it does not
exist, and the app says so by refusing rather than by half-doing it.
