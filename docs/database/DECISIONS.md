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

## Lead module scope and preservation

- **Migration:** `20261010101229_leads` applies new tables, enums, indexes,
  constraints, and foreign keys atomically. No existing tables are dropped
  or changed.
- **Decision:** Add only `Lead`, `LeadActivity`, their four enums, indexes,
  and foreign keys. User/customer changes are inverse Prisma relation fields
  only; existing table columns, constraints, and migrations are preserved.
- **Reason:** Leads precede confirmed customer/project workflows. This step
  must not create proposal/project entities or any application-layer code.
- **Existing modules:** The earlier Step 2 roles/permissions discrepancy
  remains unchanged. This module uses existing `User` and `Customer` records
  without recreating access-control entities.

## Lead capture, sources, and workflow

- **Decision:** Customer linkage is nullable. Assignment, source, and contact
  name are required. Lead status defaults to `NEW`, temperature to `COLD`.
  Source uses the nine requested controlled values with no default.
- **Reason:** A lead may exist before a customer and should not require a
  fabricated customer record. Explicit source selection avoids incorrectly
  attributing acquisition channels.
- **Contact snapshot:** Requested contact/company fields represent information
  captured for this opportunity, particularly before customer creation. Do
  not automatically duplicate employee information or copy the entire customer
  record into the lead.
- **Source configuration:** Use an enum now. If administrators later need to
  manage channels without migrations, propose a separate configuration design
  then, rather than adding a speculative source table.
- **Workflow:** All requested stages are supported, including `LOST`. Stage
  transitions, conversion to customers/projects, and audited status mutation
  are not implemented by this database-only step. No additional history model
  is introduced beyond the requested activity table.

## Lead value, timestamps, and historical retention

- **Decision:** Estimated value is nullable `Decimal(18,2)` with a SQL
  nonnegative check. No default zero, currency field, calculated totals, or
  conversion percentages are stored.
- **Reason:** Unknown value is different from zero. Currency was not provided;
  reporting must establish common currency semantics before aggregating values.
- **Timestamps:** All dates use the established timezone-aware convention.
  Leads have creation/update timestamps and an optional soft-delete marker;
  activities contain only the requested creation timestamp and optional
  scheduling/completion/follow-up timestamps, with no soft-delete field.
- **Deletion:** Soft deletion leaves history untouched. Lead activity FKs
  restrict hard deletion of leads and their authors. Required salesperson
  assignment also restricts user hard deletion; customer hard deletion clears
  optional lead linkage. User/customer soft deletion does not change FKs.
- **Reason:** Sales history and author attribution must not disappear through
  cascading deletion. Employees and leads should normally be deactivated or
  soft-deleted, not physically removed.

## Lead query indexes

- **Decision:** Index unique lead code; customer ID; assigned employee/status/
  deletion state; status/deletion state; temperature/deletion state; expected
  close date; created time. Index activities by lead/created time,
  author/next-follow-up time, activity type, scheduled time, and next-follow-up
  time.
- **Reason:** These cover personal lead lists, hot/follow-up/ready-to-close
  filters, close-date horizons, chronological history, and upcoming follow-ups.
  Composite indexes retain FK lookup support through their leading columns.
  Global and personal follow-up queries need different leading index columns.

## Proposal scope and customer boundary

- **Migration:** `20261010103125_proposals`, with transactional additive
  changes only. Existing migrations are not edited or removed.
- **Decision:** Add only `Proposal`, `ProposalVersion`, `ProposalItem`, and
  their three enums. Existing User/Customer/Lead changes are inverse relation
  fields only. There is no project link, customer login, tenancy key, JSONB
  snapshot, AWS dependency, or separate proposal audit table.
- **Reason:** Versioned commercial proposals are the requested independent
  database step; projects, accounts/payment, and global auditing come later.
- **Customer snapshot decision:** "Proposal references the customer entity.
  Historical commercial/customer snapshots can be introduced later if
  legal/business requirements require immutable proposal documents."
- **Relationships:** Customer and creator are required; lead is optional
  and not unique. Versions each reference their proposal and creator;
  items reference a specific version, never the proposal header.

## Current version and safe circular relations

- **Decision:** Keep nullable `currentVersionId` and use a composite FK from
  proposal `(id, currentVersionId)` to version `(proposalId, id)`. The latter
  pair has an explicit unique constraint in addition to version ID's PK.
- **Reason:** A simple FK to version ID would permit selecting a different
  proposal's version. A single nullable pointer gives zero or one current
  version, without duplicate flags or version numbers on the header.
- **Prisma inverse:** `currentFor` is an array to avoid a redundant source
  composite-unique index. The ownership FK plus the proposal PK still ensures
  that a version can be current only for its one owning proposal.
- **Creation:** In one transaction, create the proposal with no current
  version, create its version/items, then update the pointer. No deferred
  constraint or fragile insertion order is required.
- **FK updates:** The current-version FK uses `NoAction` on update rather than
  cascading changes through the circular relationship. UUID identity and
  version ownership should not be changed by business workflows.

## Versioning and historical retention

- **Decision:** `(proposalId, versionNumber)` is unique; numbers are positive,
  explicitly supplied, and need not be gap-free. Both statuses default to
  `DRAFT`. Only proposals and items have requested update timestamps;
  only proposal headers have soft-delete markers.
- **Reason:** Each revision is a separate commercial snapshot. Historical
  revisions and items must not be replaced when a new revision is created.
- **Future service contract:** Create a new version for commercial revisions,
  mark the replaced version `SUPERSEDED`, and update the header pointer
  atomically. Issued/historical pricing and item content must not be edited.
  Concurrent version creation must handle the unique-number constraint.
- **Enforcement boundary:** There are no write services or database workflow
  triggers in this step. Commercial immutability and status transition rules
  are future service responsibilities, not guarantees of the current schema.
  A current pointer is authoritative; no unique `ACTIVE` status constraint
  is added to incorrectly couple business status and current selection.
- **Deletion:** Customer/creator references restrict hard deletion. Proposal
  ownership and item ownership also restrict hard deletion rather than cascade
  away history. Lead hard deletion clears nullable linkage; proposal soft
  deletion leaves all revisions and items intact.

## Decimal pricing, discounts, and validity

- **Decision:** Use `Decimal(18,2)` for money/discount value and `Decimal(18,4)`
  for quantity, with no floating-point columns. Quantity defaults to one and
  must be positive. Money must be nonnegative. Numeric checks also reject
  PostgreSQL `NaN`, which ordinary nonnegative comparisons would accept.
  All version totals are required
  without defaults, making the writer supply explicit commercial values.
- **Reason:** Decimal preserves money exactly; fractional service quantities
  need more scale than money. Unknown pricing must not be silently finalized
  as zero. Currency and rounding policy must be established before financial
  integrations; no currency field is invented in this step.
- **Discounts:** Both type and value must be null or both populated. Percentage
  value is between 0 and 100, fixed value nonnegative. Backend calculations
  must enforce discounts against the applicable base, reconcile item/version
  totals, and apply agreed tax/rounding rules using Decimal, not JS Number.
- **Snapshots:** Store finalized item amounts and version totals; never
  duplicate `totalAmount` on the proposal header.
- **Validity:** The requested header `validUntil` supports overall tracking;
  version `validUntil` preserves revision-specific validity. The future
  service must define how it maintains header validity when current changes.
  All timestamps remain `TIMESTAMPTZ(6)`.

## Proposal-step conversion boundary (Step 5)

- **Decision:** No project relationship was introduced in Step 5.
- **Reason:** Conversion must be designed with the future Project module.
  It should reference the exact accepted proposal version, not merely the
  mutable current-version pointer, and be idempotent to avoid duplicate
  projects. Legal/customer snapshots, accepted-value currency semantics,
  status auditing, and conversion authorization must be resolved there.

## Project as the central business entity

- **Migration:** `20261010104233_project_core` adds exactly six project-core
  models and eight enums. Existing modules receive inverse Prisma relations
  only; no existing SQL columns, constraints, or migrations are rewritten.
- **Decision:** Project ties together the existing customer, optional proposal,
  and employee participants. Future Sales, Accounts, PMO, coordinator, UI, UX,
  development, QA, budget, payments, tasks, meetings, customer feedback, files,
  change requests, and notifications will connect through Project.
- **Reason:** The user identified Project as the core InterSmart business
  entity, not a departmental work table.
- **Normalized boundaries:** There are no resource-specific designer/developer/
  QA employee fields, budget/progress/task counts, hold/termination reason text,
  or duplicated customer details on Project. Team participation belongs in
  ProjectTeam; reasons belong in status history. Calculated metrics will come
  from later task, budget-transaction, and departmental-work modules.

## Project lifecycle, reasons, and history

- **Decision:** Use exactly the five requested lifecycle statuses, default
  `PLANNED`. Store the 15 reason values separately in nullable history `reason`.
  The most recent recorded event supplies the current reason; a resume event
  with null reason clears an old condition.
- **Reason:** Payment pending, exceeded budget/dates, or missing content are
  explanations/conditions, not lifecycle stages. The requested history model
  already holds reason without introducing another source of truth.
- **Append-only enforcement:** SQL row triggers reject UPDATE/DELETE of history;
  a statement trigger rejects TRUNCATE. Retention FKs also prevent cascading
  parent/author deletion. Corrections require a new historical event.
- **Service boundary:** No workflow logic or automatic status-history insertion
  is implemented. Future writers must atomically change status and record
  from/to status, reason, actor, and timestamp, including creation from null.
  Tied timestamps need deterministic ordering and a defined event-ordering
  policy before relying on history as a current-condition query.
- **Scope:** Same-status events are allowed for reason changes. SQL does not
  constrain permitted transition paths or reason/status combinations.

## Extensible project categories, quality, and platform

- **Decision:** Use self-referencing ProjectCategory records, globally unique
  stable codes, and a nullable parent. Seed four roots and 16 children with
  root-prefixed child codes, not a large hierarchy enum.
- **Reason:** PHP/Node/AI occur under several categories, and business categories
  may expand independently of schema deployments.
- **Seed behavior:** Transactional create-only upserts preserve IDs and
  administrator-edited labels, descriptions, and activation flags. Reserved
  codes under a different parent fail rather than silently moving records.
  Extra administrator-created categories are not deleted by the seed.
- **Hierarchy guard:** A SQL check prevents self-parenting; FKs prevent
  nonexistent parents and restrict removing used parents/categories. Longer
  cycles, active-category validation, and whether only leaf categories may
  receive projects require future category-writing/selection service checks.
- **Quality:** Optional `STANDARD`, `PREMIUM`, `HIGH` uses the suggested fixed
  levels only; do not invent additional business tiers. Revisit with the
  business if quality must become configurable.
- **Platform:** Optional coarse `WEB`, `MOBILE`, `CMS`, `ECOMMERCE`, `CUSTOM_WEB`
  uses no technology/subcategory hierarchy. Deriving this classification from
  category roots may be preferable once mapping rules are agreed; no mapping
  or synchronization logic is imposed here.

## Team assignments and responsible employees

- **Decision:** Required salesperson plus optional manager/coordinator identify
  accountable employees. All other participation is represented by ProjectTeam.
  The 11 project roles are operational roles, not global authorization roles.
- **Reason:** Adding UI/UX/developer/QA employee columns would prevent flexible
  multi-person staffing and erase assignment history.
- **Active uniqueness:** A migration-only unique index on `(projectId, userId)`
  where `releasedAt IS NULL` prevents duplicate active membership across roles.
  Released history remains, allowing an employee to return later. If the
  business needs simultaneous multiple roles per person, explicitly review
  that uniqueness policy before relaxing it.
- **Allocation:** Nullable `Decimal(5,2)`, 0–100, supports unknown or fractional
  allocation without floating point. Employee-wide allocation sums are not
  enforced by individual rows; future allocation services must define them.
- **Dates/department:** Assignment defaults to now; release cannot precede it.
  Department is the assignment's historical department context; a later
  employee transfer does not rewrite old roster rows.
- **Consistency:** Manager/coordinator/salesperson pointers do not automatically
  create or synchronize team rows. Future services must define that policy.

## Internal comments, actions, dates, and retention

- **Decision:** Comments are internal employee-authored text. ProjectAction is
  one shared follow-up entity with the seven requested types, required employee
  assignee/creator, and four statuses defaulting to `PENDING`.
- **Reason:** Neither departmental action tables nor customer-facing comments
  are requested; ProjectAction is not a replacement for the later Tasks module.
- **Dates:** Native timezone-aware timestamps support planned/actual completion
  and action due/completed times. Known end dates cannot precede a known start.
  Page count is nullable and nonnegative. Priority defaults to `MEDIUM`.
- **Retention:** Project soft deletion leaves teams, history, comments, and
  actions intact. Mandatory customer, salesperson, category, proposal origin,
  membership/author/actor links restrict hard deletion. Nullable manager and
  coordinator links clear on employee deletion only when other references
  do not already restrict deletion.
- **Boundary:** Action completion timestamps and valid status transitions are
  future service responsibilities; no state machine is implemented here.

## Project origin and pre-conversion review

- **Decision:** Use only nullable `Project.proposalId` and required customer.
  Add no reverse scalar `Proposal.projectId`, no unique proposal ID constraint,
  and no proposal-version FK beyond the user's requested project fields.
- **Reason:** Avoid circular/duplicated origin links and premature restrictions
  on how many projects a proposal may produce. UUID and human-readable code
  remain independent; formatted-code generation is a future service.
- **Review before conversion:** Decide one-versus-many projects per proposal,
  idempotent conversion rules, customer/proposal consistency, accepted-status
  verification, and how the exact accepted commercial version is frozen.
  The present header link alone does not identify that immutable version.
  These are explicit unresolved service/schema decisions, not implemented
  acceptance checks. No Step 7 modules were introduced by Step 6.

## Scope and Business Analysis boundaries (Step 7)

- **Migration:** `20261010105325_project_scope_business_analysis`. Previous
  migration history and existing SQL objects are preserved without resets.
- **Decision:** Add only ProjectScope, ProjectScopeItem, BusinessAnalysis,
  Competitor, ScopeStatus, and ScopeItemType. Project/User modifications are
  inverse Prisma relations only.
- **Reason:** Scope defines WHAT is included/excluded. Business Analysis
  defines WHY and FOR WHOM. Budget, tasks, and departmental execution are
  separate concepts and are not introduced by this step.
- **Analysis:** Unique project ID provides zero or one current document per
  project, with optional narrative fields and separate multiple competitor
  records. No speculative analysis versioning or customer authentication
  is added.

## Scope versioning and current approved selection

- **Decision:** Positive explicit version numbers, unique by project/version,
  with no current-version pointer. A migration-only partial unique index on
  project ID where status is APPROVED permits zero or one approved revision.
- **Reason:** The approved-status query is reliable and indexed without a
  second source of truth. Older revisions remain as separate records.
- **Future writer contract:** Create/populate a new draft, then atomically
  supersede the previous approved revision and approve the new one. Handle
  unique-number conflicts and serialize competing approval attempts. Approval
  transitions and permissions are not implemented as services in this step.

## Direct approval metadata and immutable approved scope

- **Decision:** Approval actor/time are paired nullable fields; APPROVED
  requires both. Optional approver FK uses Restrict rather than clearing
  historical attribution when an employee is physically deleted.
- **Reason:** The requested direct metadata supports traceability without
  building the generic approval engine.
- **Preservation:** Once approvedAt exists, scope identity, version ownership/
  number, title, summary, description, creator, approval actor/time, and
  creation timestamp cannot be edited or removed. Status/update timestamp
  remain mutable so an approved revision may be superseded.
- **Items:** SQL guards block insertion, editing, deletion, or moving items
  out of or into a previously approved scope, regardless of later status.
  Parent-row locks serialize item mutation with approval. Moving draft items
  locks both scope parents in ID order.
- **Reason:** Keeping only old version rows is insufficient if their content
  or item set can subsequently be overwritten. Clearing status or approval
  metadata must not bypass historical snapshot protection.
- **Boundary:** These are preservation guards, not a generic approval engine
  or a workflow state machine. They do not automatically select approvers,
  authorize employees, submit/reject scopes, or supersede another revision.
  Revisit direct approval fields when a generic engine is explicitly approved.

## Scope item values, deletion, and analysis mutability

- **Decision:** Included and excluded deliverables share one item table with
  a boolean flag. Estimated hours are nullable Decimal(10,2), finite and
  nonnegative. Sort order is nonnegative, defaults to zero, and may have ties.
- **Reason:** Scope items define planned boundaries, not execution tasks.
  Totals, included/excluded counts, estimated-hour sums, and progress are
  calculated later rather than stored.
- **Retention:** Project/scope/item/analysis/competitor relationships use
  Restrict. Project soft deletion retains all child records. Approved scopes,
  including superseded ones with approval provenance, cannot be deleted even
  if they have no items. Draft child deletion can be performed explicitly
  in a future authorized editing flow.
- **Analysis updates:** Analysis and competitor content remains editable;
  preserve required creator and optional last-updater links. No aggregate
  history or audit table is added. Future edits must set updatedById, because
  the database cannot infer the acting employee.
- **Dates:** All timestamps use TIMESTAMPTZ(6), with Prisma-maintained
  updatedAt fields following existing conventions.

## File storage boundary (Step 8)

- **Migration:** `20261010112103_project_files_resources`. Additive new tables,
  enum, indexes, foreign keys, and checks; no prior migrations modified.
- **Decision:** Add File, ProjectResource, and ProjectResourceType only.
  Project ownership and both uploader links are required. Existing models
  receive inverse Prisma relations only; no organization/global-file module
  is added to this single-company ERP.
- **Reason:** Files hold physical metadata; project resources hold business
  classification. File binaries will live in self-hosted MinIO, never
  PostgreSQL. No AWS services/SDKs or MinIO integration are introduced.
- **Keys:** Store configurable bucket plus globally unique complete storage
  key. Use projects/{project-id}/{resource-type}/{uuid}-{safe-filename};
  future services generate/sanitize names, validate key byte limits and
  project prefix, and never treat originalName as an unrestricted path.
- **Security:** No public/signed URLs or storage credentials are stored.
  Authorization and controlled access belong to future Next.js/NestJS/MinIO
  services, not this database-only step.

## File and resource version identity

- **Decision:** Add fileSeriesId and resourceSeriesId UUID grouping identifiers,
  defaulting to new UUIDs for new assets. Explicit reuse identifies later
  revisions. They do not reference a separate series table.
- **Reason:** The recommended fields lack a stable identity for multiple
  versioned assets of the same type. A unique project/type/version rule alone
  would prevent legitimate multiple logos or UI files; names and titles can
  change and must not be identity keys.
- **Unique keys:** File project/series/version; resource
  project/type/series/version. Positive versions default to one.
  Resource type is part of resource-series identity. Physical and business
  versions remain independent because multiple business references may reuse
  one physical object.
- **History:** Create a fresh physical row/object/key per physical revision;
  retain old rows/objects with non-current flags. No overwriting, physical
  deletion, or garbage-collection workflow is implemented here.

## Current flags and explicit enforcement limitation

- **Decision:** Use ordinary Prisma-representable uniqueness/indexes for
  version identity and queries. Do not add current-version partial indexes
  or enable preview features/change the toolchain in this step.
- **Reason:** The user explicitly permits application-level enforcement when
  current-version uniqueness cannot be cleanly represented by the project's
  current Prisma configuration. Prior migration-only partial indexes remain
  intact; their existence does not override this step's fallback instruction.
- **Future service contract:** Serialize writers per project/series and
  replace current flags atomically, handling unique-version conflicts.
  Multiple current rows are possible at the database level; this limitation
  is intentional, not silently claimed as enforced.
- **Future option:** With an approved representation/toolchain strategy,
  add a partial unique file index on project/series for live current rows and
  a resource index on project/type/series where current. Audit existing flags
  before doing so. Do not add speculative fallback pointers/third models now.

## File ownership, deletion, and numeric values

- **Decision:** Composite owned-file FK from resource (projectId, fileId) to
  file (projectId, id). The target needs explicit owner/ID uniqueness in
  addition to the file PK, following the existing proposal ownership pattern.
  Owned-file updates use NoAction rather than cascaded reclassification.
- **Reason:** Separate project/file FKs would allow a resource to attach an
  unrelated project's file. Many references to one file are allowed; fileId
  is intentionally not unique.
- **Deletion:** All new relationships use Restrict. File soft deletion retains
  metadata and references; project soft deletion retains the entire module.
  SQL requires a deleted file to be non-current. Resource visibility also
  depends on its referenced file's deletion state. Future soft-delete writers
  clear affected current references transactionally; no cross-table flag
  synchronization or MinIO deletion is implemented.
- **Values:** Nonnegative signed BIGINT sizes support large files without
  floating-point loss. Future JSON serializers must handle bigint explicitly.
  Checksum is a nullable string, indexed but non-unique, allowing legitimate
  repeated content across revisions/resources. Bucket remains a free string.
- **Indexes:** Leading project prefixes cover project-only lookup; explicit
  file/uploader/type/checksum/time indexes support references, attribution,
  category views, integrity lookup, and chronological queries. No duplicate
  index is added solely for a field already covered by a unique index.

## Budget domain and header identity

- **Migration:** `20261010115257_project_budget_transactions`. Previous
  migrations, SQL guards, and stored records are preserved.
- **Decision:** ProjectBudget, BudgetAllocation, BudgetTransaction are separate
  from Project and customer payments. Add only necessary inverse relations to
  Project, Department, and User.
- **Reason:** Internal execution funding is not customer cash collection;
  derived used/remaining/available amounts and percentages are not source
  fields. No payment, approval, or dashboard module is added.
- **Identity:** Unique project ID permits one budget definition across its
  lifecycle. Historical changes live in the transaction ledger rather than
  multiple active headers. Budget-definition versions need explicit review
  if later business requirements require them.

## Monetary conventions and initialization

- **Decision:** Use existing NUMERIC(18,2) money precision throughout; budget
  and allocation definitions are finite/nonnegative, events finite/nonzero.
  Currency is a three-letter uppercase string defaulting to INR. Services
  must validate real currency codes and review precision for currencies
  requiring more than two fractional digits.
- **Signs:** INITIAL_ALLOCATION, INCREASE, REFUND positive; DECREASE, EXPENSE
  negative. ADJUSTMENT, ALLOCATION, REVERSAL support signed directions.
  These are simple row checks, not lifecycle/approval logic.
- **Opening:** totalBudget is configured initial funding. Future initialization
  atomically records exactly one equal INITIAL_ALLOCATION and activates the
  header under a lock. Initialization uniqueness/equality is not DB-enforced.
- **Reason:** Adding the header opening amount to its mirrored initial ledger
  entry would double count funding. Post-initialization balances come from
  ledger aggregation, not overwritten header values or cached balance fields.
- **Zero definitions:** Zero is valid for draft planning. INITIAL_ALLOCATION
  events are positive, so standard funded initialization requires a positive
  opening definition. Review zero-funded activation separately before exposing
  that workflow; the database does not implement activation rules.
- **Allocation:** planned allocatedAmount is not expenditure or available
  funds. ALLOCATION events describe internal distribution and are excluded
  from project-wide funding totals. Future services must define allocation
  adjustment reconciliation, over-allocation checks, and overlap policy.

## Optional allocation ownership and employee context

- **Decision:** Both departmentId and userId are independently nullable.
  Category-only, department-only, employee-only, and combined employee/
  department-context records are valid.
- **Reason:** Allocation is not synonymous with an individual resource.
  Multiple allocation lines per category/target may be legitimate, so no
  arbitrary target/type uniqueness is added.
- **Ownership:** Transaction (projectBudgetId, allocationId) references
  allocation (projectBudgetId, id), using a composite target unique key.
  Null allocation remains budget-wide; a populated allocation must belong
  to that exact budget. Owned-reference updates use NoAction.
- **Retention:** Restrict FKs retain actor/target/department attribution and
  avoid cascading budget/ledger loss. Employee transfers must not silently
  rewrite historical allocation department context. Project soft deletion
  retains financial records.

## Transaction history and unresolved reporting policy

- **Decision:** Ledger rows have creation/transaction timestamps and actor,
  with no updatedAt/deletedAt or balance fields. Future writers must append
  corrections/reversals rather than edit/delete past entries.
- **Reason:** Traceable financial state requires the underlying event history.
  No new triggers or DB permission changes are introduced; append-only behavior
  is an application contract and direct SQL mutations are not blocked.
- **Reference:** Optional string only. It may describe future invoices,
  expenses, requests, or approvals without unsupported polymorphic FKs.
- **Reversal:** Future services must resolve and validate the original
  budget/event and its funding-versus-consumption effect. Sign alone is not
  sufficient for reporting classification. No reversal-target FK or idempotency
  mechanism is invented in this foundation step.
- **Dates/indexes:** TIMESTAMPTZ(6) everywhere; effectiveFrom/transactionDate
  default now, effectiveUntil nullable and ordered. Indexes cover owner/date,
  type, employee/department attribution, and chronology. No seed is needed.
