# Database decisions

## Employee foundation scope

- **Decision:** The first schema migration contains only `users`, `departments`,
  and `employee_profiles`. Roles and other ERP modules remain out of scope.
- **Reason:** The database is implemented incrementally, one approved module
  at a time.
- **Department codes:** Use a PostgreSQL-backed Prisma enum for the nine
  controlled department codes and seed one department row per code.

## User lifecycle and status

- **Decision:** User status is `ACTIVE`, `INACTIVE`, or `SUSPENDED`, defaulting
  to `ACTIVE`. `deleted_at` is nullable and supports soft deletion.
- **Reason:** These statuses cover account availability without introducing
  employment or approval workflows that were not requested. Unique employee
  codes and email addresses are retained after soft deletion.

## Employee profile boundary

- **Decision:** Store optional job title, work location, and short biography in
  `employee_profiles`; keep credentials and login state in `users`.
- **Reason:** This keeps authentication data separate from supplemental
  employee information while avoiding speculative sensitive personal fields.

## Employee relationships

- **Decision:** Each user belongs to one department. A nullable self-referencing
  manager relation supports reporting lines. Each user may have one profile.
- **Reason:** Department assignment is required for the employee foundation;
  manager and profile records may be added later.

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
