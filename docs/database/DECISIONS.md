# Database decisions

## Employee foundation scope

- **Decision:** The first schema migration contains only `users`, `departments`,
  and `employee_profiles`. Roles and other ERP modules remain out of scope.
- **Reason:** The database is implemented incrementally, one approved module
  at a time.
- **Department codes:** Use a PostgreSQL-backed Prisma enum for the nine
  controlled department codes and seed one department row per code.
- **Migration:** `20261010095510_employee_foundation` is the first migration.
  The pre-migration read-only check found no existing tables; no baseline or
  database reset was needed.

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
- **Integrity:** A database check rejects self-management. Broader reporting
  cycle validation belongs in the future employee-writing application flow.
  Department deletion is restricted, manager deletion clears reporting links,
  and user deletion cascades to its dependent profile.

## Types, nullability, and indexing

- **Decision:** Use native UUIDs for IDs and all foreign keys, and
  `TIMESTAMPTZ(6)` for all timestamp fields. Joining date is required; phone,
  manager, last-login timestamp, soft-delete timestamp, and supplemental
  profile fields are nullable.
- **Reason:** An employee must have a known department and joining date;
  supplemental or not-yet-known information must not require placeholder data.
- **Indexes:** Unique identifiers are indexed by their unique constraints.
  Non-unique indexes support department/status lists, direct reports, joining
  date queries, and account availability/soft-delete filtering.
- **Email:** Database uniqueness is case-sensitive. Normalize and validate
  email in the account-writing API when that separate step is implemented.

## No authentication or audit workflows in this step

- **Decision:** Store a required password hash, but do not add password
  generation, login endpoints, roles, status history, or audit tables.
- **Reason:** Only the three employee foundation tables were requested.
  Important status-change history and business auditing must be designed
  before those mutation workflows are introduced in a later approved step.

## Single-organization boundary

- **Decision:** The ERP is for InterSmart Technologies only; there is no
  multi-tenant organization model or tenant/organization foreign key.
- **Reason:** This is an explicit product constraint.

## Preserve the existing Drizzle scaffold

- **Decision:** Keep the pre-existing `lib/db/` Drizzle boilerplate intact while
  establishing the requested Prisma package at `packages/database/`.
- **Reason:** Avoid deleting or converting existing project work in an
  employee-database-only step. The two locations must not be treated as competing
  sources of truth; new ERP schema changes belong in the Prisma package.
