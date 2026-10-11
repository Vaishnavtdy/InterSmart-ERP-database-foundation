# InterSmart ERP employee, sales, and project-core ERD

```mermaid
erDiagram
  PROJECTS ||--o{ PROJECT_QA : "QA cycles"
  USERS ||--o{ PROJECT_QA : "creates"
  USERS o|--o{ PROJECT_QA : "optional approval"
  PROJECT_QA ||--o{ QA_TEST_CASES : "reusable definitions"
  USERS ||--o{ QA_TEST_CASES : "creates"
  QA_TEST_CASES ||--o{ QA_TEST_STEPS : "ordered manual steps"
  QA_TEST_CASES ||--o{ QA_TEST_EXECUTIONS : "repeated runs, same QA version"
  PROJECT_QA ||--o{ QA_TEST_EXECUTIONS : "run context"
  USERS o|--o{ QA_TEST_EXECUTIONS : "optional executor before run"
  DEVELOPMENT_ENVIRONMENTS o|--o{ QA_TEST_EXECUTIONS : "existing environment"
  PROJECT_QA ||--o{ QA_BUILDS : "manual build metadata"
  DEVELOPMENT_ENVIRONMENTS o|--o{ QA_BUILDS : "existing environment"
  USERS ||--o{ QA_BUILDS : "records"
  PROJECTS ||--o{ BUGS : "defects"
  PROJECT_QA o|--o{ BUGS : "optional same-project QA cycle"
  DEVELOPMENT_ENVIRONMENTS o|--o{ BUGS : "observed environment"
  USERS ||--o{ BUGS : "reports"
  USERS o|--o{ BUGS : "current assignee"
  USERS o|--o{ BUGS : "latest verifier"
  BUGS ||--o{ BUG_COMMENTS : "discussion"
  USERS ||--o{ BUG_COMMENTS : "comments"
  BUGS ||--o{ BUG_STATUS_HISTORY : "append-only audit"
  USERS ||--o{ BUG_STATUS_HISTORY : "changes status"
  BUGS ||--o{ BUG_TASK_LINKS : "development work"
  TASKS ||--o{ BUG_TASK_LINKS : "common work records"
  BUGS ||--o{ BUG_ATTACHMENTS : "exact File revision"
  FILES ||--o{ BUG_ATTACHMENTS : "MinIO metadata reused"
  USERS ||--o{ BUG_ATTACHMENTS : "attaches"
  QA_TEST_EXECUTIONS ||--o{ QA_EXECUTION_BUGS : "discoveries"
  BUGS ||--o{ QA_EXECUTION_BUGS : "defects from multiple runs"
  TASKS ||--o{ QA_TASK_LINKS : "common QA work"
  PROJECT_QA o|--o{ QA_TASK_LINKS : "optional cycle context"
  QA_TEST_CASES o|--o{ QA_TASK_LINKS : "optional case context"
  QA_TEST_EXECUTIONS o|--o{ QA_TASK_LINKS : "optional execution context"
  PROJECT_QA ||--o{ QA_DAILY_STATUS : "reporting snapshots"
  USERS ||--o{ QA_DAILY_STATUS : "reports"

  PROJECT_QA {
    uuid id PK
    uuid project_id FK
    int version_number "positive, unique with project_id"
    string title
    QaStatus status
    string test_scope "nullable"
    string test_strategy "nullable"
    string environment_notes "nullable"
    uuid created_by_id FK
    uuid approved_by_id FK "nullable, paired with approved_at"
    timestamptz created_at
    timestamptz updated_at
  }
  QA_TEST_CASES {
    uuid id PK
    uuid project_qa_id FK
    string test_case_code UK
    string title
    string module "nullable label"
    QaTestType test_type
    ProjectPriority priority
    QaTestCaseStatus status
    uuid created_by_id FK
    timestamptz deleted_at "nullable"
  }
  QA_TEST_STEPS {
    uuid id PK
    uuid test_case_id FK
    int step_number "positive, unique with case"
    string action
    string test_data "nullable"
    string expected_result "nullable"
  }
  QA_TEST_EXECUTIONS {
    uuid id PK
    uuid test_case_id FK
    uuid project_qa_id FK "same case QA cycle"
    uuid executed_by_id FK "nullable before run"
    uuid environment_id FK "nullable, existing Development"
    string build_version "nullable snapshot label"
    QaExecutionStatus status
    timestamptz started_at "nullable"
    timestamptz completed_at "nullable"
  }
  QA_BUILDS {
    uuid id PK
    uuid project_qa_id FK
    string version
    string build_number "nullable"
    string commit_hash "nullable"
    string release_notes "nullable"
    uuid environment_id FK "nullable"
    uuid created_by_id FK
    timestamptz created_at
  }
  BUGS {
    uuid id PK
    uuid project_id FK
    uuid project_qa_id FK "nullable, same project"
    string bug_code UK
    string title
    string description
    BugSeverity severity
    ProjectPriority priority
    BugStatus status
    BugSource source
    uuid environment_id FK "nullable"
    string build_version "nullable snapshot label"
    uuid reported_by_id FK
    uuid assigned_to_id FK "nullable"
    uuid verified_by_id FK "nullable, paired with verified_at"
    timestamptz resolved_at "nullable"
    timestamptz verified_at "nullable"
    timestamptz closed_at "nullable"
    timestamptz deleted_at "nullable"
  }
  BUG_COMMENTS {
    uuid id PK
    uuid bug_id FK
    uuid user_id FK
    string comment
  }
  BUG_STATUS_HISTORY {
    uuid id PK
    uuid bug_id FK
    BugStatus from_status "nullable initial event"
    BugStatus to_status
    uuid changed_by_id FK
    string reason "nullable"
    timestamptz created_at
  }
  BUG_TASK_LINKS {
    uuid id PK
    uuid bug_id FK "unique with task"
    uuid task_id FK
    timestamptz created_at
  }
  BUG_ATTACHMENTS {
    uuid id PK
    uuid bug_id FK "unique with File"
    uuid file_id FK
    uuid created_by_id FK
    timestamptz created_at
  }
  QA_EXECUTION_BUGS {
    uuid id PK
    uuid test_execution_id FK "unique with bug"
    uuid bug_id FK
    timestamptz created_at
  }
  QA_TASK_LINKS {
    uuid id PK
    uuid task_id FK
    uuid project_qa_id FK "nullable"
    uuid test_case_id FK "nullable"
    uuid test_execution_id FK "nullable"
    timestamptz created_at
  }
  QA_DAILY_STATUS {
    uuid id PK
    uuid project_qa_id FK
    date status_date "unique with QA cycle"
    QaDailyStatus status
    string summary
    int completion_percentage "nullable 0..100 snapshot"
    uuid created_by_id FK
  }

  PROJECTS ||--o{ SPRINTS : "reusable workstream planning"
  USERS ||--o{ SPRINTS : "creates"
  PROJECT_DEVELOPMENT o|--o{ SPRINTS : "optional same-project version"
  SPRINTS o|--o{ TASKS : "optional same-project membership"
  PROJECTS ||--o{ PROJECT_DEVELOPMENT : "Development versions"
  USERS ||--o{ PROJECT_DEVELOPMENT : "creates"
  USERS o|--o{ PROJECT_DEVELOPMENT : "approves"
  PROJECT_DEVELOPMENT ||--o{ DEVELOPMENT_MODULES : "modules and features"
  USERS ||--o{ DEVELOPMENT_MODULES : "creates"
  TASKS ||--o{ DEVELOPMENT_TASK_LINKS : "common Development work"
  PROJECT_DEVELOPMENT ||--o{ DEVELOPMENT_TASK_LINKS : "version context"
  DEVELOPMENT_MODULES o|--o{ DEVELOPMENT_TASK_LINKS : "optional same-version module"
  PROJECT_DEVELOPMENT ||--o{ DEVELOPMENT_REPOSITORIES : "repository metadata"
  USERS ||--o{ DEVELOPMENT_REPOSITORIES : "creates"
  PROJECT_DEVELOPMENT ||--o{ DEVELOPMENT_ENVIRONMENTS : "environment metadata"
  PROJECT_DEVELOPMENT ||--o{ DEVELOPMENT_DEPLOYMENTS : "deployment attempts"
  DEVELOPMENT_ENVIRONMENTS ||--o{ DEVELOPMENT_DEPLOYMENTS : "same-version environment"
  USERS ||--o{ DEVELOPMENT_DEPLOYMENTS : "deployed by"
  PROJECT_DEVELOPMENT ||--o{ DEVELOPMENT_DAILY_STATUS : "daily reporting"
  USERS ||--o{ DEVELOPMENT_DAILY_STATUS : "reports"

  SPRINTS {
    uuid id PK
    uuid project_id FK
    uuid project_development_id FK "nullable, DEVELOPMENT context only"
    string name
    string code "unique with project_id"
    TaskWorkstream workstream
    string goal "nullable"
    string description "nullable"
    SprintStatus status
    timestamptz start_date "nullable"
    timestamptz end_date "nullable, not before start"
    uuid created_by_id FK
    timestamptz completed_at "nullable"
    timestamptz created_at
    timestamptz updated_at
  }
  PROJECT_DEVELOPMENT {
    uuid id PK
    uuid project_id FK
    int version_number "positive, unique with project_id"
    string title
    string description "nullable"
    DevelopmentStatus status
    string development_summary "nullable"
    string technical_notes "nullable"
    uuid created_by_id FK
    uuid approved_by_id FK "nullable"
    timestamptz approved_at "nullable, paired with actor"
    timestamptz created_at
    timestamptz updated_at
  }
  DEVELOPMENT_MODULES {
    uuid id PK
    uuid project_development_id FK
    string name
    string code "unique within Development version"
    string description "nullable"
    DevelopmentModuleType module_type
    DevelopmentModuleStatus status
    ProjectPriority priority
    int sort_order
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }
  DEVELOPMENT_TASK_LINKS {
    uuid id PK
    uuid task_id FK
    uuid project_development_id FK
    uuid development_module_id FK "nullable, same version"
    timestamptz created_at
  }
  DEVELOPMENT_REPOSITORIES {
    uuid id PK
    uuid project_development_id FK
    string name
    string repository_url
    RepositoryProvider provider
    RepositoryType repository_type
    string default_branch "nullable"
    string description "nullable"
    boolean is_active
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }
  DEVELOPMENT_ENVIRONMENTS {
    uuid id PK
    uuid project_development_id FK
    string name
    DevelopmentEnvironmentType environment_type
    string base_url "nullable"
    string description "nullable"
    boolean is_active
    timestamptz created_at
    timestamptz updated_at
  }
  DEVELOPMENT_DEPLOYMENTS {
    uuid id PK
    uuid project_development_id FK
    uuid environment_id FK "same Development version"
    uuid deployed_by_id FK
    string version
    string commit_hash "nullable"
    DeploymentStatus deployment_status
    string deployment_url "nullable"
    string notes "nullable"
    timestamptz deployed_at "nullable"
    timestamptz created_at
    timestamptz updated_at
  }
  DEVELOPMENT_DAILY_STATUS {
    uuid id PK
    uuid project_development_id FK
    date status_date "unique with version"
    DevelopmentDailyStatus status
    string summary
    string completed_work "nullable"
    string planned_work "nullable"
    string blockers "nullable"
    string risks "nullable"
    int completion_percentage "nullable, 0..100 snapshot"
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }

  PROJECTS ||--o{ PROJECT_UX : "UX specification versions"
  USERS ||--o{ PROJECT_UX : "creates"
  USERS o|--o{ PROJECT_UX : "approves"
  PROJECT_UX ||--o{ UX_SCREENS : "defines screens"
  USERS ||--o{ UX_SCREENS : "creates"
  PROJECT_UX ||--o{ UX_FLOWS : "defines flows"
  USERS ||--o{ UX_FLOWS : "creates"
  UX_FLOWS ||--o{ UX_FLOW_STEPS : "ordered steps"
  UX_SCREENS o|--o{ UX_FLOW_STEPS : "optional screen"
  TASKS ||--o{ UX_TASK_LINKS : "common UX work"
  PROJECT_UX ||--o{ UX_TASK_LINKS : "version context"
  UX_SCREENS o|--o{ UX_TASK_LINKS : "optional same-version screen"
  UX_FLOWS o|--o{ UX_TASK_LINKS : "optional same-version flow"
  PROJECT_UX ||--o{ UX_DAILY_STATUS : "daily reporting"
  USERS ||--o{ UX_DAILY_STATUS : "reports"
  PROJECT_UX ||--o{ UX_DESIGN_LINKS : "external design URLs"
  USERS ||--o{ UX_DESIGN_LINKS : "creates"

  PROJECT_UX {
    uuid id PK
    uuid project_id FK
    int version_number "unique with project_id, positive"
    string title
    string description "nullable"
    UxStatus status
    string research_summary "nullable"
    string user_personas "nullable"
    string user_journey_summary "nullable"
    uuid created_by_id FK
    uuid approved_by_id FK "nullable"
    timestamptz approved_at "nullable, paired with approver"
    timestamptz created_at
    timestamptz updated_at
  }
  UX_SCREENS {
    uuid id PK
    uuid project_ux_id FK
    string name
    string description "nullable"
    UxScreenType screen_type
    string route "nullable, nonunique"
    int sort_order
    UxScreenStatus status
    boolean is_required
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }
  UX_FLOWS {
    uuid id PK
    uuid project_ux_id FK
    string name
    string description "nullable"
    UxFlowType flow_type
    UxFlowStatus status
    int sort_order
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }
  UX_FLOW_STEPS {
    uuid id PK
    uuid ux_flow_id FK
    int step_number "positive, unique within flow"
    string name
    string description "nullable"
    uuid screen_id FK "nullable"
    string action "nullable"
    string expected_result "nullable"
    timestamptz created_at
    timestamptz updated_at
  }
  UX_TASK_LINKS {
    uuid id PK
    uuid task_id FK
    uuid project_ux_id FK
    uuid ux_screen_id FK "nullable, same version"
    uuid ux_flow_id FK "nullable, same version"
    timestamptz created_at
  }
  UX_DAILY_STATUS {
    uuid id PK
    uuid project_ux_id FK
    date status_date "unique with version"
    UxDailyStatusType status
    string summary
    string completed_work "nullable"
    string planned_work "nullable"
    string blockers "nullable"
    int completion_percentage "nullable, 0..100 snapshot"
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }
  UX_DESIGN_LINKS {
    uuid id PK
    uuid project_ux_id FK
    string title
    string url
    UxDesignLinkType link_type
    string description "nullable"
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }

  PROJECTS ||--o{ PROJECT_UI : "UI specification versions"
  USERS ||--o{ PROJECT_UI : "creates"
  USERS o|--o{ PROJECT_UI : "approves"
  PROJECT_UI ||--o{ UI_PAGES : "defines pages"
  USERS ||--o{ UI_PAGES : "creates"
  UI_PAGES ||--o{ UI_SECTIONS : "contains"
  USERS ||--o{ UI_SECTIONS : "creates"
  TASKS ||--o{ UI_TASK_LINKS : "common UI work"
  UI_PAGES ||--o{ UI_TASK_LINKS : "page target"
  UI_SECTIONS o|--o{ UI_TASK_LINKS : "optional section within page"
  PROJECT_UI ||--o{ UI_DAILY_STATUS : "daily reporting"
  USERS ||--o{ UI_DAILY_STATUS : "reports"
  PROJECT_UI ||--o{ UI_DESIGN_LINKS : "external design URLs"
  USERS ||--o{ UI_DESIGN_LINKS : "creates"

  PROJECT_UI {
    uuid id PK
    uuid project_id FK
    int version_number "unique with project_id, positive"
    string title
    string description "nullable"
    UiStatus status
    uuid created_by_id FK
    uuid approved_by_id FK "nullable"
    timestamptz approved_at "nullable, paired with approver"
    timestamptz created_at
    timestamptz updated_at
  }
  UI_PAGES {
    uuid id PK
    uuid project_ui_id FK
    string name
    string slug "unique within specification"
    UiPageType page_type
    string description "nullable"
    string url "nullable, nonunique"
    int sort_order
    UiPageStatus status
    boolean is_required
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }
  UI_SECTIONS {
    uuid id PK
    uuid ui_page_id FK
    string name
    string description "nullable"
    UiSectionType section_type
    int sort_order
    UiPageStatus status
    boolean is_required
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }
  UI_TASK_LINKS {
    uuid id PK
    uuid task_id FK
    uuid ui_page_id FK
    uuid ui_section_id FK "nullable, same page"
    timestamptz created_at
  }
  UI_DAILY_STATUS {
    uuid id PK
    uuid project_ui_id FK
    date status_date "unique with specification"
    UiStatus status
    string summary
    string blockers "nullable"
    int completion_percentage "nullable, 0..100 snapshot"
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }
  UI_DESIGN_LINKS {
    uuid id PK
    uuid project_ui_id FK
    string title
    string url
    UiDesignLinkType link_type
    string description "nullable"
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }

  PROJECTS ||--o{ TASKS : "executable work"
  TASKS o|--o{ TASKS : "parent and children in same project"
  USERS ||--o{ TASKS : "creates"
  USERS o|--o{ TASKS : "current assignee"
  TASKS ||--o{ TASK_DEPENDENCIES : "owns dependency"
  TASKS ||--o{ TASK_DEPENDENCIES : "referenced prerequisite"
  TASKS ||--o{ TASK_COMMENTS : "discussion"
  USERS ||--o{ TASK_COMMENTS : "comments"
  TASKS ||--o{ TASK_STATUS_HISTORY : "status history"
  USERS ||--o{ TASK_STATUS_HISTORY : "changes status"
  TASKS ||--o{ TASK_ASSIGNMENTS : "assignment periods"
  USERS ||--o{ TASK_ASSIGNMENTS : "receives"
  USERS ||--o{ TASK_ASSIGNMENTS : "assigns"

  TASKS {
    uuid id PK
    uuid project_id FK
    uuid sprint_id FK "nullable, same project"
    uuid parent_task_id FK "nullable, same project"
    string task_code UK
    string title
    string description "nullable"
    TaskType task_type
    TaskWorkstream workstream
    TaskStatus status
    ProjectPriority priority "reused"
    uuid created_by_id FK
    uuid assigned_to_id FK "nullable"
    timestamptz start_date "nullable"
    timestamptz due_date "nullable"
    timestamptz completed_at "nullable"
    decimal estimated_hours "nullable summary"
    decimal actual_hours "nullable summary"
    int sort_order
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at "nullable"
  }
  TASK_DEPENDENCIES {
    uuid id PK
    uuid task_id FK
    uuid depends_on_task_id FK
    TaskDependencyType dependency_type
    timestamptz created_at
  }
  TASK_COMMENTS {
    uuid id PK
    uuid task_id FK
    uuid user_id FK
    string comment
    timestamptz created_at
    timestamptz updated_at
  }
  TASK_STATUS_HISTORY {
    uuid id PK
    uuid task_id FK
    TaskStatus from_status "nullable"
    TaskStatus to_status
    uuid changed_by_id FK
    string reason "nullable"
    timestamptz created_at
  }
  TASK_ASSIGNMENTS {
    uuid id PK
    uuid task_id FK
    uuid assigned_to_id FK
    uuid assigned_by_id FK
    timestamptz assigned_at
    timestamptz released_at "nullable"
    string reason "nullable"
  }
  PROJECTS ||--o{ PAYMENT_REQUESTS : "has requests"
  CUSTOMERS ||--o{ PAYMENT_REQUESTS : "owes"
  USERS ||--o{ PAYMENT_REQUESTS : "requests"
  USERS o|--o{ PAYMENT_REQUESTS : "approves"
  USERS o|--o{ PAYMENT_REQUESTS : "rejects"
  PAYMENT_REQUESTS o|--o{ PAYMENTS : "receives installments"
  PROJECTS ||--o{ PAYMENTS : "customer receipts"
  CUSTOMERS ||--o{ PAYMENTS : "pays"
  USERS ||--o{ PAYMENTS : "records"
  PAYMENTS ||--o{ PAYMENT_STATUS_HISTORY : "status history"
  USERS ||--o{ PAYMENT_STATUS_HISTORY : "changes"
  PAYMENT_REQUESTS ||--o{ PAYMENT_REQUEST_STATUS_HISTORY : "status history"
  USERS ||--o{ PAYMENT_REQUEST_STATUS_HISTORY : "changes"

  PAYMENT_REQUESTS {
    uuid id PK
    string payment_request_code UK
    uuid project_id FK
    uuid customer_id FK
    uuid requested_by_id FK
    decimal amount
    string currency
    PaymentType payment_type
    string description "nullable"
    timestamptz due_date "nullable"
    PaymentRequestStatus status
    timestamptz requested_at
    timestamptz approved_at "nullable"
    uuid approved_by_id FK "nullable"
    timestamptz rejected_at "nullable"
    uuid rejected_by_id FK "nullable"
    string rejection_reason "nullable"
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at "nullable"
  }
  PAYMENTS {
    uuid id PK
    string payment_code UK
    uuid payment_request_id FK "nullable"
    uuid project_id FK
    uuid customer_id FK
    decimal amount
    string currency
    PaymentMethod payment_method
    timestamptz payment_date
    string transaction_reference "nullable nonunique"
    string receipt_number UK "nullable"
    PaymentStatus status
    string notes "nullable"
    uuid recorded_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }
  PAYMENT_STATUS_HISTORY {
    uuid id PK
    uuid payment_id FK
    PaymentStatus from_status "nullable"
    PaymentStatus to_status
    uuid changed_by_id FK
    string reason "nullable"
    timestamptz created_at
  }
  PAYMENT_REQUEST_STATUS_HISTORY {
    uuid id PK
    uuid payment_request_id FK
    PaymentRequestStatus from_status "nullable"
    PaymentRequestStatus to_status
    uuid changed_by_id FK
    string reason "nullable"
    timestamptz created_at
  }
  PROJECTS ||--o| PROJECT_BUDGETS : "budget definition"
  USERS ||--o{ PROJECT_BUDGETS : "creates"
  USERS o|--o{ PROJECT_BUDGETS : "last updates"
  PROJECT_BUDGETS ||--o{ BUDGET_ALLOCATIONS : "plans allocations"
  DEPARTMENTS o|--o{ BUDGET_ALLOCATIONS : "optional department"
  USERS o|--o{ BUDGET_ALLOCATIONS : "optional employee target"
  USERS ||--o{ BUDGET_ALLOCATIONS : "creates"
  PROJECT_BUDGETS ||--o{ BUDGET_TRANSACTIONS : "financial events"
  BUDGET_ALLOCATIONS o|--o{ BUDGET_TRANSACTIONS : "optional same-budget attribution"
  USERS ||--o{ BUDGET_TRANSACTIONS : "records"

  PROJECT_BUDGETS {
    uuid id PK
    uuid project_id FK, UK
    decimal total_budget
    string currency
    enum status
    timestamptz effective_from
    timestamptz effective_until
    string notes
    uuid created_by_id FK
    uuid updated_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }

  BUDGET_ALLOCATIONS {
    uuid id PK
    uuid project_budget_id FK
    uuid department_id FK
    uuid user_id FK
    enum allocation_type
    decimal allocated_amount
    string description
    uuid created_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }

  BUDGET_TRANSACTIONS {
    uuid id PK
    uuid project_budget_id FK
    uuid allocation_id FK
    enum transaction_type
    decimal amount
    string reference
    string description
    timestamptz transaction_date
    uuid created_by_id FK
    timestamptz created_at
  }
  PROJECTS ||--o{ FILES : "owns physical metadata"
  USERS ||--o{ FILES : "uploads"
  PROJECTS ||--o{ PROJECT_RESOURCES : "classifies resources"
  FILES ||--o{ PROJECT_RESOURCES : "same-project business references"
  USERS ||--o{ PROJECT_RESOURCES : "uploads resource reference"

  FILES {
    uuid id PK
    uuid project_id FK
    uuid file_series_id
    uuid uploaded_by_id FK
    string file_name
    string original_name
    string storage_key UK
    string bucket
    string mime_type
    bigint size_bytes
    string checksum
    int version
    boolean is_current
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }

  PROJECT_RESOURCES {
    uuid id PK
    uuid project_id FK
    uuid file_id FK
    uuid resource_series_id
    enum resource_type
    string title
    string description
    int version
    boolean is_current
    uuid uploaded_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }
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
  PROJECTS ||--o{ PROJECT_SCOPES : "scope revisions"
  PROJECT_SCOPES ||--o{ PROJECT_SCOPE_ITEMS : "included/excluded deliverables"
  USERS ||--o{ PROJECT_SCOPES : "creates"
  USERS o|--o{ PROJECT_SCOPES : "approves"
  PROJECTS ||--o| BUSINESS_ANALYSES : "current business analysis"
  USERS ||--o{ BUSINESS_ANALYSES : "creates"
  USERS o|--o{ BUSINESS_ANALYSES : "last updates"
  BUSINESS_ANALYSES ||--o{ COMPETITORS : "analyses competitors"

  PROJECT_SCOPES {
    uuid id PK
    uuid project_id FK
    int version_number
    string title
    string summary
    string scope_description
    enum status
    uuid created_by_id FK
    uuid approved_by_id FK
    timestamptz approved_at
    timestamptz created_at
    timestamptz updated_at
  }

  PROJECT_SCOPE_ITEMS {
    uuid id PK
    uuid project_scope_id FK
    string name
    string description
    enum item_type
    boolean is_included
    decimal estimated_hours
    int sort_order
    timestamptz created_at
    timestamptz updated_at
  }

  BUSINESS_ANALYSES {
    uuid id PK
    uuid project_id FK, UK
    string purpose
    string about_company
    string target_audience
    string usp
    string conclusion
    uuid created_by_id FK
    uuid updated_by_id FK
    timestamptz created_at
    timestamptz updated_at
  }

  COMPETITORS {
    uuid id PK
    uuid business_analysis_id FK
    string name
    string website
    string description
    string strengths
    string weaknesses
    timestamptz created_at
    timestamptz updated_at
  }

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

Scope `(project_id, version_number)` is unique, and only one scope may have
APPROVED status per project. Approved scope content and items remain frozen
after supersession. Business Analysis has one unique project reference and
separate multiple competitor records; project soft deletion preserves both
scope history and analysis.

Files hold MinIO bucket/key metadata, never binaries or permanent public URLs.
Resources hold classification, not duplicate physical storage metadata.
Resource `(project_id, file_id)` must reference a file's `(project_id, id)`.
Stable series identifiers support multiple assets per type with independent
version histories. File project/series/version and resource
project/type/series/version are unique; at-most-one current per series remains
a future application rule. Restrict FKs and file soft deletion preserve rows.

Budgets are unique by project and never stored directly on Project. Allocation
targets are optional; transaction allocations must belong to the same budget.
All money is NUMERIC(18,2); signed events preserve funding/consumption history.
Configured opening budget and its INITIAL_ALLOCATION are not added twice.
Balances are derived later, with reversal/accounting policies validated by
future services. Customer payments and generic approval remain separate.

Customer → Project → Payment Request → multiple Payments is the customer
collection domain, separate from internal project budgets. Direct payments
may have no request. Paid/remaining totals are derived from CONFIRMED receipts;
overpayments remain visible. All new FKs restrict deletion. Requests soft-delete,
payments cannot physically delete/truncate, and both histories are append-only.
Services must enforce matching project/customer/request/currency and atomic
current-status/history writes; the database does not implement those workflows.

Tasks are shared across workstreams; project_actions remain separate high-level
follow-ups. Parent tasks must belong to the same project; self-parenting and
self-dependencies are rejected. Dependencies may have multiple prerequisites.
Status history is append-only; assignment facts are retained with one-time
release and at most one active period per task. FKs do not cascade deletion.
Current state/history coherence and longer cycle checks are future service rules.
Detailed time tracking, sprints, bugs, approvals, task files and notifications
are intentionally deferred; hours are nullable Decimal summaries only.

UI executable work uses the common task engine with workstream = UI, through
ui_task_links outside generic task scalar fields. Linked sections must belong
to the page; both page-only and section-level duplicates are prevented.
Same-project/UI-workstream enforcement and finalized specification retention
are future service contracts, not implicit FK guarantees. Revisions insert
new specification/page/section rows and retain predecessor references.
UI staffing uses ProjectTeam; files reuse existing MinIO File/ProjectResource
metadata with resourceType UI, without a version-specific attachment model.
Daily UI status is a reporting snapshot, not authoritative task/project progress.
All new FKs restrict deletion; page/section statuses share UiPageStatus.

UX uses common tasks (workstream UX) through version-owned ux_task_links.
At least one screen/flow is required; composite context FKs enforce same-version
references and partial unique indexes prevent NULL-context duplicates.
Flow-step numbers are positive/unique within a flow; screen is optional.
Same-version flow-step screen alignment and task project/workstream policies
remain service rules. UX staffing/files reuse ProjectTeam and File/ProjectResource
with UX classification. Task dates/hierarchy support planning without UX sprints.
Daily reporting is a correctable snapshot, not authoritative project progress.
UX revisions retain finalized predecessor graphs by future service contract;
all 17 new FKs restrict deletion but do not freeze historical content.

Development uses generic tasks, dependencies, history, teams and MinIO metadata.
Sprint is reusable by Project/workstream, optionally version-scoped for DEVELOPMENT.
Task.sprint_id remains nullable; composite FK ensures same-project membership.
Task/sprint workstream alignment and lifecycle/move policy remain service rules.
Development modules and deployment environments are version-owned, with composite
FKs preventing mismatched module links/environment attribution. All 20 new FKs
restrict deletion. Deployment attempts store metadata only, not CI/CD events or
secrets. Daily percentage is a correctable snapshot, not authoritative progress.
The report Prisma model is DevelopmentDailyReport, avoiding the requested enum
name collision. Version/deployment-attempt retention remains a service contract.

Step 15 QA & Bug Management: QA uses common tasks and existing generic sprints
(workstream QA), ProjectTeam QA and File/ProjectResource QA. Sprint is unchanged.
Definitions are reusable; executions are repeated actual runs. Environment/build
references reuse Development metadata without CI/CD. Bugs are separate defects
with optional cycle, multiple work-task links, exact File attachments and
many-to-many execution discoveries. All 36 new FKs restrict deletion.
Bug history cannot UPDATE/DELETE/TRUNCATE; current status and attributed events
must be written atomically by future services, without a DB lifecycle state machine.
Nullable QA task contexts independently reference real records; same-cycle/case/
Project/workstream alignment is service policy. Environment, attachment and bug
task/discovery Project alignment also require validation on writes and later moves.
QA daily percentage is a snapshot; QaDailyReport avoids the enum naming collision.
README lists every required/nullable scalar and timestamp omitted from compact
entity blocks above. No secrets, duplicated work/team/storage or tenant engine.
