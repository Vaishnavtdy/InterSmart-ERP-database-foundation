BEGIN;

-- CreateEnum
CREATE TYPE "UxStatus" AS ENUM ('DRAFT', 'IN_PROGRESS', 'IN_REVIEW', 'APPROVED', 'REWORK', 'COMPLETED', 'ON_HOLD', 'CANCELLED');

-- CreateEnum
CREATE TYPE "UxScreenType" AS ENUM ('PUBLIC', 'AUTHENTICATION', 'DASHBOARD', 'ADMIN', 'CONTENT', 'E_COMMERCE', 'FORM', 'CHECKOUT', 'PROFILE', 'SYSTEM', 'OTHER');

-- CreateEnum
CREATE TYPE "UxScreenStatus" AS ENUM ('PLANNED', 'IN_DESIGN', 'IN_REVIEW', 'APPROVED', 'REWORK', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "UxFlowType" AS ENUM ('USER_REGISTRATION', 'LOGIN', 'ONBOARDING', 'PURCHASE', 'CHECKOUT', 'BOOKING', 'CONTACT', 'ADMIN', 'CONTENT_MANAGEMENT', 'PROFILE', 'OTHER');

-- CreateEnum
CREATE TYPE "UxFlowStatus" AS ENUM ('DRAFT', 'IN_PROGRESS', 'IN_REVIEW', 'APPROVED', 'REWORK', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "UxDesignLinkType" AS ENUM ('FIGMA', 'PROTOTYPE', 'WIREFRAME', 'USER_FLOW', 'DESIGN_SYSTEM', 'REFERENCE', 'OTHER');

-- CreateEnum
CREATE TYPE "UxDailyStatusType" AS ENUM ('NOT_STARTED', 'IN_PROGRESS', 'BLOCKED', 'COMPLETED', 'ON_HOLD');

-- CreateTable
CREATE TABLE "project_ux" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "version_number" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "status" "UxStatus" NOT NULL DEFAULT 'DRAFT',
    "research_summary" TEXT,
    "user_personas" TEXT,
    "user_journey_summary" TEXT,
    "created_by_id" UUID NOT NULL,
    "approved_by_id" UUID,
    "approved_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_ux_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ux_screens" (
    "id" UUID NOT NULL,
    "project_ux_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "screen_type" "UxScreenType" NOT NULL DEFAULT 'OTHER',
    "route" VARCHAR(2048),
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "status" "UxScreenStatus" NOT NULL DEFAULT 'PLANNED',
    "is_required" BOOLEAN NOT NULL DEFAULT true,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "ux_screens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ux_flows" (
    "id" UUID NOT NULL,
    "project_ux_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "flow_type" "UxFlowType" NOT NULL DEFAULT 'OTHER',
    "status" "UxFlowStatus" NOT NULL DEFAULT 'DRAFT',
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "ux_flows_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ux_flow_steps" (
    "id" UUID NOT NULL,
    "ux_flow_id" UUID NOT NULL,
    "step_number" INTEGER NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "screen_id" UUID,
    "action" TEXT,
    "expected_result" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "ux_flow_steps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ux_task_links" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "project_ux_id" UUID NOT NULL,
    "ux_screen_id" UUID,
    "ux_flow_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ux_task_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ux_daily_status" (
    "id" UUID NOT NULL,
    "project_ux_id" UUID NOT NULL,
    "status_date" DATE NOT NULL,
    "status" "UxDailyStatusType" NOT NULL DEFAULT 'NOT_STARTED',
    "summary" TEXT NOT NULL,
    "completed_work" TEXT,
    "planned_work" TEXT,
    "blockers" TEXT,
    "completion_percentage" INTEGER,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "ux_daily_status_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ux_design_links" (
    "id" UUID NOT NULL,
    "project_ux_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "url" VARCHAR(2048) NOT NULL,
    "link_type" "UxDesignLinkType" NOT NULL DEFAULT 'OTHER',
    "description" TEXT,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "ux_design_links_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "project_ux_status_created_at_idx" ON "project_ux"("status", "created_at");

-- CreateIndex
CREATE INDEX "project_ux_created_at_idx" ON "project_ux"("created_at");

-- CreateIndex
CREATE INDEX "project_ux_created_by_id_idx" ON "project_ux"("created_by_id");

-- CreateIndex
CREATE INDEX "project_ux_approved_by_id_idx" ON "project_ux"("approved_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_ux_project_id_version_number_key" ON "project_ux"("project_id", "version_number");

-- CreateIndex
CREATE INDEX "ux_screens_project_ux_id_sort_order_idx" ON "ux_screens"("project_ux_id", "sort_order");

-- CreateIndex
CREATE INDEX "ux_screens_status_idx" ON "ux_screens"("status");

-- CreateIndex
CREATE INDEX "ux_screens_screen_type_idx" ON "ux_screens"("screen_type");

-- CreateIndex
CREATE INDEX "ux_screens_created_by_id_idx" ON "ux_screens"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "ux_screens_project_ux_id_id_key" ON "ux_screens"("project_ux_id", "id");

-- CreateIndex
CREATE INDEX "ux_flows_project_ux_id_sort_order_idx" ON "ux_flows"("project_ux_id", "sort_order");

-- CreateIndex
CREATE INDEX "ux_flows_status_idx" ON "ux_flows"("status");

-- CreateIndex
CREATE INDEX "ux_flows_flow_type_idx" ON "ux_flows"("flow_type");

-- CreateIndex
CREATE INDEX "ux_flows_created_by_id_idx" ON "ux_flows"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "ux_flows_project_ux_id_id_key" ON "ux_flows"("project_ux_id", "id");

-- CreateIndex
CREATE INDEX "ux_flow_steps_screen_id_idx" ON "ux_flow_steps"("screen_id");

-- CreateIndex
CREATE UNIQUE INDEX "ux_flow_steps_ux_flow_id_step_number_key" ON "ux_flow_steps"("ux_flow_id", "step_number");

-- CreateIndex
CREATE INDEX "ux_task_links_project_ux_id_idx" ON "ux_task_links"("project_ux_id");

-- CreateIndex
CREATE INDEX "ux_task_links_ux_screen_id_idx" ON "ux_task_links"("ux_screen_id");

-- CreateIndex
CREATE INDEX "ux_task_links_ux_flow_id_idx" ON "ux_task_links"("ux_flow_id");

-- CreateIndex
CREATE UNIQUE INDEX "ux_task_links_task_id_project_ux_id_ux_screen_id_ux_flow_id_key" ON "ux_task_links"("task_id", "project_ux_id", "ux_screen_id", "ux_flow_id");

-- CreateIndex
CREATE INDEX "ux_daily_status_status_date_idx" ON "ux_daily_status"("status_date");

-- CreateIndex
CREATE INDEX "ux_daily_status_created_by_id_idx" ON "ux_daily_status"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "ux_daily_status_project_ux_id_status_date_key" ON "ux_daily_status"("project_ux_id", "status_date");

-- CreateIndex
CREATE INDEX "ux_design_links_project_ux_id_link_type_idx" ON "ux_design_links"("project_ux_id", "link_type");

-- CreateIndex
CREATE INDEX "ux_design_links_created_at_idx" ON "ux_design_links"("created_at");

-- CreateIndex
CREATE INDEX "ux_design_links_created_by_id_idx" ON "ux_design_links"("created_by_id");

-- AddForeignKey
ALTER TABLE "project_ux" ADD CONSTRAINT "project_ux_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_ux" ADD CONSTRAINT "project_ux_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_ux" ADD CONSTRAINT "project_ux_approved_by_id_fkey" FOREIGN KEY ("approved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_screens" ADD CONSTRAINT "ux_screens_project_ux_id_fkey" FOREIGN KEY ("project_ux_id") REFERENCES "project_ux"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_screens" ADD CONSTRAINT "ux_screens_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_flows" ADD CONSTRAINT "ux_flows_project_ux_id_fkey" FOREIGN KEY ("project_ux_id") REFERENCES "project_ux"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_flows" ADD CONSTRAINT "ux_flows_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_flow_steps" ADD CONSTRAINT "ux_flow_steps_ux_flow_id_fkey" FOREIGN KEY ("ux_flow_id") REFERENCES "ux_flows"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_flow_steps" ADD CONSTRAINT "ux_flow_steps_screen_id_fkey" FOREIGN KEY ("screen_id") REFERENCES "ux_screens"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_task_links" ADD CONSTRAINT "ux_task_links_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_task_links" ADD CONSTRAINT "ux_task_links_project_ux_id_fkey" FOREIGN KEY ("project_ux_id") REFERENCES "project_ux"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_task_links" ADD CONSTRAINT "ux_task_links_project_ux_id_ux_screen_id_fkey" FOREIGN KEY ("project_ux_id", "ux_screen_id") REFERENCES "ux_screens"("project_ux_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ux_task_links" ADD CONSTRAINT "ux_task_links_project_ux_id_ux_flow_id_fkey" FOREIGN KEY ("project_ux_id", "ux_flow_id") REFERENCES "ux_flows"("project_ux_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ux_daily_status" ADD CONSTRAINT "ux_daily_status_project_ux_id_fkey" FOREIGN KEY ("project_ux_id") REFERENCES "project_ux"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_daily_status" ADD CONSTRAINT "ux_daily_status_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_design_links" ADD CONSTRAINT "ux_design_links_project_ux_id_fkey" FOREIGN KEY ("project_ux_id") REFERENCES "project_ux"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ux_design_links" ADD CONSTRAINT "ux_design_links_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Simple domain checks follow the existing UI/scope/task architecture.
ALTER TABLE "project_ux" ADD CONSTRAINT "project_ux_version_positive_check"
CHECK ("version_number" > 0);

ALTER TABLE "project_ux" ADD CONSTRAINT "project_ux_approval_pair_check"
CHECK (("approved_by_id" IS NULL) = ("approved_at" IS NULL));

ALTER TABLE "ux_screens" ADD CONSTRAINT "ux_screens_sort_order_nonnegative_check"
CHECK ("sort_order" >= 0);

ALTER TABLE "ux_flows" ADD CONSTRAINT "ux_flows_sort_order_nonnegative_check"
CHECK ("sort_order" >= 0);

ALTER TABLE "ux_flow_steps" ADD CONSTRAINT "ux_flow_steps_step_number_positive_check"
CHECK ("step_number" > 0);

ALTER TABLE "ux_daily_status" ADD CONSTRAINT "ux_daily_status_percentage_range_check"
CHECK ("completion_percentage" IS NULL OR "completion_percentage" BETWEEN 0 AND 100);

ALTER TABLE "ux_task_links" ADD CONSTRAINT "ux_task_links_context_required_check"
CHECK ("ux_screen_id" IS NOT NULL OR "ux_flow_id" IS NOT NULL);

-- Normal nullable uniqueness covers both-context links; partial keys cover
-- screen-only and flow-only links without modifying the common task table.
CREATE UNIQUE INDEX "ux_task_links_screen_only_key"
ON "ux_task_links" ("task_id", "project_ux_id", "ux_screen_id")
WHERE "ux_flow_id" IS NULL;

CREATE UNIQUE INDEX "ux_task_links_flow_only_key"
ON "ux_task_links" ("task_id", "project_ux_id", "ux_flow_id")
WHERE "ux_screen_id" IS NULL;

COMMIT;
