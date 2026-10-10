BEGIN;

-- CreateEnum
CREATE TYPE "TaskType" AS ENUM ('GENERAL', 'DESIGN', 'DEVELOPMENT', 'TESTING', 'BUG_FIX', 'REVIEW', 'RESEARCH', 'DOCUMENTATION', 'MEETING', 'FOLLOW_UP', 'APPROVAL', 'DEPLOYMENT', 'OTHER');

-- CreateEnum
CREATE TYPE "TaskWorkstream" AS ENUM ('PMO', 'BUSINESS_ANALYSIS', 'UI', 'UX', 'DEVELOPMENT', 'QA', 'PROJECT_MANAGEMENT', 'SALES', 'ACCOUNTS', 'HR', 'OTHER');

-- CreateEnum
CREATE TYPE "TaskStatus" AS ENUM ('TODO', 'ASSIGNED', 'IN_PROGRESS', 'BLOCKED', 'IN_REVIEW', 'REWORK', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "TaskDependencyType" AS ENUM ('BLOCKS', 'RELATED');

-- CreateTable
CREATE TABLE "tasks" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "parent_task_id" UUID,
    "task_code" VARCHAR(32) NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "task_type" "TaskType" NOT NULL DEFAULT 'GENERAL',
    "workstream" "TaskWorkstream" NOT NULL DEFAULT 'OTHER',
    "status" "TaskStatus" NOT NULL DEFAULT 'TODO',
    "priority" "ProjectPriority" NOT NULL DEFAULT 'MEDIUM',
    "created_by_id" UUID NOT NULL,
    "assigned_to_id" UUID,
    "start_date" TIMESTAMPTZ(6),
    "due_date" TIMESTAMPTZ(6),
    "completed_at" TIMESTAMPTZ(6),
    "estimated_hours" DECIMAL(10,2),
    "actual_hours" DECIMAL(10,2),
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "tasks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "task_dependencies" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "depends_on_task_id" UUID NOT NULL,
    "dependency_type" "TaskDependencyType" NOT NULL DEFAULT 'BLOCKS',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "task_dependencies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "task_comments" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "comment" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "task_comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "task_status_history" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "from_status" "TaskStatus",
    "to_status" "TaskStatus" NOT NULL,
    "changed_by_id" UUID NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "task_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "task_assignments" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "assigned_to_id" UUID NOT NULL,
    "assigned_by_id" UUID NOT NULL,
    "assigned_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "released_at" TIMESTAMPTZ(6),
    "reason" TEXT,

    CONSTRAINT "task_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "tasks_task_code_key" ON "tasks"("task_code");

-- CreateIndex
CREATE INDEX "tasks_project_id_status_idx" ON "tasks"("project_id", "status");

-- CreateIndex
CREATE INDEX "tasks_parent_task_id_idx" ON "tasks"("parent_task_id");

-- CreateIndex
CREATE INDEX "tasks_assigned_to_id_status_idx" ON "tasks"("assigned_to_id", "status");

-- CreateIndex
CREATE INDEX "tasks_created_by_id_idx" ON "tasks"("created_by_id");

-- CreateIndex
CREATE INDEX "tasks_status_deleted_at_idx" ON "tasks"("status", "deleted_at");

-- CreateIndex
CREATE INDEX "tasks_priority_idx" ON "tasks"("priority");

-- CreateIndex
CREATE INDEX "tasks_workstream_idx" ON "tasks"("workstream");

-- CreateIndex
CREATE INDEX "tasks_task_type_idx" ON "tasks"("task_type");

-- CreateIndex
CREATE INDEX "tasks_due_date_idx" ON "tasks"("due_date");

-- CreateIndex
CREATE INDEX "tasks_created_at_idx" ON "tasks"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "tasks_project_id_id_key" ON "tasks"("project_id", "id");

-- CreateIndex
CREATE INDEX "task_dependencies_depends_on_task_id_idx" ON "task_dependencies"("depends_on_task_id");

-- CreateIndex
CREATE UNIQUE INDEX "task_dependencies_task_id_depends_on_task_id_dependency_typ_key" ON "task_dependencies"("task_id", "depends_on_task_id", "dependency_type");

-- CreateIndex
CREATE INDEX "task_comments_task_id_created_at_idx" ON "task_comments"("task_id", "created_at");

-- CreateIndex
CREATE INDEX "task_comments_user_id_idx" ON "task_comments"("user_id");

-- CreateIndex
CREATE INDEX "task_comments_created_at_idx" ON "task_comments"("created_at");

-- CreateIndex
CREATE INDEX "task_status_history_task_id_created_at_idx" ON "task_status_history"("task_id", "created_at");

-- CreateIndex
CREATE INDEX "task_status_history_changed_by_id_idx" ON "task_status_history"("changed_by_id");

-- CreateIndex
CREATE INDEX "task_status_history_created_at_idx" ON "task_status_history"("created_at");

-- CreateIndex
CREATE INDEX "task_assignments_task_id_released_at_idx" ON "task_assignments"("task_id", "released_at");

-- CreateIndex
CREATE INDEX "task_assignments_assigned_to_id_assigned_at_idx" ON "task_assignments"("assigned_to_id", "assigned_at");

-- CreateIndex
CREATE INDEX "task_assignments_assigned_by_id_idx" ON "task_assignments"("assigned_by_id");

-- CreateIndex
CREATE INDEX "task_assignments_assigned_at_idx" ON "task_assignments"("assigned_at");

-- AddForeignKey
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_project_id_parent_task_id_fkey" FOREIGN KEY ("project_id", "parent_task_id") REFERENCES "tasks"("project_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_assigned_to_id_fkey" FOREIGN KEY ("assigned_to_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_dependencies" ADD CONSTRAINT "task_dependencies_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_dependencies" ADD CONSTRAINT "task_dependencies_depends_on_task_id_fkey" FOREIGN KEY ("depends_on_task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_comments" ADD CONSTRAINT "task_comments_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_comments" ADD CONSTRAINT "task_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_status_history" ADD CONSTRAINT "task_status_history_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_status_history" ADD CONSTRAINT "task_status_history_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_assignments" ADD CONSTRAINT "task_assignments_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_assignments" ADD CONSTRAINT "task_assignments_assigned_to_id_fkey" FOREIGN KEY ("assigned_to_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "task_assignments" ADD CONSTRAINT "task_assignments_assigned_by_id_fkey" FOREIGN KEY ("assigned_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "tasks" ADD CONSTRAINT "tasks_parent_not_self_check"
CHECK ("parent_task_id" IS NULL OR "parent_task_id" <> "id");
ALTER TABLE "task_dependencies" ADD CONSTRAINT "task_dependencies_not_self_check"
CHECK ("task_id" <> "depends_on_task_id");
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_estimated_hours_nonnegative_finite_check"
CHECK ("estimated_hours" IS NULL OR ("estimated_hours" >= 0 AND "estimated_hours" NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric)));
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_actual_hours_nonnegative_finite_check"
CHECK ("actual_hours" IS NULL OR ("actual_hours" >= 0 AND "actual_hours" NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric)));
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_sort_order_nonnegative_check"
CHECK ("sort_order" >= 0);
ALTER TABLE "task_assignments" ADD CONSTRAINT "task_assignments_release_order_check"
CHECK ("released_at" IS NULL OR "released_at" >= "assigned_at");

CREATE UNIQUE INDEX "task_assignments_one_active_per_task_key"
ON "task_assignments" ("task_id") WHERE "released_at" IS NULL;

-- Match existing project/payment append-only history conventions.
CREATE FUNCTION "prevent_task_status_history_mutation"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Task status history is append-only'
    USING ERRCODE = '23514';
END;
$$;
CREATE TRIGGER "task_status_history_append_only"
BEFORE UPDATE OR DELETE ON "task_status_history"
FOR EACH ROW EXECUTE FUNCTION "prevent_task_status_history_mutation"();
CREATE TRIGGER "task_status_history_no_truncate"
BEFORE TRUNCATE ON "task_status_history"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_task_status_history_mutation"();

-- Assignment identities are historical facts. Only closing an open period is
-- permitted; reassignment inserts a new row rather than relabeling an old one.
CREATE FUNCTION "preserve_task_assignment_history"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP IN ('DELETE', 'TRUNCATE') THEN
        RAISE EXCEPTION 'Task assignment history cannot be deleted'
        USING ERRCODE = '23514';
    END IF;
    IF NEW."id" IS DISTINCT FROM OLD."id"
        OR NEW."task_id" IS DISTINCT FROM OLD."task_id"
        OR NEW."assigned_to_id" IS DISTINCT FROM OLD."assigned_to_id"
        OR NEW."assigned_by_id" IS DISTINCT FROM OLD."assigned_by_id"
        OR NEW."assigned_at" IS DISTINCT FROM OLD."assigned_at"
        OR NEW."reason" IS DISTINCT FROM OLD."reason"
        OR (OLD."released_at" IS NOT NULL AND NEW."released_at" IS DISTINCT FROM OLD."released_at")
    THEN
        RAISE EXCEPTION 'Preserve assignment history; only close an unreleased period'
        USING ERRCODE = '23514';
    END IF;
    RETURN NEW;
END;
$$;
CREATE TRIGGER "task_assignments_preserve_history"
BEFORE UPDATE OR DELETE ON "task_assignments"
FOR EACH ROW EXECUTE FUNCTION "preserve_task_assignment_history"();
CREATE TRIGGER "task_assignments_no_truncate"
BEFORE TRUNCATE ON "task_assignments"
FOR EACH STATEMENT EXECUTE FUNCTION "preserve_task_assignment_history"();

COMMIT;
