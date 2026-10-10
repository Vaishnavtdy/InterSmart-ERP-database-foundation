# InterSmart ERP employee, sales, and project-core ERD

```mermaid
erDiagram
  DEPARTMENTS ||--o{ USERS : "has employees"
  USERS o|--o{ USERS : "manages"
  USERS ||--o| EMPLOYEE_PROFILES : "has profile"
  USERS o|--o{ CUSTOMERS : "assigned salesperson"
  CUSTOMERS ||--o{ CUSTOMER_CONTACTS : "has contacts"
  CUSTOMERS o|--o{ LEADS : "optional customer linkage"
  USERS ||--o{ LEADS : "assigned salesperson"
  LEADS ||--o{ LEAD_ACTIVITIES : "activity history"
  USERS ||--o{ LEAD_ACTIVITIES : "activity author"
  CUSTOMERS ||--o{ PROPOSALS : "receives proposals"
  LEADS o|--o{ PROPOSALS : "optional lead"
  USERS ||--o{ PROPOSALS : "creates"
  PROPOSALS ||--o{ PROPOSAL_VERSIONS : "revision history"
  USERS ||--o{ PROPOSAL_VERSIONS : "creates revision"
  PROPOSAL_VERSIONS o|--o| PROPOSALS : "current owned revision"
  PROPOSAL_VERSIONS ||--o{ PROPOSAL_ITEMS : "revision items"
  CUSTOMERS ||--o{ PROJECTS : "owns projects"
  PROPOSALS o|--o{ PROJECTS : "optional origin"
  USERS ||--o{ PROJECTS : "salesperson"
  USERS o|--o{ PROJECTS : "optional manager/coordinator"
  PROJECT_CATEGORIES ||--o{ PROJECTS : "classifies"
  PROJECT_CATEGORIES o|--o{ PROJECT_CATEGORIES : "parent category"
  PROJECTS ||--o{ PROJECT_TEAMS : "team history"
  USERS ||--o{ PROJECT_TEAMS : "member"
  DEPARTMENTS ||--o{ PROJECT_TEAMS : "assignment department"
  PROJECTS ||--o{ PROJECT_STATUS_HISTORIES : "append-only lifecycle"
  USERS ||--o{ PROJECT_STATUS_HISTORIES : "changes status"
  PROJECTS ||--o{ PROJECT_COMMENTS : "internal comments"
  USERS ||--o{ PROJECT_COMMENTS : "comments"
  PROJECTS ||--o{ PROJECT_ACTIONS : "follow-up actions"
  USERS ||--o{ PROJECT_ACTIONS : "assigns/creates actions"

  PROJECTS {
    uuid id PK
    string project_code UK
    string name
    uuid customer_id FK
    uuid proposal_id FK
    uuid sales_person_id FK
    uuid project_manager_id FK
    uuid project_coordinator_id FK
    uuid category_id FK
    enum quality_level
    enum platform
    int page_count
    enum priority
    enum status
    timestamptz start_date
    timestamptz planned_end_date
    timestamptz actual_end_date
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }

  PROJECT_CATEGORIES {
    uuid id PK
    uuid parent_id FK
    string name
    string code UK
    string description
    boolean is_active
    timestamptz created_at
    timestamptz updated_at
  }

  PROJECT_TEAMS {
    uuid id PK
    uuid project_id FK
    uuid user_id FK
    uuid department_id FK
    enum project_role
    decimal allocation_percentage
    timestamptz assigned_at
    timestamptz released_at
  }

  PROJECT_STATUS_HISTORIES {
    uuid id PK
    uuid project_id FK
    enum from_status
    enum to_status
    enum reason
    uuid changed_by_id FK
    timestamptz created_at
  }

  PROJECT_COMMENTS {
    uuid id PK
    uuid project_id FK
    uuid user_id FK
    string comment
    timestamptz created_at
    timestamptz updated_at
  }

  PROJECT_ACTIONS {
    uuid id PK
    uuid project_id FK
    uuid assigned_to_id FK
    uuid created_by_id FK
    enum action_type
    string title
    string description
    timestamptz due_date
    enum status
    timestamptz completed_at
    timestamptz created_at
    timestamptz updated_at
  }

  PROPOSALS {
    uuid id PK
    string proposal_code UK
    uuid lead_id FK
    uuid customer_id FK
    uuid created_by_id FK
    string title
    enum status
    uuid current_version_id FK
    timestamptz valid_until
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }

  PROPOSAL_VERSIONS {
    uuid id PK
    uuid proposal_id FK
    int version_number
    enum status
    decimal subtotal
    decimal discount_amount
    decimal tax_amount
    decimal total_amount
    string notes
    timestamptz valid_until
    uuid created_by_id FK
    timestamptz created_at
    timestamptz sent_at
    timestamptz accepted_at
    timestamptz rejected_at
    string rejection_reason
  }

  PROPOSAL_ITEMS {
    uuid id PK
    uuid proposal_version_id FK
    string description
    decimal quantity
    decimal unit_price
    enum discount_type
    decimal discount_value
    decimal amount
    int sort_order
    timestamptz created_at
    timestamptz updated_at
  }

  LEADS {
    uuid id PK
    string lead_code UK
    uuid customer_id FK
    uuid assigned_to_id FK
    enum source
    string contact_name
    string email
    string phone
    string company_name
    string requirement
    decimal estimated_value
    timestamptz expected_close_date
    enum status
    enum temperature
    string notes
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }

  LEAD_ACTIVITIES {
    uuid id PK
    uuid lead_id FK
    uuid user_id FK
    enum activity_type
    string subject
    string description
    timestamptz scheduled_at
    timestamptz completed_at
    timestamptz next_follow_up_at
    timestamptz created_at
  }

  CUSTOMERS {
    uuid id PK
    string customer_code UK
    string company_name
    string website
    string industry
    string country
    string state
    string city
    string address
    string source
    enum status
    uuid assigned_salesperson_id FK
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }

  CUSTOMER_CONTACTS {
    uuid id PK
    uuid customer_id FK
    string first_name
    string last_name
    string email
    string phone
    string designation
    boolean is_primary
    enum status
    timestamptz created_at
    timestamptz updated_at
  }

  DEPARTMENTS {
    uuid id PK
    enum code UK
    timestamptz created_at
    timestamptz updated_at
  }

  USERS {
    uuid id PK
    string employee_code UK
    string email UK
    string password_hash
    string first_name
    string last_name
    string phone
    uuid department_id FK
    uuid manager_id FK
    enum status
    timestamptz joining_date
    timestamptz last_login_at
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }

  EMPLOYEE_PROFILES {
    uuid id PK
    uuid user_id FK, UK
    string job_title
    string work_location
    string bio
    timestamptz created_at
    timestamptz updated_at
  }
```

Organization boundary: this system serves InterSmart Technologies only. Do not
add an organizations table, `tenant_id`, or `organization_id`.

`customer_contacts.customer_id` has a partial unique index only for rows where
`is_primary = true`. Non-primary contacts are unrestricted in number. Neither
customers nor their contacts authenticate or participate in employee access
control.

`leads.customer_id` is nullable; employee assignment is required. Lead soft
deletion retains activities. Hard deletion of leads with activity history and
users with lead assignments/authored activities is restricted.

Proposal lead linkage is nullable, customer/creator linkage required. Version
`(proposal_id, version_number)` and `(proposal_id, id)` are composite unique
keys. Current selection uses `(proposals.id, current_version_id)` to reference
`(proposal_versions.proposal_id, id)`, ensuring the selected version belongs
to the same proposal. Item ordering is indexed by `(proposal_version_id,
sort_order)`; sort-order values need not be unique.

Project's customer, salesperson, and category are required; proposal, manager,
and coordinator are nullable. Team membership is unique by `(project_id,
user_id)` only while `released_at IS NULL`. History records store optional
reasons separately from lifecycle status and cannot be updated/deleted.
No resource-specific employee fields or calculated financial/work totals are
stored on Project.
