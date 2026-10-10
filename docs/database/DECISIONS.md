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

## Customer boundary and preserved models

- **Migration:** `20261010100740_customers`, applied transactionally with
  additive tables, enums, indexes, and foreign keys only.
- **Decision:** Add only `Customer` and `CustomerContact`. External customers
  and contacts have no authentication or role/permission relationships.
- **Reason:** Employee users access the internal ERP; external clients are
  business records managed by employees, not ERP accounts.
- **Existing model change:** `User.assignedCustomers` is only a Prisma
  back-reference required for the new relationship; no existing user columns
  or constraints are changed.
- **Repository observation:** The supplied brief stated that Step 2 was
  implemented, but its roles/permissions models and migration were absent
  from the inspected schema, repository, and matching database. Step 3 does
  not depend on those tables, and they were not recreated.

## Customer and contact lifecycle

- **Decision:** Customer status is `ACTIVE`, `INACTIVE`, `PROSPECT`, or
  `BLOCKED`, defaulting to `PROSPECT`. Contact status is `ACTIVE` or
  `INACTIVE`, defaulting to `ACTIVE`.
- **Reason:** Newly captured companies may not yet be active customers;
  individual contacts only need availability status at this stage.
- **Deletion:** Customers support soft deletion. Hard deletion cascades to
  contacts, while deleting an assigned employee clears the nullable assignment.
  Soft deletion does not automatically remove or change contacts.
- **Assignment:** The FK ensures that a salesperson is an existing employee.
  No department restriction or authentication workflow is added.

## At most one primary contact

- **Decision:** Use a PostgreSQL partial unique index on contact `customer_id`
  where `is_primary = true`, maintained in migration SQL.
- **Reason:** An unconditional unique FK would incorrectly limit a customer
  to one contact. A partial unique index allows multiple non-primary contacts
  and prevents competing primary contacts atomically, including concurrent
  writes.
- **Scope:** Zero primary contacts is valid. Inactive primary contacts still
  reserve the slot; switching primary contact must demote the old contact
  before promoting another, within one transaction.
- **Migration review:** Prisma does not represent this index in the schema
  without additional preview configuration. Preserve the SQL-only index in
  future migrations and verify it directly in PostgreSQL.

## Customer data and query indexes

- **Decision:** Use only requested scalar fields, UUID foreign keys, and
  timezone-aware timestamps. No Decimal, JSONB, tenancy keys, or new seed
  records are needed.
- **Reason:** There are no monetary calculations or unstructured payloads in
  this module. Company code is unique; contacts may legitimately share email
  addresses or phone numbers, so those fields are indexed but not unique.
- **Indexes:** Company name supports exact lookups and ordering, not
  arbitrary substring search. `(status, deleted_at)` supports lifecycle
  filtering; salesperson and contact-customer indexes support relationship
  queries. Email and phone indexes support exact contact lookups.
