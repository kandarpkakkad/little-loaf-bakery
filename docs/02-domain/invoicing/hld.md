# Invoicing — HLD


Built — `lib/domain/invoicing/repository.dart`, seven tests. Issued
automatically when the **last live item** of an order is delivered, because the
bill covers the order rather than the handover.

**Still not built:** the GST columns (`gstin`, `hsn_code`, `tax_rate`, `cgst`,
`sgst`, `igst`, `place_of_supply`) remain unwritten behind `gst_enabled`, and
there is no separate invoice screen — the bill is rendered as a WhatsApp
message from order detail, which is what D13 asked for.

## Purpose
Produce a bill of supply that is numbered, immutable and readable in a WhatsApp message.

## Responsibilities
- Issue the invoice at Delivered, and freeze its totals.
- Per-device invoice numbering.
- Render the message, including every variant.
- Void, never delete.

## Owns
`invoices`.

## Depends on
orders (the source of truth for lines and totals), payments (what has been paid), config
(business profile, UPI details).

## Key decisions
- **It is a WhatsApp message, not a PDF** (D11). No PDF pipeline, no file storage, no share
  sheet, no contact picker.
- **Issued at Delivered**, when goods have been supplied — the right moment for a bill of
  supply — and **sent only on request**, because the delivery message already says everything
  a customer normally wants.
- **Totals freeze on issue.** The document never quietly changes what it says.
- **Numbers are per device**, consecutive within that device, with a hash (D8).
- **Voided, never deleted.** Numbers are never reused.
- **No logo.** The bakery name in bold does that work.

## The monospace constraint
WhatsApp renders triple-backtick text in a fixed-width font, which is what makes the amounts
line up — but it **wraps rather than scrolls**, and a wrapped line destroys the alignment.
Hence: every line ≤ 26 characters, amounts right-aligned to column 26, and a product name
always on its own line where it can wrap harmlessly.

## Failure modes
| Case | Behaviour |
|---|---|
| Order edited after issue | The invoice keeps its frozen totals; the discrepancy is visible on order detail |
| Order cancelled after issue | Invoice voided, number retained |
| Two devices reach Delivered for the same order | LWW on status; the first issue wins. `invoices.order_id` is unique, so the second is a no-op |
| Formatting stops rendering monospaced | Content stays complete, only alignment is lost |

## Non-goals
No PDF, no printing, no email, no tax computation until GST (v2). No credit notes — a
cancellation with a refund is recorded on the order, not as a second document.
