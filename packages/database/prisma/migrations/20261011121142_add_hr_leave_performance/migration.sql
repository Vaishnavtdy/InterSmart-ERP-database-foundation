BEGIN;

-- CreateEnum
CREATE TYPE "LeaveRequestStatus" AS ENUM ('DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PerformanceCycleStatus" AS ENUM ('DRAFT', 'OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PerformanceReviewStatus" AS ENUM ('DRAFT', 'SELF_REVIEW', 'MANAGER_REVIEW', 'HR_REVIEW', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PerformanceGoalStatus" AS ENUM ('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED', 'MISSED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PerformanceFeedbackType" AS ENUM ('MANAGER', 'PEER', 'SELF', 'HR', 'OTHER');

-- CreateEnum
CREATE TYPE "HrComplaintCategory" AS ENUM ('WORKPLACE', 'MANAGEMENT', 'TEAM_CONFLICT', 'HARASSMENT', 'POLICY', 'SALARY', 'WORKLOAD', 'LEAVE', 'ATTENDANCE', 'OTHER');

-- CreateEnum
CREATE TYPE "HrComplaintStatus" AS ENUM ('OPEN', 'UNDER_REVIEW', 'ASSIGNED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REJECTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AppreciationCategory" AS ENUM ('PERFORMANCE', 'TEAMWORK', 'LEADERSHIP', 'CUSTOMER_FEEDBACK', 'INNOVATION', 'HELPFULNESS', 'MILESTONE', 'OTHER');

-- CreateEnum
CREATE TYPE "AppreciationVisibility" AS ENUM ('PRIVATE', 'TEAM', 'COMPANY');

-- CreateEnum
CREATE TYPE "FileCategory" AS ENUM ('EMPLOYEE_DOCUMENT', 'LEAVE_DOCUMENT', 'PERFORMANCE_DOCUMENT', 'COMPLAINT_ATTACHMENT', 'HR_DOCUMENT', 'OTHER');

-- AlterTable
ALTER TABLE "files" ADD COLUMN     "complaint_id" UUID,
ADD COLUMN     "employee_id" UUID,
ADD COLUMN     "file_category" "FileCategory" NOT NULL DEFAULT 'OTHER',
ADD COLUMN     "leave_request_id" UUID,
ADD COLUMN     "performance_review_id" UUID,
ALTER COLUMN "project_id" DROP NOT NULL;

-- AlterTable
ALTER TABLE "tasks" ALTER COLUMN "project_id" DROP NOT NULL;

-- CreateTable
CREATE TABLE "leave_types" (
    "id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "code" VARCHAR(64) NOT NULL,
    "description" TEXT,
    "is_paid" BOOLEAN NOT NULL DEFAULT true,
    "requires_approval" BOOLEAN NOT NULL DEFAULT true,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "leave_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leave_balances" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "leave_type_id" UUID NOT NULL,
    "year" SMALLINT NOT NULL,
    "allocated_days" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "used_days" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "pending_days" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "adjusted_days" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "leave_balances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leave_requests" (
    "id" UUID NOT NULL,
    "request_code" VARCHAR(64) NOT NULL,
    "user_id" UUID NOT NULL,
    "leave_type_id" UUID NOT NULL,
    "start_date" TIMESTAMPTZ(6) NOT NULL,
    "end_date" TIMESTAMPTZ(6) NOT NULL,
    "total_days" DECIMAL(10,2) NOT NULL,
    "reason" TEXT NOT NULL,
    "status" "LeaveRequestStatus" NOT NULL DEFAULT 'DRAFT',
    "submitted_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "approved_at" TIMESTAMPTZ(6),
    "approved_by_id" UUID,
    "rejected_at" TIMESTAMPTZ(6),
    "rejected_by_id" UUID,
    "rejection_reason" TEXT,
    "cancelled_at" TIMESTAMPTZ(6),
    "cancelled_by_id" UUID,
    "cancellation_reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "leave_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leave_request_status_history" (
    "id" UUID NOT NULL,
    "leave_request_id" UUID NOT NULL,
    "from_status" "LeaveRequestStatus",
    "to_status" "LeaveRequestStatus" NOT NULL,
    "changed_by_id" UUID NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "leave_request_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leave_request_comments" (
    "id" UUID NOT NULL,
    "leave_request_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "comment" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "leave_request_comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "performance_cycles" (
    "id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "code" VARCHAR(64) NOT NULL,
    "description" TEXT,
    "start_date" TIMESTAMPTZ(6) NOT NULL,
    "end_date" TIMESTAMPTZ(6) NOT NULL,
    "status" "PerformanceCycleStatus" NOT NULL DEFAULT 'DRAFT',
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "performance_cycles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "performance_reviews" (
    "id" UUID NOT NULL,
    "performance_cycle_id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "reviewer_id" UUID NOT NULL,
    "status" "PerformanceReviewStatus" NOT NULL DEFAULT 'DRAFT',
    "overall_rating" DECIMAL(10,4),
    "strengths" TEXT,
    "improvement_areas" TEXT,
    "employee_comments" TEXT,
    "reviewer_comments" TEXT,
    "submitted_at" TIMESTAMPTZ(6),
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "performance_reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "performance_goals" (
    "id" UUID NOT NULL,
    "performance_review_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "measurement_criteria" TEXT,
    "target_value" TEXT,
    "achieved_value" TEXT,
    "weight" DECIMAL(10,4),
    "status" "PerformanceGoalStatus" NOT NULL DEFAULT 'NOT_STARTED',
    "due_date" TIMESTAMPTZ(6),
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "performance_goals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "performance_feedback" (
    "id" UUID NOT NULL,
    "performance_review_id" UUID NOT NULL,
    "from_user_id" UUID NOT NULL,
    "feedback_type" "PerformanceFeedbackType" NOT NULL DEFAULT 'OTHER',
    "feedback" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "performance_feedback_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hr_complaints" (
    "id" UUID NOT NULL,
    "complaint_code" VARCHAR(64) NOT NULL,
    "reported_by_id" UUID NOT NULL,
    "assigned_to_id" UUID,
    "subject" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "category" "HrComplaintCategory" NOT NULL DEFAULT 'OTHER',
    "priority" "ProjectPriority" NOT NULL DEFAULT 'MEDIUM',
    "status" "HrComplaintStatus" NOT NULL DEFAULT 'OPEN',
    "is_confidential" BOOLEAN NOT NULL DEFAULT true,
    "resolution" TEXT,
    "resolved_at" TIMESTAMPTZ(6),
    "resolved_by_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "hr_complaints_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hr_complaint_status_history" (
    "id" UUID NOT NULL,
    "complaint_id" UUID NOT NULL,
    "from_status" "HrComplaintStatus",
    "to_status" "HrComplaintStatus" NOT NULL,
    "changed_by_id" UUID NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "hr_complaint_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hr_complaint_comments" (
    "id" UUID NOT NULL,
    "complaint_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "comment" TEXT NOT NULL,
    "is_internal" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "hr_complaint_comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employee_appreciations" (
    "id" UUID NOT NULL,
    "appreciation_code" VARCHAR(64) NOT NULL,
    "employee_id" UUID NOT NULL,
    "given_by_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "message" TEXT NOT NULL,
    "category" "AppreciationCategory" NOT NULL DEFAULT 'OTHER',
    "visibility" "AppreciationVisibility" NOT NULL DEFAULT 'PRIVATE',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "employee_appreciations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hr_task_links" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "leave_request_id" UUID,
    "performance_review_id" UUID,
    "complaint_id" UUID,
    "appreciation_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "hr_task_links_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "leave_types_code_key" ON "leave_types"("code");

-- CreateIndex
CREATE INDEX "leave_types_is_active_idx" ON "leave_types"("is_active");

-- CreateIndex
CREATE INDEX "leave_balances_leave_type_id_idx" ON "leave_balances"("leave_type_id");

-- CreateIndex
CREATE INDEX "leave_balances_year_idx" ON "leave_balances"("year");

-- CreateIndex
CREATE UNIQUE INDEX "leave_balances_user_id_leave_type_id_year_key" ON "leave_balances"("user_id", "leave_type_id", "year");

-- CreateIndex
CREATE UNIQUE INDEX "leave_requests_request_code_key" ON "leave_requests"("request_code");

-- CreateIndex
CREATE INDEX "leave_requests_user_id_status_deleted_at_idx" ON "leave_requests"("user_id", "status", "deleted_at");

-- CreateIndex
CREATE INDEX "leave_requests_leave_type_id_idx" ON "leave_requests"("leave_type_id");

-- CreateIndex
CREATE INDEX "leave_requests_status_deleted_at_idx" ON "leave_requests"("status", "deleted_at");

-- CreateIndex
CREATE INDEX "leave_requests_start_date_idx" ON "leave_requests"("start_date");

-- CreateIndex
CREATE INDEX "leave_requests_end_date_idx" ON "leave_requests"("end_date");

-- CreateIndex
CREATE INDEX "leave_requests_submitted_at_idx" ON "leave_requests"("submitted_at");

-- CreateIndex
CREATE INDEX "leave_requests_approved_by_id_idx" ON "leave_requests"("approved_by_id");

-- CreateIndex
CREATE INDEX "leave_requests_rejected_by_id_idx" ON "leave_requests"("rejected_by_id");

-- CreateIndex
CREATE INDEX "leave_requests_cancelled_by_id_idx" ON "leave_requests"("cancelled_by_id");

-- CreateIndex
CREATE INDEX "leave_request_status_history_leave_request_id_created_at_idx" ON "leave_request_status_history"("leave_request_id", "created_at");

-- CreateIndex
CREATE INDEX "leave_request_status_history_changed_by_id_idx" ON "leave_request_status_history"("changed_by_id");

-- CreateIndex
CREATE INDEX "leave_request_status_history_created_at_idx" ON "leave_request_status_history"("created_at");

-- CreateIndex
CREATE INDEX "leave_request_comments_leave_request_id_created_at_idx" ON "leave_request_comments"("leave_request_id", "created_at");

-- CreateIndex
CREATE INDEX "leave_request_comments_user_id_idx" ON "leave_request_comments"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "performance_cycles_code_key" ON "performance_cycles"("code");

-- CreateIndex
CREATE INDEX "performance_cycles_status_deleted_at_idx" ON "performance_cycles"("status", "deleted_at");

-- CreateIndex
CREATE INDEX "performance_cycles_start_date_idx" ON "performance_cycles"("start_date");

-- CreateIndex
CREATE INDEX "performance_cycles_end_date_idx" ON "performance_cycles"("end_date");

-- CreateIndex
CREATE INDEX "performance_cycles_created_by_id_idx" ON "performance_cycles"("created_by_id");

-- CreateIndex
CREATE INDEX "performance_reviews_employee_id_idx" ON "performance_reviews"("employee_id");

-- CreateIndex
CREATE INDEX "performance_reviews_reviewer_id_idx" ON "performance_reviews"("reviewer_id");

-- CreateIndex
CREATE INDEX "performance_reviews_status_deleted_at_idx" ON "performance_reviews"("status", "deleted_at");

-- CreateIndex
CREATE UNIQUE INDEX "performance_reviews_performance_cycle_id_employee_id_key" ON "performance_reviews"("performance_cycle_id", "employee_id");

-- CreateIndex
CREATE INDEX "performance_goals_performance_review_id_idx" ON "performance_goals"("performance_review_id");

-- CreateIndex
CREATE INDEX "performance_goals_status_idx" ON "performance_goals"("status");

-- CreateIndex
CREATE INDEX "performance_goals_due_date_idx" ON "performance_goals"("due_date");

-- CreateIndex
CREATE INDEX "performance_feedback_performance_review_id_created_at_idx" ON "performance_feedback"("performance_review_id", "created_at");

-- CreateIndex
CREATE INDEX "performance_feedback_from_user_id_idx" ON "performance_feedback"("from_user_id");

-- CreateIndex
CREATE INDEX "performance_feedback_feedback_type_idx" ON "performance_feedback"("feedback_type");

-- CreateIndex
CREATE UNIQUE INDEX "hr_complaints_complaint_code_key" ON "hr_complaints"("complaint_code");

-- CreateIndex
CREATE INDEX "hr_complaints_reported_by_id_idx" ON "hr_complaints"("reported_by_id");

-- CreateIndex
CREATE INDEX "hr_complaints_assigned_to_id_idx" ON "hr_complaints"("assigned_to_id");

-- CreateIndex
CREATE INDEX "hr_complaints_resolved_by_id_idx" ON "hr_complaints"("resolved_by_id");

-- CreateIndex
CREATE INDEX "hr_complaints_status_deleted_at_idx" ON "hr_complaints"("status", "deleted_at");

-- CreateIndex
CREATE INDEX "hr_complaints_priority_idx" ON "hr_complaints"("priority");

-- CreateIndex
CREATE INDEX "hr_complaints_category_idx" ON "hr_complaints"("category");

-- CreateIndex
CREATE INDEX "hr_complaints_created_at_idx" ON "hr_complaints"("created_at");

-- CreateIndex
CREATE INDEX "hr_complaints_is_confidential_deleted_at_idx" ON "hr_complaints"("is_confidential", "deleted_at");

-- CreateIndex
CREATE INDEX "hr_complaint_status_history_complaint_id_created_at_idx" ON "hr_complaint_status_history"("complaint_id", "created_at");

-- CreateIndex
CREATE INDEX "hr_complaint_status_history_changed_by_id_idx" ON "hr_complaint_status_history"("changed_by_id");

-- CreateIndex
CREATE INDEX "hr_complaint_status_history_created_at_idx" ON "hr_complaint_status_history"("created_at");

-- CreateIndex
CREATE INDEX "hr_complaint_comments_complaint_id_is_internal_created_at_idx" ON "hr_complaint_comments"("complaint_id", "is_internal", "created_at");

-- CreateIndex
CREATE INDEX "hr_complaint_comments_user_id_idx" ON "hr_complaint_comments"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "employee_appreciations_appreciation_code_key" ON "employee_appreciations"("appreciation_code");

-- CreateIndex
CREATE INDEX "employee_appreciations_employee_id_created_at_idx" ON "employee_appreciations"("employee_id", "created_at");

-- CreateIndex
CREATE INDEX "employee_appreciations_given_by_id_idx" ON "employee_appreciations"("given_by_id");

-- CreateIndex
CREATE INDEX "employee_appreciations_visibility_deleted_at_idx" ON "employee_appreciations"("visibility", "deleted_at");

-- CreateIndex
CREATE INDEX "employee_appreciations_category_idx" ON "employee_appreciations"("category");

-- CreateIndex
CREATE INDEX "hr_task_links_task_id_idx" ON "hr_task_links"("task_id");

-- CreateIndex
CREATE INDEX "hr_task_links_leave_request_id_idx" ON "hr_task_links"("leave_request_id");

-- CreateIndex
CREATE INDEX "hr_task_links_performance_review_id_idx" ON "hr_task_links"("performance_review_id");

-- CreateIndex
CREATE INDEX "hr_task_links_complaint_id_idx" ON "hr_task_links"("complaint_id");

-- CreateIndex
CREATE INDEX "hr_task_links_appreciation_id_idx" ON "hr_task_links"("appreciation_id");

-- CreateIndex
CREATE INDEX "files_file_category_deleted_at_idx" ON "files"("file_category", "deleted_at");

-- CreateIndex
CREATE INDEX "files_employee_id_idx" ON "files"("employee_id");

-- CreateIndex
CREATE INDEX "files_leave_request_id_idx" ON "files"("leave_request_id");

-- CreateIndex
CREATE INDEX "files_performance_review_id_idx" ON "files"("performance_review_id");

-- CreateIndex
CREATE INDEX "files_complaint_id_idx" ON "files"("complaint_id");

-- AddForeignKey
ALTER TABLE "files" ADD CONSTRAINT "files_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "files" ADD CONSTRAINT "files_leave_request_id_fkey" FOREIGN KEY ("leave_request_id") REFERENCES "leave_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "files" ADD CONSTRAINT "files_performance_review_id_fkey" FOREIGN KEY ("performance_review_id") REFERENCES "performance_reviews"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "files" ADD CONSTRAINT "files_complaint_id_fkey" FOREIGN KEY ("complaint_id") REFERENCES "hr_complaints"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_balances" ADD CONSTRAINT "leave_balances_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_balances" ADD CONSTRAINT "leave_balances_leave_type_id_fkey" FOREIGN KEY ("leave_type_id") REFERENCES "leave_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_requests" ADD CONSTRAINT "leave_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_requests" ADD CONSTRAINT "leave_requests_leave_type_id_fkey" FOREIGN KEY ("leave_type_id") REFERENCES "leave_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_requests" ADD CONSTRAINT "leave_requests_approved_by_id_fkey" FOREIGN KEY ("approved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_requests" ADD CONSTRAINT "leave_requests_rejected_by_id_fkey" FOREIGN KEY ("rejected_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_requests" ADD CONSTRAINT "leave_requests_cancelled_by_id_fkey" FOREIGN KEY ("cancelled_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_request_status_history" ADD CONSTRAINT "leave_request_status_history_leave_request_id_fkey" FOREIGN KEY ("leave_request_id") REFERENCES "leave_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_request_status_history" ADD CONSTRAINT "leave_request_status_history_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_request_comments" ADD CONSTRAINT "leave_request_comments_leave_request_id_fkey" FOREIGN KEY ("leave_request_id") REFERENCES "leave_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_request_comments" ADD CONSTRAINT "leave_request_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_cycles" ADD CONSTRAINT "performance_cycles_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_reviews" ADD CONSTRAINT "performance_reviews_performance_cycle_id_fkey" FOREIGN KEY ("performance_cycle_id") REFERENCES "performance_cycles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_reviews" ADD CONSTRAINT "performance_reviews_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_reviews" ADD CONSTRAINT "performance_reviews_reviewer_id_fkey" FOREIGN KEY ("reviewer_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_goals" ADD CONSTRAINT "performance_goals_performance_review_id_fkey" FOREIGN KEY ("performance_review_id") REFERENCES "performance_reviews"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_feedback" ADD CONSTRAINT "performance_feedback_performance_review_id_fkey" FOREIGN KEY ("performance_review_id") REFERENCES "performance_reviews"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "performance_feedback" ADD CONSTRAINT "performance_feedback_from_user_id_fkey" FOREIGN KEY ("from_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_complaints" ADD CONSTRAINT "hr_complaints_reported_by_id_fkey" FOREIGN KEY ("reported_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_complaints" ADD CONSTRAINT "hr_complaints_assigned_to_id_fkey" FOREIGN KEY ("assigned_to_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_complaints" ADD CONSTRAINT "hr_complaints_resolved_by_id_fkey" FOREIGN KEY ("resolved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_complaint_status_history" ADD CONSTRAINT "hr_complaint_status_history_complaint_id_fkey" FOREIGN KEY ("complaint_id") REFERENCES "hr_complaints"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_complaint_status_history" ADD CONSTRAINT "hr_complaint_status_history_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_complaint_comments" ADD CONSTRAINT "hr_complaint_comments_complaint_id_fkey" FOREIGN KEY ("complaint_id") REFERENCES "hr_complaints"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_complaint_comments" ADD CONSTRAINT "hr_complaint_comments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_appreciations" ADD CONSTRAINT "employee_appreciations_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employee_appreciations" ADD CONSTRAINT "employee_appreciations_given_by_id_fkey" FOREIGN KEY ("given_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_task_links" ADD CONSTRAINT "hr_task_links_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_task_links" ADD CONSTRAINT "hr_task_links_leave_request_id_fkey" FOREIGN KEY ("leave_request_id") REFERENCES "leave_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_task_links" ADD CONSTRAINT "hr_task_links_performance_review_id_fkey" FOREIGN KEY ("performance_review_id") REFERENCES "performance_reviews"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_task_links" ADD CONSTRAINT "hr_task_links_complaint_id_fkey" FOREIGN KEY ("complaint_id") REFERENCES "hr_complaints"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hr_task_links" ADD CONSTRAINT "hr_task_links_appreciation_id_fkey" FOREIGN KEY ("appreciation_id") REFERENCES "employee_appreciations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "leave_balances" ADD CONSTRAINT "leave_balances_year_range_check"
CHECK ("year" BETWEEN 1 AND 9999);
ALTER TABLE "leave_balances" ADD CONSTRAINT "leave_balances_days_nonnegative_check"
CHECK ("allocated_days" >= 0 AND "used_days" >= 0 AND "pending_days" >= 0);
-- adjusted_days is deliberately signed; remaining_days is calculated, not stored.
ALTER TABLE "leave_requests" ADD CONSTRAINT "leave_requests_date_order_check"
CHECK ("end_date" >= "start_date");
ALTER TABLE "leave_requests" ADD CONSTRAINT "leave_requests_days_positive_check"
CHECK ("total_days" > 0);
ALTER TABLE "leave_requests" ADD CONSTRAINT "leave_requests_approval_pair_check"
CHECK (("approved_at" IS NULL) = ("approved_by_id" IS NULL));
ALTER TABLE "leave_requests" ADD CONSTRAINT "leave_requests_rejection_pair_check"
CHECK (("rejected_at" IS NULL) = ("rejected_by_id" IS NULL));
ALTER TABLE "leave_requests" ADD CONSTRAINT "leave_requests_cancellation_pair_check"
CHECK (("cancelled_at" IS NULL) = ("cancelled_by_id" IS NULL));
ALTER TABLE "leave_request_status_history" ADD CONSTRAINT "leave_history_distinct_status_check"
CHECK ("from_status" IS NULL OR "from_status" <> "to_status");
ALTER TABLE "performance_cycles" ADD CONSTRAINT "performance_cycles_date_order_check"
CHECK ("end_date" >= "start_date");
ALTER TABLE "performance_reviews" ADD CONSTRAINT "performance_reviews_rating_nonnegative_check"
CHECK ("overall_rating" IS NULL OR "overall_rating" >= 0);
ALTER TABLE "performance_reviews" ADD CONSTRAINT "performance_reviews_time_order_check"
CHECK ("submitted_at" IS NULL OR "completed_at" IS NULL OR "completed_at" >= "submitted_at");
ALTER TABLE "performance_goals" ADD CONSTRAINT "performance_goals_weight_nonnegative_check"
CHECK ("weight" IS NULL OR "weight" >= 0);
ALTER TABLE "hr_complaints" ADD CONSTRAINT "hr_complaints_resolution_pair_check"
CHECK (("resolved_at" IS NULL) = ("resolved_by_id" IS NULL));
ALTER TABLE "hr_complaint_status_history" ADD CONSTRAINT "hr_complaint_history_distinct_status_check"
CHECK ("from_status" IS NULL OR "from_status" <> "to_status");

-- Nullable Project permits standalone HR work, without weakening the original
-- same-Project parent/sprint FKs through PostgreSQL MATCH SIMPLE NULL semantics.
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_nonproject_hr_scope_check"
CHECK ("project_id" IS NOT NULL OR (
    "workstream" = 'HR' AND "parent_task_id" IS NULL AND "sprint_id" IS NULL
));

-- HR documents cannot be projected into ProjectResource/customer sharing.
-- Classification/ownership integrity is not an authorization implementation.
ALTER TABLE "files" ADD CONSTRAINT "files_hr_project_separation_check"
CHECK ("project_id" IS NULL OR (
    "file_category" = 'OTHER' AND "employee_id" IS NULL
    AND "leave_request_id" IS NULL AND "performance_review_id" IS NULL
    AND "complaint_id" IS NULL
));
ALTER TABLE "files" ADD CONSTRAINT "files_hr_single_context_check"
CHECK (num_nonnulls("employee_id", "leave_request_id", "performance_review_id", "complaint_id") <= 1);
ALTER TABLE "files" ADD CONSTRAINT "files_hr_category_context_check"
CHECK (
    ("file_category" = 'EMPLOYEE_DOCUMENT' AND "employee_id" IS NOT NULL)
    OR ("file_category" = 'LEAVE_DOCUMENT' AND "leave_request_id" IS NOT NULL)
    OR ("file_category" = 'PERFORMANCE_DOCUMENT' AND "performance_review_id" IS NOT NULL)
    OR ("file_category" = 'COMPLAINT_ATTACHMENT' AND "complaint_id" IS NOT NULL)
    OR "file_category" = 'HR_DOCUMENT'
    OR ("file_category" = 'OTHER' AND num_nonnulls("employee_id", "leave_request_id", "performance_review_id", "complaint_id") = 0)
);

-- Prisma cannot express the partial/expression indexes below. Preserve in SQL.
-- NULL Project must not allow duplicate physical revisions for standalone files.
CREATE UNIQUE INDEX "files_nonproject_series_version_key"
ON "files" ("file_series_id", "version") WHERE "project_id" IS NULL;
CREATE UNIQUE INDEX "hr_task_links_context_key"
ON "hr_task_links" (
    "task_id",
    COALESCE("leave_request_id"::text, ''),
    COALESCE("performance_review_id"::text, ''),
    COALESCE("complaint_id"::text, ''),
    COALESCE("appreciation_id"::text, '')
);

CREATE FUNCTION "prevent_hr_status_history_mutation"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'HR status history is append-only' USING ERRCODE = '23514';
END;
$$;
CREATE TRIGGER "leave_history_append_only"
BEFORE UPDATE OR DELETE ON "leave_request_status_history"
FOR EACH ROW EXECUTE FUNCTION "prevent_hr_status_history_mutation"();
CREATE TRIGGER "leave_history_no_truncate"
BEFORE TRUNCATE ON "leave_request_status_history"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_hr_status_history_mutation"();
CREATE TRIGGER "hr_complaint_history_append_only"
BEFORE UPDATE OR DELETE ON "hr_complaint_status_history"
FOR EACH ROW EXECUTE FUNCTION "prevent_hr_status_history_mutation"();
CREATE TRIGGER "hr_complaint_history_no_truncate"
BEFORE TRUNCATE ON "hr_complaint_status_history"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_hr_status_history_mutation"();

-- Keep responsible-user/timestamp records even when they have no children.
-- Soft deletion is available on these parent records, including drafts.
CREATE FUNCTION "prevent_hr_record_hard_delete"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Retain HR records; use deleted_at instead of hard deletion'
    USING ERRCODE = '23514';
END;
$$;
CREATE TRIGGER "leave_requests_no_hard_delete"
BEFORE DELETE OR TRUNCATE ON "leave_requests"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_hr_record_hard_delete"();
CREATE TRIGGER "performance_cycles_no_hard_delete"
BEFORE DELETE OR TRUNCATE ON "performance_cycles"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_hr_record_hard_delete"();
CREATE TRIGGER "performance_reviews_no_hard_delete"
BEFORE DELETE OR TRUNCATE ON "performance_reviews"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_hr_record_hard_delete"();
CREATE TRIGGER "hr_complaints_no_hard_delete"
BEFORE DELETE OR TRUNCATE ON "hr_complaints"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_hr_record_hard_delete"();
CREATE TRIGGER "employee_appreciations_no_hard_delete"
BEFORE DELETE OR TRUNCATE ON "employee_appreciations"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_hr_record_hard_delete"();

COMMIT;
