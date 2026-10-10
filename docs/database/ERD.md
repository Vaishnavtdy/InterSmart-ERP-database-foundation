# Employee, customer, and lead ERD

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
