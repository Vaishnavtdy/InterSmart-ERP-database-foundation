# Database decisions

## Foundation remains model-free

- **Decision:** Set up Prisma and PostgreSQL without adding business or
  authentication models in this step.
- **Reason:** The database is being built incrementally, and no first domain
  module was approved. Adding speculative tables would exceed the selected
  foundation scope.
- **Migration:** No initial migration is created or applied until an approved
  model produces a meaningful schema change.

## Single-organization boundary

- **Decision:** The ERP is for InterSmart Technologies only; there is no
  multi-tenant organization model or tenant/organization foreign key.
- **Reason:** This is an explicit product constraint.

## Preserve the existing Drizzle scaffold

- **Decision:** Keep the pre-existing `lib/db/` Drizzle boilerplate intact while
  establishing the requested Prisma package at `packages/database/`.
- **Reason:** Avoid deleting or converting existing project work in a
  foundation-only step. The two locations must not be treated as competing
  sources of truth; new ERP schema changes belong in the Prisma package.
