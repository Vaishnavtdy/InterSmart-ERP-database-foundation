BEGIN;

-- CreateEnum
CREATE TYPE "ApprovalRequestStatus" AS ENUM ('DRAFT', 'PENDING', 'APPROVED', 'REJECTED', 'RETURNED', 'CANCELLED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "ApprovalPriority" AS ENUM ('LOW', 'NORMAL', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "ApprovalApproverType" AS ENUM ('USER', 'ROLE', 'DEPARTMENT', 'MANAGER');

-- CreateEnum
CREATE TYPE "ApprovalStepStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'RETURNED', 'SKIPPED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ApprovalAction" AS ENUM ('SUBMITTED', 'APPROVED', 'REJECTED', 'RETURNED', 'SKIPPED', 'CANCELLED', 'REASSIGNED');

-- AlterEnum
ALTER TYPE "NumberSequenceEntityType" ADD VALUE 'APPROVAL_REQUEST';

-- CreateTable
CREATE TABLE "roles" (
    "id" UUID NOT NULL,
    "code" VARCHAR(64) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" UUID NOT NULL,
    "code" VARCHAR(128) NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_roles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "id" UUID NOT NULL,
    "role_id" UUID NOT NULL,
    "permission_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_requests" (
    "id" UUID NOT NULL,
    "request_code" VARCHAR(32) NOT NULL,
    "request_type" VARCHAR(64) NOT NULL,
    "entity_type" VARCHAR(64) NOT NULL,
    "entity_id" UUID NOT NULL,
    "requested_by_id" UUID NOT NULL,
    "status" "ApprovalRequestStatus" NOT NULL DEFAULT 'DRAFT',
    "priority" "ApprovalPriority" NOT NULL DEFAULT 'NORMAL',
    "reason" TEXT,
    "due_at" TIMESTAMPTZ(6),
    "current_step_order" INTEGER,
    "completed_at" TIMESTAMPTZ(6),
    "cancelled_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "approval_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_steps" (
    "id" UUID NOT NULL,
    "approval_request_id" UUID NOT NULL,
    "step_order" INTEGER NOT NULL,
    "approver_type" "ApprovalApproverType" NOT NULL,
    "approver_user_id" UUID,
    "approver_role_id" UUID,
    "approver_department_id" UUID,
    "status" "ApprovalStepStatus" NOT NULL DEFAULT 'PENDING',
    "acted_by_id" UUID,
    "acted_at" TIMESTAMPTZ(6),
    "due_at" TIMESTAMPTZ(6),
    "comments" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "approval_steps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_history" (
    "id" UUID NOT NULL,
    "approval_request_id" UUID NOT NULL,
    "approval_step_id" UUID,
    "action" "ApprovalAction" NOT NULL,
    "acted_by_id" UUID,
    "comments" TEXT,
    "metadata" JSONB,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "approval_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "approval_request_comments" (
    "id" UUID NOT NULL,
    "approval_request_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "comment" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "approval_request_comments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "roles_code_key" ON "roles"("code");

-- CreateIndex
CREATE INDEX "roles_is_active_idx" ON "roles"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "permissions_code_key" ON "permissions"("code");

-- CreateIndex
CREATE INDEX "user_roles_role_id_idx" ON "user_roles"("role_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_roles_user_id_role_id_key" ON "user_roles"("user_id", "role_id");

-- CreateIndex
CREATE INDEX "role_permissions_permission_id_idx" ON "role_permissions"("permission_id");

-- CreateIndex
CREATE UNIQUE INDEX "role_permissions_role_id_permission_id_key" ON "role_permissions"("role_id", "permission_id");

-- CreateIndex
CREATE UNIQUE INDEX "approval_requests_request_code_key" ON "approval_requests"("request_code");

-- CreateIndex
CREATE INDEX "approval_requests_request_type_idx" ON "approval_requests"("request_type");

-- CreateIndex
CREATE INDEX "approval_requests_entity_type_entity_id_idx" ON "approval_requests"("entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "approval_requests_requested_by_id_created_at_idx" ON "approval_requests"("requested_by_id", "created_at");

-- CreateIndex
CREATE INDEX "approval_requests_status_due_at_idx" ON "approval_requests"("status", "due_at");

-- CreateIndex
CREATE INDEX "approval_requests_due_at_idx" ON "approval_requests"("due_at");

-- CreateIndex
CREATE INDEX "approval_steps_approval_request_id_step_order_idx" ON "approval_steps"("approval_request_id", "step_order");

-- CreateIndex
CREATE INDEX "approval_steps_approver_user_id_status_idx" ON "approval_steps"("approver_user_id", "status");

-- CreateIndex
CREATE INDEX "approval_steps_approver_role_id_status_idx" ON "approval_steps"("approver_role_id", "status");

-- CreateIndex
CREATE INDEX "approval_steps_approver_department_id_status_idx" ON "approval_steps"("approver_department_id", "status");

-- CreateIndex
CREATE INDEX "approval_steps_status_due_at_idx" ON "approval_steps"("status", "due_at");

-- CreateIndex
CREATE INDEX "approval_steps_acted_by_id_idx" ON "approval_steps"("acted_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "approval_steps_approval_request_id_id_key" ON "approval_steps"("approval_request_id", "id");

-- CreateIndex
CREATE INDEX "approval_history_approval_request_id_created_at_idx" ON "approval_history"("approval_request_id", "created_at");

-- CreateIndex
CREATE INDEX "approval_history_approval_step_id_idx" ON "approval_history"("approval_step_id");

-- CreateIndex
CREATE INDEX "approval_history_acted_by_id_idx" ON "approval_history"("acted_by_id");

-- CreateIndex
CREATE INDEX "approval_history_created_at_idx" ON "approval_history"("created_at");

-- CreateIndex
CREATE INDEX "approval_request_comments_approval_request_id_created_at_idx" ON "approval_request_comments"("approval_request_id", "created_at");

-- CreateIndex
CREATE INDEX "approval_request_comments_user_id_idx" ON "approval_request_comments"("user_id");

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_requested_by_id_fkey" FOREIGN KEY ("requested_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_approver_user_id_fkey" FOREIGN KEY ("approver_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_approver_role_id_fkey" FOREIGN KEY ("approver_role_id") REFERENCES "roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_approver_department_id_fkey" FOREIGN KEY ("approver_department_id") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_acted_by_id_fkey" FOREIGN KEY ("acted_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_history" ADD CONSTRAINT "approval_history_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_history" ADD CONSTRAINT "approval_history_approval_request_id_approval_step_id_fkey" FOREIGN KEY ("approval_request_id", "approval_step_id") REFERENCES "approval_steps"("approval_request_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "approval_history" ADD CONSTRAINT "approval_history_acted_by_id_fkey" FOREIGN KEY ("acted_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_request_comments" ADD CONSTRAINT "approval_request_comments_approval_request_id_fkey" FOREIGN KEY ("approval_request_id") REFERENCES "approval_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "approval_request_comments" ADD CONSTRAINT "approval_request_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Minimal approved RBAC catalog, not an authorization implementation.
ALTER TABLE "roles" ADD CONSTRAINT "roles_code_check"
CHECK ("code" ~ '^[A-Z][A-Z0-9_]{0,63}$');
ALTER TABLE "roles" ADD CONSTRAINT "roles_name_check"
CHECK (length(btrim("name")) > 0 AND "name" = btrim("name"));
ALTER TABLE "permissions" ADD CONSTRAINT "permissions_code_check"
CHECK ("code" ~ '^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$');
ALTER TABLE "permissions" ADD CONSTRAINT "permissions_name_check"
CHECK (length(btrim("name")) > 0 AND "name" = btrim("name"));

ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_code_check"
CHECK (length(btrim("request_code")) > 0 AND "request_code" = btrim("request_code"));
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_type_check"
CHECK (length(btrim("request_type")) > 0 AND "request_type" = btrim("request_type")
   AND length(btrim("entity_type")) > 0 AND "entity_type" = btrim("entity_type"));
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_current_order_check"
CHECK ("current_step_order" IS NULL OR "current_step_order" > 0);
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_completion_time_check"
CHECK ("completed_at" IS NULL OR "completed_at" >= "created_at");
ALTER TABLE "approval_requests" ADD CONSTRAINT "approval_requests_cancellation_time_check"
CHECK ("cancelled_at" IS NULL OR "cancelled_at" >= "created_at");

ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_order_check"
CHECK ("step_order" > 0);
ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_target_check"
CHECK (
  ("approver_type" = 'USER' AND "approver_user_id" IS NOT NULL
    AND "approver_role_id" IS NULL AND "approver_department_id" IS NULL)
  OR ("approver_type" = 'ROLE' AND "approver_role_id" IS NOT NULL
    AND "approver_user_id" IS NULL AND "approver_department_id" IS NULL)
  OR ("approver_type" = 'DEPARTMENT' AND "approver_department_id" IS NOT NULL
    AND "approver_user_id" IS NULL AND "approver_role_id" IS NULL)
  OR ("approver_type" = 'MANAGER' AND "approver_user_id" IS NULL
    AND "approver_role_id" IS NULL AND "approver_department_id" IS NULL)
);
ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_actor_time_check"
CHECK ("acted_by_id" IS NULL OR "acted_at" IS NOT NULL);
ALTER TABLE "approval_steps" ADD CONSTRAINT "approval_steps_action_time_check"
CHECK ("acted_at" IS NULL OR "acted_at" >= "created_at");

-- Request/order cannot be unique: distinct approvers at one order are parallel.
-- A target appears at most once within its request/order; it can appear again
-- at another order or request. MANAGER has one unresolved slot per group.
CREATE UNIQUE INDEX "approval_steps_user_target_key"
ON "approval_steps" ("approval_request_id", "step_order", "approver_user_id")
WHERE "approver_type" = 'USER';
CREATE UNIQUE INDEX "approval_steps_role_target_key"
ON "approval_steps" ("approval_request_id", "step_order", "approver_role_id")
WHERE "approver_type" = 'ROLE';
CREATE UNIQUE INDEX "approval_steps_department_target_key"
ON "approval_steps" ("approval_request_id", "step_order", "approver_department_id")
WHERE "approver_type" = 'DEPARTMENT';
CREATE UNIQUE INDEX "approval_steps_manager_target_key"
ON "approval_steps" ("approval_request_id", "step_order")
WHERE "approver_type" = 'MANAGER';

-- Small contextual JSON only. Object/size checks are NOT secret sanitizers.
ALTER TABLE "approval_history" ADD CONSTRAINT "approval_history_metadata_check"
CHECK ("metadata" IS NULL OR
  (jsonb_typeof("metadata") = 'object' AND octet_length("metadata"::text) <= 8192));
ALTER TABLE "approval_request_comments" ADD CONSTRAINT "approval_request_comments_content_check"
CHECK (length(btrim("comment")) > 0);

-- Evidence protection only; these triggers never advance or resolve workflows.
CREATE FUNCTION "prevent_approval_history_mutation"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'Approval history is append-only' USING ERRCODE = '23514';
END;
$$;
CREATE TRIGGER "approval_history_append_only"
BEFORE UPDATE OR DELETE ON "approval_history"
FOR EACH ROW EXECUTE FUNCTION "prevent_approval_history_mutation"();
CREATE TRIGGER "approval_history_no_truncate"
BEFORE TRUNCATE ON "approval_history"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_approval_history_mutation"();

-- No roles, grants, sequence prefixes, workflows or notification/audit writers.
-- Four approval permission definitions are installed by the idempotent seed.
COMMIT;
