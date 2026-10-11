---
name: File revision contracts
description: Intentional current-flag enforcement boundary and historical file-reference semantics
---

At-most-one current file/resource revision is intentionally a future
application-level contract, not a database guarantee for these modules.

**Why:** The user explicitly requested the application-level fallback when
current-version uniqueness cannot be cleanly represented by the existing
Prisma configuration. Multiple current rows are possible; this is not evidence
that a partial index was accidentally omitted.

**How to apply:** Future revision writers must serialize per project/series (or
per standalone series, not all NULL-project files as one scope) and
atomically clear old current flags while recording the replacement. Soft-delete
writers must also clear affected business references in the same transaction;
the database does not coordinate their flags automatically.

Physical file and business resource revisions are independent. Historical
business references must resolve their exact physical revision, not silently
resolve the newest physical file in the series.

**Why:** One physical object may have several business references, and changing
business classification does not always require another upload. Resolving an
old reference to newer bytes would undermine historical accuracy.

**How to apply:** Retain old physical rows/objects and pinned references. Create
a new object/key for physical revisions. Explicitly reuse server-managed series
identity for a revision; fresh default series IDs represent new assets, not the
next version of an existing asset.
