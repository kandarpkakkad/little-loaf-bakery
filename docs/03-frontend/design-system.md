# Design system

The visual language. Every colour derives from the logo's two; every size comes off one scale.
If something here is not enough to build a screen, that is a gap in this document, not a
licence to invent.

---

## 1. Colour

Sampled from the logo: **slate `hue 202° / 29% / 44%`** and **cream `hue 45° / 70% / 91%`**.
Everything else is those two hues at other lightnesses. The semantic trio is pitched at the
slate's own saturation and lightness so it belongs to the same set rather than looking
bolted on.

### Light
| Token | Value | Use |
|---|---|---|
| `paper` | `#FBF8EF` | Page ground |
| `surface` | `#FFFDF7` | Cards, sheets |
| `surface-2` | `#F8F0D8` | **The logo cream.** Quiet fills, nav bar, chips |
| `ink` | `#16242B` | Body text |
| `ink-2` | `#3A505B` | Secondary |
| `ink-3` | `#566A75` | Tertiary, captions |
| `rule` | `#E6DFC9` | Borders |
| `rule-soft` | `#F4F0E0` | Dividers inside cards |
| `brand` | `#507991` | **The logo slate, exact.** App bar only |
| `accent` | `#3B6C8A` | Same hue, deeper — links, small text, icons |
| `accent-2` | `#2B5268` | Pressed, emphasis on tint |
| `accent-soft` | `#E2EEF4` | Selected chips, info tint |
| `good` / `good-soft` | `#2D6A4F` / `#DBEEE4` | Semantic only |
| `warn` / `warn-soft` | `#7D5613` / `#F5E6C8` | |
| `bad` / `bad-soft` | `#98392D` / `#F6DED9` | |

### Dark
| Token | Value |
|---|---|
| `paper` `surface` `surface-2` | `#11181C` `#1B2429` `#28333A` |
| `ink` `ink-2` `ink-3` | `#F3EEE1` `#AEBAC1` `#93A2AB` |
| `rule` `rule-soft` | `#38444B` `#2A3339` |
| `brand` `accent` `accent-2` `accent-soft` | `#2B4553` `#9CC5DC` `#B8D6E8` `#22343E` |
| `good` `warn` `bad` | `#7FC5A5` `#E2BA74` `#E4958B` |
| `good-soft` `warn-soft` `bad-soft` | `#1F3129` `#342C1D` `#382320` |

### Rules
- **Every pair clears WCAG AA (4.5:1) on every ground it sits on** — paper, surface *and*
  cream — in both themes, and on its own soft tint. Checked by
  `test/ui/contrast_test.dart`, which is what makes "checked" true rather than
  a claim: it caught `accent` at 4.41 on `accent-soft` the moment the palette moved.
- **Headroom is spent on chroma.** The first palette sat at 4.57 worst-case, which
  capped how saturated anything could be and left the semantic trio muddy. Going a
  step darker buys margin *and* colour: the worst pair now clears 4.9 and every
  semantic hue gained roughly a point of contrast to spend.
- **`brand` is the logo colour and appears only on the app bar.** `accent` is the same hue,
  3% darker, for anything read as text.
- **Semantic colour is never decorative.** `good`/`warn`/`bad` mean a state, never a category.
- **Colour is never the only signal.** Every state that uses colour also uses position, an
  icon or a word.
- **The logo never appears on anything the customer receives.**

---

## 2. Type

No webfonts. Platform faces, chosen so weight and rhythm survive the fallback.

| Role | Stack | Use |
|---|---|---|
| `sans` | Roboto / system | Everything in the app |
| `mono` | Roboto Mono / monospace | Amounts in columns, invoice preview, ids |

| Token | Size | Weight | Line | Use |
|---|---|---|---|---|
| `display` | 28 | 600 | 1.15 | Screen title on a scroll-away header |
| `title` | 20 | 650 | 1.25 | App bar, sheet titles |
| `heading` | 16 | 650 | 1.3 | Section heads, card titles |
| `body` | 15 | 400 | 1.45 | Default |
| `body-strong` | 15 | 600 | 1.45 | Names, totals |
| `label` | 13 | 500 | 1.35 | Field labels, buttons |
| `caption` | 12 | 400 | 1.35 | `ink-3` secondary lines |
| `micro` | 11 | 700 | 1.2 | Uppercase section markers, +0.08em tracking |
| `num` | — | — | — | **`tabular-nums` on every number that sits in a column** |

**Rules**
- Never below 11. This is used in a hot kitchen with flour on hands.
- Money always `tabular-nums`, so columns line up while digits change.
- One size per role. There is no 14 and no 17.

---

## 3. Space & shape

```
space:   4  8  12  16  24  32  48        (a 4pt grid; nothing off it)
radius:  sm 6   md 10   lg 14   pill 999
stroke:  hairline 1   emphasis 2
```

| | |
|---|---|
| Screen padding | `16` |
| Card padding | `12` inside, `12` between |
| Row height, tappable | **≥ 48** — never smaller, whatever the design wants |
| Sheet corner | `lg` top only |
| Elevation | Borders, not shadows. One soft shadow reserved for sheets |

---

## 4. Primitives

| Primitive | Notes |
|---|---|
| `Text` | Role from §2. Never a raw size |
| `Money` | Right-aligned, `tabular-nums`. **Renders nothing when zero** (D10) |
| `Field` | Label above, value below, 48 tall. `*` suffix on the label when required |
| `NumField` | Numeric keypad, right-aligned, selects-all on focus |
| `Chip` | Filter, tag, or suggestion. Filled when selected |
| `Seg` | 2–5 exclusive options. Filled selection. **Switching a unit clears the value** |
| `Button` | `primary` filled `brand` · `ghost` outlined `accent` · `text` |
| `Card` | `surface`, `rule` border, radius `md` |
| `Alert` | `good` / `warn` / `bad` tint, icon, optional action |
| `Bar` | Fill + notch. See §6 |
| `Sheet` | Bottom sheet, drag handle, one primary action |
| `Empty` | Icon, one line of what goes here, and the action that fills it |

**Required fields carry `*`. Optional fields say nothing** — the asterisk marks the exception,
and on these forms the exception is the short list.

---

## 5. Money rendering

```
₹1,890          Indian digit grouping, no decimals when whole
₹1,890.50       two decimals only when non-zero paise
−₹100           discount, minus sign not brackets
(nothing)       when zero — the row does not exist
```
Inside the invoice's monospace block: **no ₹ symbol**, right-aligned to column 26.

---

## 6. The stock bar

```
level 2.5, reference 8, threshold 6

███░░░░░░░░░┊░░░░░░░░░░░
            ▲ notch = threshold ÷ scale
scale = max(reference, threshold)
```

| | |
|---|---|
| Height | 8, radius `pill` |
| Track | `rule-soft` |
| Fill | `bad` below threshold · `warn` within 15% above · `good` beyond |
| Notch | 2px, `ink` at 60%, **drawn over the fill as well as the track** |
| Below it | Nothing. Name and numbers sit above |

---

## 7. State presentation

| State | How it looks |
|---|---|
| Empty | `Empty` primitive. Never a blank list |
| Loading | Skeleton rows. Local reads are instant, so this appears only during restore |
| Offline | Thin strip under the app bar with a pending count. Nothing is blocked |
| Sync stale | Persistent `warn` strip after 24h, with Retry |
| Conflict | `warn` alert linking to the conflict log, both values shown |
| Not shared | `bad` chip on the order |
| ⚑ Requirements changed | `warn` banner with **Acknowledge**, on the card and on order detail |
| Blocked (version) | Full screen, no shell, no way past. Download + Restore |

---

## 8. Motion

| | |
|---|---|
| Sheets | 200ms ease-out up, 150ms down |
| Tab change | Cross-fade 120ms. **No horizontal slide** — tabs are places, not pages |
| List insert | 150ms fade. No spring |
| Everything else | None |

Honour `prefers-reduced-motion`: durations to zero, nothing else changes.

---

## 9. Writing

- **Say what happens.** "Confirm & share on WhatsApp", not "Submit".
- **Never claim what cannot be known.** "Shared 7:12 pm", never "Delivered ✓✓".
- **Numbers over adjectives.** "still below your 8 kg threshold", not "stock is low".
- **Errors say what to do.** "Add at least one item" beats "Invalid order".
- Indian English, no exclamation marks except in customer-facing messages.
