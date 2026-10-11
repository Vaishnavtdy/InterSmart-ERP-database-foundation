BEGIN;

-- CreateEnum
CREATE TYPE "QaStatus" AS ENUM ('DRAFT', 'PLANNING', 'IN_PROGRESS', 'IN_REVIEW', 'READY_FOR_RELEASE', 'RETESTING', 'COMPLETED', 'ON_HOLD', 'CANCELLED');

-- CreateEnum
CREATE TYPE "QaTestType" AS ENUM ('FUNCTIONAL', 'UI', 'API', 'INTEGRATION', 'REGRESSION', 'SMOKE', 'SANITY', 'PERFORMANCE', 'SECURITY', 'COMPATIBILITY', 'USER_ACCEPTANCE', 'OTHER');

-- CreateEnum
CREATE TYPE "QaTestCaseStatus" AS ENUM ('DRAFT', 'READY', 'IN_PROGRESS', 'PASSED', 'FAILED', 'BLOCKED', 'RETIRED');

-- CreateEnum
CREATE TYPE "QaExecutionStatus" AS ENUM ('NOT_RUN', 'PASSED', 'FAILED', 'BLOCKED', 'SKIPPED', 'IN_PROGRESS');

-- CreateEnum
CREATE TYPE "BugSeverity" AS ENUM ('BLOCKER', 'CRITICAL', 'MAJOR', 'MINOR', 'TRIVIAL');

-- CreateEnum
CREATE TYPE "BugStatus" AS ENUM ('OPEN', 'TRIAGED', 'ASSIGNED', 'IN_PROGRESS', 'FIXED', 'READY_FOR_RETEST', 'REOPENED', 'VERIFIED', 'CLOSED', 'WONT_FIX', 'DUPLICATE', 'CANNOT_REPRODUCE', 'BLOCKED');

-- CreateEnum
CREATE TYPE "BugSource" AS ENUM ('MANUAL_TESTING', 'REGRESSION', 'UAT', 'PRODUCTION', 'CUSTOMER_REPORTED', 'INTERNAL', 'AUTOMATED_TEST', 'OTHER');

-- CreateEnum
CREATE TYPE "QaDailyStatus" AS ENUM ('NOT_STARTED', 'IN_PROGRESS', 'BLOCKED', 'READY_FOR_RELEASE', 'COMPLETED', 'ON_HOLD');

-- CreateTable
CREATE TABLE "project_qa" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "version_number" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "status" "QaStatus" NOT NULL DEFAULT 'DRAFT',
    "test_scope" TEXT,
    "test_strategy" TEXT,
    "environment_notes" TEXT,
    "created_by_id" UUID NOT NULL,
    "approved_by_id" UUID,
    "approved_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_qa_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "qa_test_cases" (
    "id" UUID NOT NULL,
    "project_qa_id" UUID NOT NULL,
    "test_case_code" VARCHAR(64) NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "module" VARCHAR(255),
    "preconditions" TEXT,
    "expected_result" TEXT,
    "test_type" "QaTestType" NOT NULL DEFAULT 'FUNCTIONAL',
    "priority" "ProjectPriority" NOT NULL DEFAULT 'MEDIUM',
    "status" "QaTestCaseStatus" NOT NULL DEFAULT 'DRAFT',
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "qa_test_cases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "qa_test_steps" (
    "id" UUID NOT NULL,
    "test_case_id" UUID NOT NULL,
    "step_number" INTEGER NOT NULL,
    "action" TEXT NOT NULL,
    "test_data" TEXT,
    "expected_result" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "qa_test_steps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "qa_test_executions" (
    "id" UUID NOT NULL,
    "test_case_id" UUID NOT NULL,
    "project_qa_id" UUID NOT NULL,
    "executed_by_id" UUID,
    "environment_id" UUID,
    "build_version" VARCHAR(100),
    "status" "QaExecutionStatus" NOT NULL DEFAULT 'NOT_RUN',
    "started_at" TIMESTAMPTZ(6),
    "completed_at" TIMESTAMPTZ(6),
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "qa_test_executions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "qa_builds" (
    "id" UUID NOT NULL,
    "project_qa_id" UUID NOT NULL,
    "version" VARCHAR(100) NOT NULL,
    "build_number" VARCHAR(100),
    "commit_hash" VARCHAR(128),
    "release_notes" TEXT,
    "environment_id" UUID,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "qa_builds_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bugs" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "project_qa_id" UUID,
    "bug_code" VARCHAR(64) NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "steps_to_reproduce" TEXT,
    "expected_result" TEXT,
    "actual_result" TEXT,
    "severity" "BugSeverity" NOT NULL DEFAULT 'MAJOR',
    "priority" "ProjectPriority" NOT NULL DEFAULT 'MEDIUM',
    "status" "BugStatus" NOT NULL DEFAULT 'OPEN',
    "source" "BugSource" NOT NULL DEFAULT 'MANUAL_TESTING',
    "environment_id" UUID,
    "build_version" VARCHAR(100),
    "reported_by_id" UUID NOT NULL,
    "assigned_to_id" UUID,
    "verified_by_id" UUID,
    "resolved_at" TIMESTAMPTZ(6),
    "verified_at" TIMESTAMPTZ(6),
    "closed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "bugs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bug_comments" (
    "id" UUID NOT NULL,
    "bug_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "comment" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "bug_comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bug_status_history" (
    "id" UUID NOT NULL,
    "bug_id" UUID NOT NULL,
    "from_status" "BugStatus",
    "to_status" "BugStatus" NOT NULL,
    "changed_by_id" UUID NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "bug_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bug_task_links" (
    "id" UUID NOT NULL,
    "bug_id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "bug_task_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bug_attachments" (
    "id" UUID NOT NULL,
    "bug_id" UUID NOT NULL,
    "file_id" UUID NOT NULL,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "bug_attachments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "qa_execution_bugs" (
    "id" UUID NOT NULL,
    "test_execution_id" UUID NOT NULL,
    "bug_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "qa_execution_bugs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "qa_task_links" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "project_qa_id" UUID,
    "test_case_id" UUID,
    "test_execution_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "qa_task_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "qa_daily_status" (
    "id" UUID NOT NULL,
    "project_qa_id" UUID NOT NULL,
    "status_date" DATE NOT NULL,
    "status" "QaDailyStatus" NOT NULL DEFAULT 'NOT_STARTED',
    "summary" TEXT NOT NULL,
    "completed_work" TEXT,
    "planned_work" TEXT,
    "blockers" TEXT,
    "risks" TEXT,
    "completion_percentage" INTEGER,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "qa_daily_status_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "project_qa_status_idx" ON "project_qa"("status");

-- CreateIndex
CREATE INDEX "project_qa_created_by_id_idx" ON "project_qa"("created_by_id");

-- CreateIndex
CREATE INDEX "project_qa_approved_by_id_idx" ON "project_qa"("approved_by_id");

-- CreateIndex
CREATE INDEX "project_qa_created_at_idx" ON "project_qa"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "project_qa_project_id_version_number_key" ON "project_qa"("project_id", "version_number");

-- CreateIndex
CREATE UNIQUE INDEX "project_qa_project_id_id_key" ON "project_qa"("project_id", "id");

-- CreateIndex
CREATE UNIQUE INDEX "qa_test_cases_test_case_code_key" ON "qa_test_cases"("test_case_code");

-- CreateIndex
CREATE INDEX "qa_test_cases_project_qa_id_deleted_at_idx" ON "qa_test_cases"("project_qa_id", "deleted_at");

-- CreateIndex
CREATE INDEX "qa_test_cases_status_idx" ON "qa_test_cases"("status");

-- CreateIndex
CREATE INDEX "qa_test_cases_test_type_idx" ON "qa_test_cases"("test_type");

-- CreateIndex
CREATE INDEX "qa_test_cases_priority_idx" ON "qa_test_cases"("priority");

-- CreateIndex
CREATE INDEX "qa_test_cases_created_by_id_idx" ON "qa_test_cases"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "qa_test_cases_project_qa_id_id_key" ON "qa_test_cases"("project_qa_id", "id");

-- CreateIndex
CREATE UNIQUE INDEX "qa_test_steps_test_case_id_step_number_key" ON "qa_test_steps"("test_case_id", "step_number");

-- CreateIndex
CREATE INDEX "qa_test_executions_test_case_id_idx" ON "qa_test_executions"("test_case_id");

-- CreateIndex
CREATE INDEX "qa_test_executions_project_qa_id_idx" ON "qa_test_executions"("project_qa_id");

-- CreateIndex
CREATE INDEX "qa_test_executions_executed_by_id_idx" ON "qa_test_executions"("executed_by_id");

-- CreateIndex
CREATE INDEX "qa_test_executions_environment_id_idx" ON "qa_test_executions"("environment_id");

-- CreateIndex
CREATE INDEX "qa_test_executions_status_idx" ON "qa_test_executions"("status");

-- CreateIndex
CREATE INDEX "qa_test_executions_started_at_idx" ON "qa_test_executions"("started_at");

-- CreateIndex
CREATE INDEX "qa_builds_project_qa_id_version_build_number_idx" ON "qa_builds"("project_qa_id", "version", "build_number");

-- CreateIndex
CREATE INDEX "qa_builds_version_idx" ON "qa_builds"("version");

-- CreateIndex
CREATE INDEX "qa_builds_build_number_idx" ON "qa_builds"("build_number");

-- CreateIndex
CREATE INDEX "qa_builds_environment_id_idx" ON "qa_builds"("environment_id");

-- CreateIndex
CREATE INDEX "qa_builds_created_by_id_idx" ON "qa_builds"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "bugs_bug_code_key" ON "bugs"("bug_code");

-- CreateIndex
CREATE INDEX "bugs_project_id_deleted_at_idx" ON "bugs"("project_id", "deleted_at");

-- CreateIndex
CREATE INDEX "bugs_project_qa_id_idx" ON "bugs"("project_qa_id");

-- CreateIndex
CREATE INDEX "bugs_status_deleted_at_idx" ON "bugs"("status", "deleted_at");

-- CreateIndex
CREATE INDEX "bugs_severity_idx" ON "bugs"("severity");

-- CreateIndex
CREATE INDEX "bugs_priority_idx" ON "bugs"("priority");

-- CreateIndex
CREATE INDEX "bugs_assigned_to_id_idx" ON "bugs"("assigned_to_id");

-- CreateIndex
CREATE INDEX "bugs_reported_by_id_idx" ON "bugs"("reported_by_id");

-- CreateIndex
CREATE INDEX "bugs_verified_by_id_idx" ON "bugs"("verified_by_id");

-- CreateIndex
CREATE INDEX "bugs_environment_id_idx" ON "bugs"("environment_id");

-- CreateIndex
CREATE INDEX "bugs_created_at_idx" ON "bugs"("created_at");

-- CreateIndex
CREATE INDEX "bug_comments_bug_id_idx" ON "bug_comments"("bug_id");

-- CreateIndex
CREATE INDEX "bug_comments_user_id_idx" ON "bug_comments"("user_id");

-- CreateIndex
CREATE INDEX "bug_comments_created_at_idx" ON "bug_comments"("created_at");

-- CreateIndex
CREATE INDEX "bug_status_history_bug_id_created_at_idx" ON "bug_status_history"("bug_id", "created_at");

-- CreateIndex
CREATE INDEX "bug_status_history_changed_by_id_idx" ON "bug_status_history"("changed_by_id");

-- CreateIndex
CREATE INDEX "bug_status_history_created_at_idx" ON "bug_status_history"("created_at");

-- CreateIndex
CREATE INDEX "bug_task_links_task_id_idx" ON "bug_task_links"("task_id");

-- CreateIndex
CREATE UNIQUE INDEX "bug_task_links_bug_id_task_id_key" ON "bug_task_links"("bug_id", "task_id");

-- CreateIndex
CREATE INDEX "bug_attachments_file_id_idx" ON "bug_attachments"("file_id");

-- CreateIndex
CREATE INDEX "bug_attachments_created_by_id_idx" ON "bug_attachments"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "bug_attachments_bug_id_file_id_key" ON "bug_attachments"("bug_id", "file_id");

-- CreateIndex
CREATE INDEX "qa_execution_bugs_bug_id_idx" ON "qa_execution_bugs"("bug_id");

-- CreateIndex
CREATE UNIQUE INDEX "qa_execution_bugs_test_execution_id_bug_id_key" ON "qa_execution_bugs"("test_execution_id", "bug_id");

-- CreateIndex
CREATE INDEX "qa_task_links_task_id_idx" ON "qa_task_links"("task_id");

-- CreateIndex
CREATE INDEX "qa_task_links_project_qa_id_idx" ON "qa_task_links"("project_qa_id");

-- CreateIndex
CREATE INDEX "qa_task_links_test_case_id_idx" ON "qa_task_links"("test_case_id");

-- CreateIndex
CREATE INDEX "qa_task_links_test_execution_id_idx" ON "qa_task_links"("test_execution_id");

-- CreateIndex
CREATE INDEX "qa_daily_status_status_date_idx" ON "qa_daily_status"("status_date");

-- CreateIndex
CREATE INDEX "qa_daily_status_created_by_id_idx" ON "qa_daily_status"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "qa_daily_status_project_qa_id_status_date_key" ON "qa_daily_status"("project_qa_id", "status_date");

-- AddForeignKey
ALTER TABLE "project_qa" ADD CONSTRAINT "project_qa_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_qa" ADD CONSTRAINT "project_qa_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_qa" ADD CONSTRAINT "project_qa_approved_by_id_fkey" FOREIGN KEY ("approved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_test_cases" ADD CONSTRAINT "qa_test_cases_project_qa_id_fkey" FOREIGN KEY ("project_qa_id") REFERENCES "project_qa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_test_cases" ADD CONSTRAINT "qa_test_cases_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_test_steps" ADD CONSTRAINT "qa_test_steps_test_case_id_fkey" FOREIGN KEY ("test_case_id") REFERENCES "qa_test_cases"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_test_executions" ADD CONSTRAINT "qa_test_executions_project_qa_id_test_case_id_fkey" FOREIGN KEY ("project_qa_id", "test_case_id") REFERENCES "qa_test_cases"("project_qa_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "qa_test_executions" ADD CONSTRAINT "qa_test_executions_project_qa_id_fkey" FOREIGN KEY ("project_qa_id") REFERENCES "project_qa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_test_executions" ADD CONSTRAINT "qa_test_executions_executed_by_id_fkey" FOREIGN KEY ("executed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_test_executions" ADD CONSTRAINT "qa_test_executions_environment_id_fkey" FOREIGN KEY ("environment_id") REFERENCES "development_environments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_builds" ADD CONSTRAINT "qa_builds_project_qa_id_fkey" FOREIGN KEY ("project_qa_id") REFERENCES "project_qa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_builds" ADD CONSTRAINT "qa_builds_environment_id_fkey" FOREIGN KEY ("environment_id") REFERENCES "development_environments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_builds" ADD CONSTRAINT "qa_builds_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bugs" ADD CONSTRAINT "bugs_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bugs" ADD CONSTRAINT "bugs_project_id_project_qa_id_fkey" FOREIGN KEY ("project_id", "project_qa_id") REFERENCES "project_qa"("project_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "bugs" ADD CONSTRAINT "bugs_environment_id_fkey" FOREIGN KEY ("environment_id") REFERENCES "development_environments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bugs" ADD CONSTRAINT "bugs_reported_by_id_fkey" FOREIGN KEY ("reported_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bugs" ADD CONSTRAINT "bugs_assigned_to_id_fkey" FOREIGN KEY ("assigned_to_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bugs" ADD CONSTRAINT "bugs_verified_by_id_fkey" FOREIGN KEY ("verified_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bug_comments" ADD CONSTRAINT "bug_comments_bug_id_fkey" FOREIGN KEY ("bug_id") REFERENCES "bugs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bug_comments" ADD CONSTRAINT "bug_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bug_status_history" ADD CONSTRAINT "bug_status_history_bug_id_fkey" FOREIGN KEY ("bug_id") REFERENCES "bugs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bug_status_history" ADD CONSTRAINT "bug_status_history_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bug_task_links" ADD CONSTRAINT "bug_task_links_bug_id_fkey" FOREIGN KEY ("bug_id") REFERENCES "bugs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bug_task_links" ADD CONSTRAINT "bug_task_links_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bug_attachments" ADD CONSTRAINT "bug_attachments_bug_id_fkey" FOREIGN KEY ("bug_id") REFERENCES "bugs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bug_attachments" ADD CONSTRAINT "bug_attachments_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "files"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bug_attachments" ADD CONSTRAINT "bug_attachments_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_execution_bugs" ADD CONSTRAINT "qa_execution_bugs_test_execution_id_fkey" FOREIGN KEY ("test_execution_id") REFERENCES "qa_test_executions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_execution_bugs" ADD CONSTRAINT "qa_execution_bugs_bug_id_fkey" FOREIGN KEY ("bug_id") REFERENCES "bugs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_task_links" ADD CONSTRAINT "qa_task_links_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_task_links" ADD CONSTRAINT "qa_task_links_project_qa_id_fkey" FOREIGN KEY ("project_qa_id") REFERENCES "project_qa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_task_links" ADD CONSTRAINT "qa_task_links_test_case_id_fkey" FOREIGN KEY ("test_case_id") REFERENCES "qa_test_cases"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_task_links" ADD CONSTRAINT "qa_task_links_test_execution_id_fkey" FOREIGN KEY ("test_execution_id") REFERENCES "qa_test_executions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_daily_status" ADD CONSTRAINT "qa_daily_status_project_qa_id_fkey" FOREIGN KEY ("project_qa_id") REFERENCES "project_qa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "qa_daily_status" ADD CONSTRAINT "qa_daily_status_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "project_qa" ADD CONSTRAINT "project_qa_version_positive_check"
CHECK ("version_number" > 0);
ALTER TABLE "project_qa" ADD CONSTRAINT "project_qa_approval_pair_check"
CHECK (("approved_by_id" IS NULL) = ("approved_at" IS NULL));
ALTER TABLE "qa_test_steps" ADD CONSTRAINT "qa_test_steps_number_positive_check"
CHECK ("step_number" > 0);
ALTER TABLE "qa_test_executions" ADD CONSTRAINT "qa_test_executions_time_order_check"
CHECK ("started_at" IS NULL OR "completed_at" IS NULL OR "completed_at" >= "started_at");
ALTER TABLE "bugs" ADD CONSTRAINT "bugs_verification_pair_check"
CHECK (("verified_by_id" IS NULL) = ("verified_at" IS NULL));
ALTER TABLE "bug_status_history" ADD CONSTRAINT "bug_status_history_distinct_status_check"
CHECK ("from_status" IS NULL OR "from_status" <> "to_status");
ALTER TABLE "qa_daily_status" ADD CONSTRAINT "qa_daily_status_percentage_range_check"
CHECK ("completion_percentage" IS NULL OR "completion_percentage" BETWEEN 0 AND 100);

-- UUID text never equals empty string. Normalize NULL contexts without
-- reserving a real UUID or requiring PostgreSQL 15 NULLS NOT DISTINCT.
-- Prisma cannot represent expression indexes; retain this in migration SQL.
CREATE UNIQUE INDEX "qa_task_links_context_key"
ON "qa_task_links" (
    "task_id",
    COALESCE("project_qa_id"::text, ''),
    COALESCE("test_case_id"::text, ''),
    COALESCE("test_execution_id"::text, '')
);

-- Audit facts may only be appended, including initial NULL -> OPEN records.
CREATE FUNCTION "prevent_bug_status_history_mutation"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Bug status history is append-only'
    USING ERRCODE = '23514';
END;
$$;
CREATE TRIGGER "bug_status_history_append_only"
BEFORE UPDATE OR DELETE ON "bug_status_history"
FOR EACH ROW EXECUTE FUNCTION "prevent_bug_status_history_mutation"();
CREATE TRIGGER "bug_status_history_no_truncate"
BEFORE TRUNCATE ON "bug_status_history"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_bug_status_history_mutation"();

COMMIT;
