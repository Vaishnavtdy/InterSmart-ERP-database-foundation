---
name: Audit and security evidence write contracts
description: Future audit transaction boundaries, failed-attempt durability and session/resolution coordination
---

Coordinate a successful business change, its authoritative domain history and
selective audit evidence in the same authorized transaction. Do not replace
workflow history with generic audit context or indiscriminately copy every
history row into all event streams.

**Why:** The user requires the cross-module audit layer to complement, not
replace or duplicate, domain lifecycle history. Partial writes can make either
workflow state or the evidence of who changed it misleading.

**How to apply:** Future writers use the actual actor and trusted request
correlation. Failed/denied authentication or access-attempt evidence must survive
the rejected operation; do not put its only event into a transaction that will
be rolled back. Define safe, bounded evidence and its commit/error policy
explicitly before implementing interceptors.

A session-history reference is not the actual authentication session, and a
recorded revocation/lockout/MFA event does not enforce authentication policy.

**Why:** The requested database-only step explicitly excludes auth logic and
credential storage. Conflating observation with enforcement would give future
callers false security guarantees.

**How to apply:** Future auth writers coordinate provider/session enforcement
with attributed history and audit evidence without copying authenticating
credentials. Serialize revocation and investigation-resolution updates; use the
authorized revoker/resolver, not the session owner or involved account by default.
Define privacy/retention and tamper-resistance permissions separately rather than
assuming an audit-management permission means unrestricted evidence deletion.
