# Customers — HLD

## Purpose
Hold who the order is for, dedupe them reliably, and carry the one thing that must never be
re-typed: an allergy.

## Responsibilities
- The customer record and phone-number dedupe.
- Order history, lifetime value, outstanding balance.
- The allergy note that pulls forward onto every order.
- The last delivery address, as a reference — not a default.

## Owns
`customers`.

## Depends on
storage, sync. Orders reads customers.

## Key decisions
- **The phone number in E.164 is the dedupe key.** Typing an existing number pulls up the
  customer rather than creating a second one.
- **No address book** (D20). Cakes go somewhere different almost every time. The address
  belongs to the order; the customer page shows the last one as a reference.
- **The allergy note pulls forward automatically** onto every order that customer places, so
  it is never re-typed and never forgotten.
- **The customer is not a user.** They never log in. Their entire experience is two or three
  WhatsApp messages.

## Failure modes
| Case | Behaviour |
|---|---|
| Two devices create the same person offline | Two rows, same phone. The partial unique index rejects the second on merge; the domain folds orders onto the survivor and tombstones the other |
| Number entered without a country code | Normalised to E.164 on entry, defaulting to +91. Rejected if it cannot be normalised — `wa.me` opens a blank chat otherwise |
| Number changes | Edit in place. Old orders keep pointing at the same customer row |
| Deletion requested | Tombstone the customer and their orders; scrub the name on invoices, keep the money |

## Non-goals
No segments, no loyalty, no marketing. No customer login, ever.
