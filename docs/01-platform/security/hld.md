# Security & privacy — HLD

## Purpose
Protect the bakery's data with the tools available to an app that has no server, and be honest
about what that cannot cover.

## Threat model
| Threat | In scope | Response |
|---|---|---|
| Phone lost or stolen | Yes | App lock, encryption at rest, remote account removal |
| Someone reads the Drive folder | Yes | It is a private folder in the bakery's own account |
| A curious app on the same phone | Yes | App-private storage, `drive.file` scope |
| One owner acting against the other | **No** | Both are owners. There is no permission model, by design |
| Google itself | **No** | Accepted — the data lives in their account |
| Network interception | Yes | TLS, by the Drive SDK |

## What protects what
| | |
|---|---|
| **The database** | SQLCipher at rest, key in Android Keystore, never leaves the device |
| **The snapshot** | The Google account. It is written **decrypted**, because it must restore onto a different phone with a different key |
| **The Drive folder** | Account credentials. Sharing is never enabled on anything |
| **The app** | Optional PIN or biometric on open, **off by default** |
| **Nothing** | The fact that every device holds every record. That is the architecture (D1) |

## Google auth
- Google Sign-In, scope **`drive.file` only** — the app can see only files it created.
  It cannot read the rest of the account's Drive, and the consent screen says so.
- The APK, uploaded by a human through the web, is therefore **invisible to the app** — which
  is why the block screen hands its URL to the browser instead.
- The consent screen must be **published**, not left in Testing, or refresh tokens expire
  after seven days and Drive access dies weekly.

## Privacy — DPDP Act 2023
- Collected for order fulfilment: name, phone, delivery address, optional map pin, order history.
- Stays inside the bakery's own Google account. Nothing is sent anywhere else. No analytics.
- **A map pin is a home to the metre** — more sensitive than an address. Pasted, never sensed;
  deleted with the order.
- **The app never requests location permission** (D21).
- Retention: three years after a customer's last order, then anonymised.
- Deletion on request: tombstone the customer and their orders; the tombstone replicates.

## Failure modes
| Failure | Behaviour |
|---|---|
| Phone lost | Remove the account remotely. **Treat the local copy as exposed until wiped** — the device is the credential |
| Keystore key lost | Database unreadable → restore from Drive |
| Auth revoked | Local work continues; stale-sync banner after 24h |
| Consent screen left in Testing | Weekly re-auth. Called out in Appendix D of the PRD |

## Non-goals
No roles. No audit of *who* beyond `device_id`. No MDM. No secret in the APK — there is none
to hide, because Android OAuth clients have no client secret.
