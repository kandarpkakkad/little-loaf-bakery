# Messaging — HLD

## Purpose
Get three messages to the customer from the bakery's existing WhatsApp number, with no
Business API, no server and no attachments.

## The four messages
| Trigger | Message | Sent when |
|---|---|---|
| **Confirmed** | Items, requirements, date, time, address, paid, due | Always |
| **Out for delivery** | *"On its way"* + the tracking link | **Only if a tracking link exists** |
| **Delivered** | Order details + thank-you; **plus** balance and how to pay | Always — two shapes |
| **Completed** | *"We have received your payment. Thank you."* No amounts | **Only if there was a balance** |

The tracking message is **deliberately bare** — order number and link, nothing else. The
customer opening it wants the link, not a restatement of what they ordered.

## Responsibilities
- Compose each message from the order.
- Hand it to WhatsApp and record that it was handed over.
- Chase anything composed but never shared.

## Owns
`share_log`.

## Depends on
orders, payments, invoicing (for the bill text), config (UPI details, phone).

## Key decisions
- **No attachments anywhere** (D12). A `wa.me` deep link can pre-select the chat but cannot
  attach; an attachment intent can attach but cannot pre-select. Only one is available at a
  time, and pre-selecting the chat is worth more.
- **The app cannot know it was sent.** It knows it handed the message to WhatsApp. The log
  says *"Shared 7:12 pm"*, never "delivered ✓✓".
- **Unshared confirmations nag on Today** until cleared. That is the only quality control
  available, and at this volume it is enough.
- **The payment-received note carries no numbers.** They know what they paid — they just paid it.
- **Identity is in the body.** There is no verified business display name, so every message
  opens with "Little Loaf Bakery".

## Failure modes
| Case | Behaviour |
|---|---|
| WhatsApp not installed | Generic Android share sheet with the same text |
| Number not valid E.164 | Blocked at customer entry, not at send — `wa.me` opens a blank chat otherwise |
| Formatting changes in WhatsApp | Content stays complete; only the invoice's alignment is cosmetic |
| Message too long for a URL | Line count capped; a very long order summarises |
| No tracking link when the order goes out | No message is offered. The link is what the message is *for* |
| Link added after it already went out | Offerable from order detail until Delivered |
| Customer asks not to be messaged | Copy-text instead of opening WhatsApp |
| UPI id and phone both unset | Payment lines omitted; the message still reads |

## Non-goals
No inbound. No templates, no approval, no BSP, no per-message cost. No delivery receipts —
they are not obtainable this way, and pretending otherwise would be a lie in the UI.
