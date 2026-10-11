BEGIN;

-- CreateEnum
CREATE TYPE "SprintStatus" AS ENUM ('PLANNED', 'ACTIVE', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "DevelopmentStatus" AS ENUM ('DRAFT', 'PLANNING', 'IN_PROGRESS', 'IN_REVIEW', 'READY_FOR_QA', 'REWORK', 'COMPLETED', 'ON_HOLD', 'CANCELLED');

-- CreateEnum
CREATE TYPE "DevelopmentModuleType" AS ENUM ('FEATURE', 'MODULE', 'API', 'INTEGRATION', 'DATABASE', 'AUTHENTICATION', 'ADMIN', 'FRONTEND', 'BACKEND', 'OTHER');

-- CreateEnum
CREATE TYPE "DevelopmentModuleStatus" AS ENUM ('PLANNED', 'IN_PROGRESS', 'IN_REVIEW', 'COMPLETED', 'BLOCKED', 'REWORK', 'CANCELLED');

-- CreateEnum
CREATE TYPE "RepositoryProvider" AS ENUM ('GITHUB', 'GITLAB', 'BITBUCKET', 'OTHER');

-- CreateEnum
CREATE TYPE "RepositoryType" AS ENUM ('FRONTEND', 'BACKEND', 'MOBILE', 'INFRASTRUCTURE', 'MONOREPO', 'OTHER');

-- CreateEnum
CREATE TYPE "DevelopmentEnvironmentType" AS ENUM ('LOCAL', 'DEVELOPMENT', 'STAGING', 'UAT', 'PRODUCTION', 'OTHER');

-- CreateEnum
CREATE TYPE "DeploymentStatus" AS ENUM ('PENDING', 'IN_PROGRESS', 'SUCCESS', 'FAILED', 'ROLLED_BACK', 'CANCELLED');

-- CreateEnum
CREATE TYPE "DevelopmentDailyStatus" AS ENUM ('NOT_STARTED', 'IN_PROGRESS', 'BLOCKED', 'READY_FOR_QA', 'COMPLETED', 'ON_HOLD');

-- AlterTable
ALTER TABLE "tasks" ADD COLUMN     "sprint_id" UUID;

-- CreateTable
CREATE TABLE "sprints" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "project_development_id" UUID,
    "name" VARCHAR(255) NOT NULL,
    "code" VARCHAR(64) NOT NULL,
    "workstream" "TaskWorkstream" NOT NULL,
    "goal" TEXT,
    "description" TEXT,
    "status" "SprintStatus" NOT NULL DEFAULT 'PLANNED',
    "start_date" TIMESTAMPTZ(6),
    "end_date" TIMESTAMPTZ(6),
    "created_by_id" UUID NOT NULL,
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "sprints_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_development" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "version_number" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "status" "DevelopmentStatus" NOT NULL DEFAULT 'DRAFT',
    "development_summary" TEXT,
    "technical_notes" TEXT,
    "created_by_id" UUID NOT NULL,
    "approved_by_id" UUID,
    "approved_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_development_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "development_modules" (
    "id" UUID NOT NULL,
    "project_development_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "code" VARCHAR(64) NOT NULL,
    "description" TEXT,
    "module_type" "DevelopmentModuleType" NOT NULL DEFAULT 'OTHER',
    "status" "DevelopmentModuleStatus" NOT NULL DEFAULT 'PLANNED',
    "priority" "ProjectPriority" NOT NULL DEFAULT 'MEDIUM',
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "development_modules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "development_task_links" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "project_development_id" UUID NOT NULL,
    "development_module_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "development_task_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "development_repositories" (
    "id" UUID NOT NULL,
    "project_development_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "repository_url" VARCHAR(2048) NOT NULL,
    "provider" "RepositoryProvider" NOT NULL DEFAULT 'OTHER',
    "repository_type" "RepositoryType" NOT NULL DEFAULT 'OTHER',
    "default_branch" VARCHAR(255),
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "development_repositories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "development_environments" (
    "id" UUID NOT NULL,
    "project_development_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "environment_type" "DevelopmentEnvironmentType" NOT NULL DEFAULT 'OTHER',
    "base_url" VARCHAR(2048),
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "development_environments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "development_deployments" (
    "id" UUID NOT NULL,
    "project_development_id" UUID NOT NULL,
    "environment_id" UUID NOT NULL,
    "deployed_by_id" UUID NOT NULL,
    "version" VARCHAR(100) NOT NULL,
    "commit_hash" VARCHAR(128),
    "deployment_status" "DeploymentStatus" NOT NULL DEFAULT 'PENDING',
    "deployment_url" VARCHAR(2048),
    "notes" TEXT,
    "deployed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "development_deployments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "development_daily_status" (
    "id" UUID NOT NULL,
    "project_development_id" UUID NOT NULL,
    "status_date" DATE NOT NULL,
    "status" "DevelopmentDailyStatus" NOT NULL DEFAULT 'NOT_STARTED',
    "summary" TEXT NOT NULL,
    "completed_work" TEXT,
    "planned_work" TEXT,
    "blockers" TEXT,
    "risks" TEXT,
    "completion_percentage" INTEGER,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "development_daily_status_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "sprints_project_development_id_idx" ON "sprints"("project_development_id");

-- CreateIndex
CREATE INDEX "sprints_workstream_idx" ON "sprints"("workstream");

-- CreateIndex
CREATE INDEX "sprints_status_idx" ON "sprints"("status");

-- CreateIndex
CREATE INDEX "sprints_start_date_idx" ON "sprints"("start_date");

-- CreateIndex
CREATE INDEX "sprints_end_date_idx" ON "sprints"("end_date");

-- CreateIndex
CREATE INDEX "sprints_created_by_id_idx" ON "sprints"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "sprints_project_id_code_key" ON "sprints"("project_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "sprints_project_id_id_key" ON "sprints"("project_id", "id");

-- CreateIndex
CREATE INDEX "project_development_status_created_at_idx" ON "project_development"("status", "created_at");

-- CreateIndex
CREATE INDEX "project_development_created_at_idx" ON "project_development"("created_at");

-- CreateIndex
CREATE INDEX "project_development_created_by_id_idx" ON "project_development"("created_by_id");

-- CreateIndex
CREATE INDEX "project_development_approved_by_id_idx" ON "project_development"("approved_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_development_project_id_version_number_key" ON "project_development"("project_id", "version_number");

-- CreateIndex
CREATE UNIQUE INDEX "project_development_project_id_id_key" ON "project_development"("project_id", "id");

-- CreateIndex
CREATE INDEX "development_modules_project_development_id_sort_order_idx" ON "development_modules"("project_development_id", "sort_order");

-- CreateIndex
CREATE INDEX "development_modules_status_idx" ON "development_modules"("status");

-- CreateIndex
CREATE INDEX "development_modules_module_type_idx" ON "development_modules"("module_type");

-- CreateIndex
CREATE INDEX "development_modules_priority_idx" ON "development_modules"("priority");

-- CreateIndex
CREATE INDEX "development_modules_created_by_id_idx" ON "development_modules"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "development_modules_project_development_id_code_key" ON "development_modules"("project_development_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "development_modules_project_development_id_id_key" ON "development_modules"("project_development_id", "id");

-- CreateIndex
CREATE INDEX "development_task_links_project_development_id_idx" ON "development_task_links"("project_development_id");

-- CreateIndex
CREATE INDEX "development_task_links_development_module_id_idx" ON "development_task_links"("development_module_id");

-- CreateIndex
CREATE UNIQUE INDEX "development_task_links_task_id_project_development_id_devel_key" ON "development_task_links"("task_id", "project_development_id", "development_module_id");

-- CreateIndex
CREATE INDEX "development_repositories_project_development_id_is_active_idx" ON "development_repositories"("project_development_id", "is_active");

-- CreateIndex
CREATE INDEX "development_repositories_provider_idx" ON "development_repositories"("provider");

-- CreateIndex
CREATE INDEX "development_repositories_created_by_id_idx" ON "development_repositories"("created_by_id");

-- CreateIndex
CREATE INDEX "development_environments_project_development_id_is_active_idx" ON "development_environments"("project_development_id", "is_active");

-- CreateIndex
CREATE INDEX "development_environments_environment_type_idx" ON "development_environments"("environment_type");

-- CreateIndex
CREATE UNIQUE INDEX "development_environments_project_development_id_id_key" ON "development_environments"("project_development_id", "id");

-- CreateIndex
CREATE INDEX "development_deployments_project_development_id_idx" ON "development_deployments"("project_development_id");

-- CreateIndex
CREATE INDEX "development_deployments_environment_id_idx" ON "development_deployments"("environment_id");

-- CreateIndex
CREATE INDEX "development_deployments_deployment_status_idx" ON "development_deployments"("deployment_status");

-- CreateIndex
CREATE INDEX "development_deployments_deployed_at_idx" ON "development_deployments"("deployed_at");

-- CreateIndex
CREATE INDEX "development_deployments_deployed_by_id_idx" ON "development_deployments"("deployed_by_id");

-- CreateIndex
CREATE INDEX "development_daily_status_status_date_idx" ON "development_daily_status"("status_date");

-- CreateIndex
CREATE INDEX "development_daily_status_created_by_id_idx" ON "development_daily_status"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "development_daily_status_project_development_id_status_date_key" ON "development_daily_status"("project_development_id", "status_date");

-- CreateIndex
CREATE INDEX "tasks_sprint_id_idx" ON "tasks"("sprint_id");

-- AddForeignKey
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_project_id_sprint_id_fkey" FOREIGN KEY ("project_id", "sprint_id") REFERENCES "sprints"("project_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "sprints" ADD CONSTRAINT "sprints_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sprints" ADD CONSTRAINT "sprints_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sprints" ADD CONSTRAINT "sprints_project_id_project_development_id_fkey" FOREIGN KEY ("project_id", "project_development_id") REFERENCES "project_development"("project_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "project_development" ADD CONSTRAINT "project_development_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_development" ADD CONSTRAINT "project_development_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_development" ADD CONSTRAINT "project_development_approved_by_id_fkey" FOREIGN KEY ("approved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_modules" ADD CONSTRAINT "development_modules_project_development_id_fkey" FOREIGN KEY ("project_development_id") REFERENCES "project_development"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_modules" ADD CONSTRAINT "development_modules_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_task_links" ADD CONSTRAINT "development_task_links_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_task_links" ADD CONSTRAINT "development_task_links_project_development_id_fkey" FOREIGN KEY ("project_development_id") REFERENCES "project_development"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_task_links" ADD CONSTRAINT "development_task_links_project_development_id_development__fkey" FOREIGN KEY ("project_development_id", "development_module_id") REFERENCES "development_modules"("project_development_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "development_repositories" ADD CONSTRAINT "development_repositories_project_development_id_fkey" FOREIGN KEY ("project_development_id") REFERENCES "project_development"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_repositories" ADD CONSTRAINT "development_repositories_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_environments" ADD CONSTRAINT "development_environments_project_development_id_fkey" FOREIGN KEY ("project_development_id") REFERENCES "project_development"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_deployments" ADD CONSTRAINT "development_deployments_project_development_id_fkey" FOREIGN KEY ("project_development_id") REFERENCES "project_development"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_deployments" ADD CONSTRAINT "development_deployments_project_development_id_environment_fkey" FOREIGN KEY ("project_development_id", "environment_id") REFERENCES "development_environments"("project_development_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "development_deployments" ADD CONSTRAINT "development_deployments_deployed_by_id_fkey" FOREIGN KEY ("deployed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_daily_status" ADD CONSTRAINT "development_daily_status_project_development_id_fkey" FOREIGN KEY ("project_development_id") REFERENCES "project_development"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "development_daily_status" ADD CONSTRAINT "development_daily_status_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Domain checks and nullable-link uniqueness follow existing migrations.
ALTER TABLE "sprints" ADD CONSTRAINT "sprints_date_order_check"
CHECK ("start_date" IS NULL OR "end_date" IS NULL OR "end_date" >= "start_date");

ALTER TABLE "sprints" ADD CONSTRAINT "sprints_development_context_check"
CHECK ("project_development_id" IS NULL OR "workstream" = 'DEVELOPMENT');

ALTER TABLE "project_development" ADD CONSTRAINT "project_development_version_positive_check"
CHECK ("version_number" > 0);

ALTER TABLE "project_development" ADD CONSTRAINT "project_development_approval_pair_check"
CHECK (("approved_by_id" IS NULL) = ("approved_at" IS NULL));

ALTER TABLE "development_modules" ADD CONSTRAINT "development_modules_sort_order_nonnegative_check"
CHECK ("sort_order" >= 0);

ALTER TABLE "development_daily_status" ADD CONSTRAINT "development_daily_status_percentage_range_check"
CHECK ("completion_percentage" IS NULL OR "completion_percentage" BETWEEN 0 AND 100);

CREATE UNIQUE INDEX "development_task_links_version_only_key"
ON "development_task_links" ("task_id", "project_development_id")
WHERE "development_module_id" IS NULL;

COMMIT;
