BEGIN;

-- CreateEnum
CREATE TYPE "ProjectStatus" AS ENUM ('PLANNED', 'ONGOING', 'ON_HOLD', 'COMPLETED', 'TERMINATED');

-- CreateEnum
CREATE TYPE "ProjectStatusReason" AS ENUM ('PAYMENT_PENDING', 'NO_CLIENT_RESPONSE', 'OUT_OF_SCOPE', 'CONTENT_PENDING', 'IMAGE_PENDING', 'PAYMENT_GATEWAY_PENDING', 'SMS_PENDING', 'SMTP_PENDING', 'TOO_MANY_CORRECTIONS', 'REPEATED_CORRECTIONS', 'BUDGET_EXCEEDED', 'DATE_EXCEEDED', 'MEETING_PENDING', 'APPROVAL_PENDING', 'OTHER');

-- CreateEnum
CREATE TYPE "ProjectPriority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "ProjectQualityLevel" AS ENUM ('STANDARD', 'PREMIUM', 'HIGH');

-- CreateEnum
CREATE TYPE "ProjectPlatform" AS ENUM ('WEB', 'MOBILE', 'CMS', 'ECOMMERCE', 'CUSTOM_WEB');

-- CreateEnum
CREATE TYPE "ProjectRole" AS ENUM ('PROJECT_MANAGER', 'PROJECT_COORDINATOR', 'UI_TL', 'UI_RESOURCE', 'UX_TL', 'UX_RESOURCE', 'DEV_TL', 'DEV_RESOURCE', 'QA', 'SALES', 'ACCOUNTS');

-- CreateEnum
CREATE TYPE "ProjectActionType" AS ENUM ('CLIENT_RESPONSE_REQUIRED', 'PAYMENT_FOLLOW_UP', 'CONTENT_REQUIRED', 'APPROVAL_REQUIRED', 'MEETING_REQUIRED', 'INTERNAL_ACTION', 'OTHER');

-- CreateEnum
CREATE TYPE "ProjectActionStatus" AS ENUM ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');

-- CreateTable
CREATE TABLE "projects" (
    "id" UUID NOT NULL,
    "project_code" VARCHAR(32) NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "customer_id" UUID NOT NULL,
    "proposal_id" UUID,
    "sales_person_id" UUID NOT NULL,
    "project_manager_id" UUID,
    "project_coordinator_id" UUID,
    "category_id" UUID NOT NULL,
    "quality_level" "ProjectQualityLevel",
    "platform" "ProjectPlatform",
    "page_count" INTEGER,
    "priority" "ProjectPriority" NOT NULL DEFAULT 'MEDIUM',
    "status" "ProjectStatus" NOT NULL DEFAULT 'PLANNED',
    "start_date" TIMESTAMPTZ(6),
    "planned_end_date" TIMESTAMPTZ(6),
    "actual_end_date" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "projects_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "projects" ADD CONSTRAINT "projects_page_count_nonnegative_check"
CHECK ("page_count" IS NULL OR "page_count" >= 0);

ALTER TABLE "projects" ADD CONSTRAINT "projects_date_order_check"
CHECK (
    ("start_date" IS NULL OR "planned_end_date" IS NULL OR "planned_end_date" >= "start_date")
    AND ("start_date" IS NULL OR "actual_end_date" IS NULL OR "actual_end_date" >= "start_date")
);

-- CreateTable
CREATE TABLE "project_categories" (
    "id" UUID NOT NULL,
    "parent_id" UUID,
    "name" VARCHAR(100) NOT NULL,
    "code" VARCHAR(64) NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_categories_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "project_categories" ADD CONSTRAINT "project_categories_parent_not_self_check"
CHECK ("parent_id" IS NULL OR "parent_id" <> "id");

-- CreateTable
CREATE TABLE "project_teams" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "department_id" UUID NOT NULL,
    "project_role" "ProjectRole" NOT NULL,
    "allocation_percentage" DECIMAL(5,2),
    "assigned_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "released_at" TIMESTAMPTZ(6),

    CONSTRAINT "project_teams_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "project_teams" ADD CONSTRAINT "project_teams_allocation_range_check"
CHECK (
    "allocation_percentage" IS NULL
    OR ("allocation_percentage" >= 0 AND "allocation_percentage" <= 100)
);

ALTER TABLE "project_teams" ADD CONSTRAINT "project_teams_release_date_check"
CHECK ("released_at" IS NULL OR "released_at" >= "assigned_at");

-- Release an old assignment before creating/reactivating its replacement.
CREATE UNIQUE INDEX "project_teams_one_active_assignment_per_user_key"
ON "project_teams"("project_id", "user_id") WHERE "released_at" IS NULL;

-- CreateTable
CREATE TABLE "project_status_histories" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "from_status" "ProjectStatus",
    "to_status" "ProjectStatus" NOT NULL,
    "reason" "ProjectStatusReason",
    "changed_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "project_status_histories_pkey" PRIMARY KEY ("id")
);

-- History rows are append-only; business transition logic remains in future services.
CREATE FUNCTION "prevent_project_status_history_mutation"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Project status history is append-only'
    USING ERRCODE = '23514';
END;
$$;

CREATE TRIGGER "project_status_histories_append_only"
BEFORE UPDATE OR DELETE ON "project_status_histories"
FOR EACH ROW EXECUTE FUNCTION "prevent_project_status_history_mutation"();

CREATE TRIGGER "project_status_histories_no_truncate"
BEFORE TRUNCATE ON "project_status_histories"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_project_status_history_mutation"();

-- CreateTable
CREATE TABLE "project_comments" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "comment" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_actions" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "assigned_to_id" UUID NOT NULL,
    "created_by_id" UUID NOT NULL,
    "action_type" "ProjectActionType" NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "due_date" TIMESTAMPTZ(6),
    "status" "ProjectActionStatus" NOT NULL DEFAULT 'PENDING',
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_actions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "projects_project_code_key" ON "projects"("project_code");

-- CreateIndex
CREATE INDEX "projects_customer_id_idx" ON "projects"("customer_id");

-- CreateIndex
CREATE INDEX "projects_proposal_id_idx" ON "projects"("proposal_id");

-- CreateIndex
CREATE INDEX "projects_sales_person_id_idx" ON "projects"("sales_person_id");

-- CreateIndex
CREATE INDEX "projects_project_manager_id_idx" ON "projects"("project_manager_id");

-- CreateIndex
CREATE INDEX "projects_project_coordinator_id_idx" ON "projects"("project_coordinator_id");

-- CreateIndex
CREATE INDEX "projects_category_id_idx" ON "projects"("category_id");

-- CreateIndex
CREATE INDEX "projects_status_deleted_at_idx" ON "projects"("status", "deleted_at");

-- CreateIndex
CREATE INDEX "projects_priority_deleted_at_idx" ON "projects"("priority", "deleted_at");

-- CreateIndex
CREATE INDEX "projects_planned_end_date_idx" ON "projects"("planned_end_date");

-- CreateIndex
CREATE INDEX "projects_created_at_idx" ON "projects"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "project_categories_code_key" ON "project_categories"("code");

-- CreateIndex
CREATE INDEX "project_categories_parent_id_is_active_idx" ON "project_categories"("parent_id", "is_active");

-- CreateIndex
CREATE INDEX "project_teams_project_id_released_at_idx" ON "project_teams"("project_id", "released_at");

-- CreateIndex
CREATE INDEX "project_teams_user_id_released_at_idx" ON "project_teams"("user_id", "released_at");

-- CreateIndex
CREATE INDEX "project_teams_department_id_idx" ON "project_teams"("department_id");

-- CreateIndex
CREATE INDEX "project_teams_project_role_idx" ON "project_teams"("project_role");

-- CreateIndex
CREATE INDEX "project_status_histories_project_id_created_at_idx" ON "project_status_histories"("project_id", "created_at");

-- CreateIndex
CREATE INDEX "project_status_histories_changed_by_id_idx" ON "project_status_histories"("changed_by_id");

-- CreateIndex
CREATE INDEX "project_status_histories_created_at_idx" ON "project_status_histories"("created_at");

-- CreateIndex
CREATE INDEX "project_comments_project_id_created_at_idx" ON "project_comments"("project_id", "created_at");

-- CreateIndex
CREATE INDEX "project_comments_user_id_idx" ON "project_comments"("user_id");

-- CreateIndex
CREATE INDEX "project_comments_created_at_idx" ON "project_comments"("created_at");

-- CreateIndex
CREATE INDEX "project_actions_project_id_status_idx" ON "project_actions"("project_id", "status");

-- CreateIndex
CREATE INDEX "project_actions_assigned_to_id_status_due_date_idx" ON "project_actions"("assigned_to_id", "status", "due_date");

-- CreateIndex
CREATE INDEX "project_actions_created_by_id_idx" ON "project_actions"("created_by_id");

-- CreateIndex
CREATE INDEX "project_actions_status_due_date_idx" ON "project_actions"("status", "due_date");

-- CreateIndex
CREATE INDEX "project_actions_due_date_idx" ON "project_actions"("due_date");

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_proposal_id_fkey" FOREIGN KEY ("proposal_id") REFERENCES "proposals"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_sales_person_id_fkey" FOREIGN KEY ("sales_person_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_project_manager_id_fkey" FOREIGN KEY ("project_manager_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_project_coordinator_id_fkey" FOREIGN KEY ("project_coordinator_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "project_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_categories" ADD CONSTRAINT "project_categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "project_categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_teams" ADD CONSTRAINT "project_teams_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_teams" ADD CONSTRAINT "project_teams_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_teams" ADD CONSTRAINT "project_teams_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_status_histories" ADD CONSTRAINT "project_status_histories_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_status_histories" ADD CONSTRAINT "project_status_histories_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_comments" ADD CONSTRAINT "project_comments_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_comments" ADD CONSTRAINT "project_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_actions" ADD CONSTRAINT "project_actions_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_actions" ADD CONSTRAINT "project_actions_assigned_to_id_fkey" FOREIGN KEY ("assigned_to_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_actions" ADD CONSTRAINT "project_actions_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

COMMIT;
