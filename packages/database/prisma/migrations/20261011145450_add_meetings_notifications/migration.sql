BEGIN;

-- CreateEnum
CREATE TYPE "MeetingType" AS ENUM ('INTERNAL', 'CUSTOMER', 'PROJECT', 'TEAM', 'MANAGEMENT', 'HR', 'INTERVIEW', 'REVIEW', 'OTHER');

-- CreateEnum
CREATE TYPE "MeetingStatus" AS ENUM ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'NO_SHOW');

-- CreateEnum
CREATE TYPE "MeetingParticipantRole" AS ENUM ('ORGANIZER', 'REQUIRED', 'OPTIONAL');

-- CreateEnum
CREATE TYPE "MeetingCustomerContactRole" AS ENUM ('REQUIRED', 'OPTIONAL');

-- CreateEnum
CREATE TYPE "MeetingResponseStatus" AS ENUM ('PENDING', 'ACCEPTED', 'DECLINED', 'TENTATIVE');

-- CreateEnum
CREATE TYPE "MeetingAgendaStatus" AS ENUM ('PENDING', 'DISCUSSION', 'COMPLETED', 'DEFERRED');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('TASK_ASSIGNED', 'TASK_DUE', 'TASK_OVERDUE', 'MEETING_INVITATION', 'MEETING_REMINDER', 'MEETING_CANCELLED', 'LEAVE_REQUEST', 'LEAVE_APPROVED', 'LEAVE_REJECTED', 'PAYMENT_REQUEST', 'PAYMENT_APPROVED', 'PAYMENT_REJECTED', 'PROJECT_STATUS', 'BUG_ASSIGNED', 'BUG_STATUS', 'APPROVAL_REQUIRED', 'SYSTEM', 'OTHER');

-- CreateEnum
CREATE TYPE "NotificationPriority" AS ENUM ('LOW', 'NORMAL', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "NotificationChannel" AS ENUM ('IN_APP', 'EMAIL', 'PUSH');

-- CreateEnum
CREATE TYPE "NotificationDeliveryStatus" AS ENUM ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'SKIPPED');

-- CreateTable
CREATE TABLE "meetings" (
    "id" UUID NOT NULL,
    "meeting_code" VARCHAR(64) NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "meeting_type" "MeetingType" NOT NULL DEFAULT 'INTERNAL',
    "status" "MeetingStatus" NOT NULL DEFAULT 'SCHEDULED',
    "organizer_id" UUID NOT NULL,
    "project_id" UUID,
    "customer_id" UUID,
    "start_at" TIMESTAMPTZ(6) NOT NULL,
    "end_at" TIMESTAMPTZ(6) NOT NULL,
    "location" VARCHAR(255),
    "meeting_url" VARCHAR(2048),
    "agenda" TEXT,
    "minutes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "cancelled_at" TIMESTAMPTZ(6),
    "cancelled_by_id" UUID,
    "cancellation_reason" TEXT,

    CONSTRAINT "meetings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "meeting_participants" (
    "id" UUID NOT NULL,
    "meeting_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "participant_role" "MeetingParticipantRole" NOT NULL DEFAULT 'REQUIRED',
    "response_status" "MeetingResponseStatus" NOT NULL DEFAULT 'PENDING',
    "joined_at" TIMESTAMPTZ(6),
    "left_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "meeting_participants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "meeting_customer_contacts" (
    "id" UUID NOT NULL,
    "meeting_id" UUID NOT NULL,
    "customer_contact_id" UUID NOT NULL,
    "participant_role" "MeetingCustomerContactRole" NOT NULL DEFAULT 'REQUIRED',
    "response_status" "MeetingResponseStatus" NOT NULL DEFAULT 'PENDING',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "meeting_customer_contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "meeting_agenda_items" (
    "id" UUID NOT NULL,
    "meeting_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "status" "MeetingAgendaStatus" NOT NULL DEFAULT 'PENDING',
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "meeting_agenda_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "meeting_minutes" (
    "id" UUID NOT NULL,
    "meeting_id" UUID NOT NULL,
    "summary" TEXT NOT NULL,
    "decisions" TEXT,
    "created_by_id" UUID NOT NULL,
    "approved_by_id" UUID,
    "approved_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "meeting_minutes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "meeting_task_links" (
    "id" UUID NOT NULL,
    "meeting_id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "meeting_task_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "meeting_attachments" (
    "id" UUID NOT NULL,
    "meeting_id" UUID NOT NULL,
    "file_id" UUID NOT NULL,
    "uploaded_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "meeting_attachments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "meeting_status_history" (
    "id" UUID NOT NULL,
    "meeting_id" UUID NOT NULL,
    "from_status" "MeetingStatus",
    "to_status" "MeetingStatus" NOT NULL,
    "changed_by_id" UUID NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "meeting_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL,
    "recipient_id" UUID NOT NULL,
    "notification_type" "NotificationType" NOT NULL DEFAULT 'OTHER',
    "title" VARCHAR(255) NOT NULL,
    "message" TEXT NOT NULL,
    "priority" "NotificationPriority" NOT NULL DEFAULT 'NORMAL',
    "entity_type" VARCHAR(64),
    "entity_id" UUID,
    "action_url" VARCHAR(2048),
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "read_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ(6),

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_deliveries" (
    "id" UUID NOT NULL,
    "notification_id" UUID NOT NULL,
    "channel" "NotificationChannel" NOT NULL,
    "status" "NotificationDeliveryStatus" NOT NULL DEFAULT 'PENDING',
    "sent_at" TIMESTAMPTZ(6),
    "delivered_at" TIMESTAMPTZ(6),
    "failed_at" TIMESTAMPTZ(6),
    "failure_reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "notification_deliveries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_preferences" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "notification_type" "NotificationType" NOT NULL,
    "in_app_enabled" BOOLEAN NOT NULL,
    "email_enabled" BOOLEAN NOT NULL,
    "push_enabled" BOOLEAN NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "notification_preferences_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "meetings_meeting_code_key" ON "meetings"("meeting_code");

-- CreateIndex
CREATE INDEX "meetings_organizer_id_idx" ON "meetings"("organizer_id");

-- CreateIndex
CREATE INDEX "meetings_project_id_idx" ON "meetings"("project_id");

-- CreateIndex
CREATE INDEX "meetings_customer_id_idx" ON "meetings"("customer_id");

-- CreateIndex
CREATE INDEX "meetings_start_at_idx" ON "meetings"("start_at");

-- CreateIndex
CREATE INDEX "meetings_end_at_idx" ON "meetings"("end_at");

-- CreateIndex
CREATE INDEX "meetings_status_start_at_idx" ON "meetings"("status", "start_at");

-- CreateIndex
CREATE INDEX "meetings_cancelled_by_id_idx" ON "meetings"("cancelled_by_id");

-- CreateIndex
CREATE INDEX "meeting_participants_user_id_response_status_idx" ON "meeting_participants"("user_id", "response_status");

-- CreateIndex
CREATE UNIQUE INDEX "meeting_participants_meeting_id_user_id_key" ON "meeting_participants"("meeting_id", "user_id");

-- CreateIndex
CREATE INDEX "meeting_customer_contacts_customer_contact_id_idx" ON "meeting_customer_contacts"("customer_contact_id");

-- CreateIndex
CREATE UNIQUE INDEX "meeting_customer_contacts_meeting_id_customer_contact_id_key" ON "meeting_customer_contacts"("meeting_id", "customer_contact_id");

-- CreateIndex
CREATE INDEX "meeting_agenda_items_meeting_id_sort_order_idx" ON "meeting_agenda_items"("meeting_id", "sort_order");

-- CreateIndex
CREATE INDEX "meeting_agenda_items_created_by_id_idx" ON "meeting_agenda_items"("created_by_id");

-- CreateIndex
CREATE INDEX "meeting_agenda_items_status_idx" ON "meeting_agenda_items"("status");

-- CreateIndex
CREATE UNIQUE INDEX "meeting_minutes_meeting_id_key" ON "meeting_minutes"("meeting_id");

-- CreateIndex
CREATE INDEX "meeting_minutes_created_by_id_idx" ON "meeting_minutes"("created_by_id");

-- CreateIndex
CREATE INDEX "meeting_minutes_approved_by_id_idx" ON "meeting_minutes"("approved_by_id");

-- CreateIndex
CREATE INDEX "meeting_task_links_task_id_idx" ON "meeting_task_links"("task_id");

-- CreateIndex
CREATE UNIQUE INDEX "meeting_task_links_meeting_id_task_id_key" ON "meeting_task_links"("meeting_id", "task_id");

-- CreateIndex
CREATE INDEX "meeting_attachments_file_id_idx" ON "meeting_attachments"("file_id");

-- CreateIndex
CREATE INDEX "meeting_attachments_uploaded_by_id_idx" ON "meeting_attachments"("uploaded_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "meeting_attachments_meeting_id_file_id_key" ON "meeting_attachments"("meeting_id", "file_id");

-- CreateIndex
CREATE INDEX "meeting_status_history_meeting_id_created_at_idx" ON "meeting_status_history"("meeting_id", "created_at");

-- CreateIndex
CREATE INDEX "meeting_status_history_changed_by_id_idx" ON "meeting_status_history"("changed_by_id");

-- CreateIndex
CREATE INDEX "notifications_recipient_id_is_read_created_at_idx" ON "notifications"("recipient_id", "is_read", "created_at");

-- CreateIndex
CREATE INDEX "notifications_is_read_idx" ON "notifications"("is_read");

-- CreateIndex
CREATE INDEX "notifications_created_at_idx" ON "notifications"("created_at");

-- CreateIndex
CREATE INDEX "notifications_notification_type_idx" ON "notifications"("notification_type");

-- CreateIndex
CREATE INDEX "notifications_entity_type_entity_id_idx" ON "notifications"("entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "notifications_expires_at_idx" ON "notifications"("expires_at");

-- CreateIndex
CREATE INDEX "notification_deliveries_notification_id_channel_created_at_idx" ON "notification_deliveries"("notification_id", "channel", "created_at");

-- CreateIndex
CREATE INDEX "notification_deliveries_status_created_at_idx" ON "notification_deliveries"("status", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "notification_preferences_user_id_notification_type_key" ON "notification_preferences"("user_id", "notification_type");

-- AddForeignKey
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_organizer_id_fkey" FOREIGN KEY ("organizer_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_cancelled_by_id_fkey" FOREIGN KEY ("cancelled_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_participants" ADD CONSTRAINT "meeting_participants_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "meetings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_participants" ADD CONSTRAINT "meeting_participants_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_customer_contacts" ADD CONSTRAINT "meeting_customer_contacts_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "meetings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_customer_contacts" ADD CONSTRAINT "meeting_customer_contacts_customer_contact_id_fkey" FOREIGN KEY ("customer_contact_id") REFERENCES "customer_contacts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_agenda_items" ADD CONSTRAINT "meeting_agenda_items_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "meetings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_agenda_items" ADD CONSTRAINT "meeting_agenda_items_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_minutes" ADD CONSTRAINT "meeting_minutes_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "meetings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_minutes" ADD CONSTRAINT "meeting_minutes_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_minutes" ADD CONSTRAINT "meeting_minutes_approved_by_id_fkey" FOREIGN KEY ("approved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_task_links" ADD CONSTRAINT "meeting_task_links_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "meetings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_task_links" ADD CONSTRAINT "meeting_task_links_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_attachments" ADD CONSTRAINT "meeting_attachments_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "meetings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_attachments" ADD CONSTRAINT "meeting_attachments_file_id_fkey" FOREIGN KEY ("file_id") REFERENCES "files"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_attachments" ADD CONSTRAINT "meeting_attachments_uploaded_by_id_fkey" FOREIGN KEY ("uploaded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_status_history" ADD CONSTRAINT "meeting_status_history_meeting_id_fkey" FOREIGN KEY ("meeting_id") REFERENCES "meetings"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "meeting_status_history" ADD CONSTRAINT "meeting_status_history_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_recipient_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_deliveries" ADD CONSTRAINT "notification_deliveries_notification_id_fkey" FOREIGN KEY ("notification_id") REFERENCES "notifications"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_preferences" ADD CONSTRAINT "notification_preferences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "meetings" ADD CONSTRAINT "meetings_time_order_check"
CHECK ("end_at" > "start_at");
ALTER TABLE "meetings" ADD CONSTRAINT "meetings_cancellation_pair_check"
CHECK (("cancelled_at" IS NULL) = ("cancelled_by_id" IS NULL));
ALTER TABLE "meeting_participants" ADD CONSTRAINT "meeting_participants_attendance_order_check"
CHECK ("left_at" IS NULL OR ("joined_at" IS NOT NULL AND "left_at" >= "joined_at"));
ALTER TABLE "meeting_agenda_items" ADD CONSTRAINT "meeting_agenda_sort_order_check"
CHECK ("sort_order" >= 0);
ALTER TABLE "meeting_minutes" ADD CONSTRAINT "meeting_minutes_approval_pair_check"
CHECK (("approved_at" IS NULL) = ("approved_by_id" IS NULL));
ALTER TABLE "meeting_status_history" ADD CONSTRAINT "meeting_history_distinct_status_check"
CHECK ("from_status" IS NULL OR "from_status" <> "to_status");

ALTER TABLE "notifications" ADD CONSTRAINT "notifications_entity_pair_check"
CHECK (("entity_type" IS NULL) = ("entity_id" IS NULL));
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_entity_type_nonblank_check"
CHECK ("entity_type" IS NULL OR length(btrim("entity_type")) > 0);
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_read_state_check"
CHECK ("is_read" = ("read_at" IS NOT NULL));
ALTER TABLE "notification_deliveries" ADD CONSTRAINT "notification_delivery_time_order_check"
CHECK (
    ("sent_at" IS NULL OR "delivered_at" IS NULL OR "delivered_at" >= "sent_at")
    AND ("sent_at" IS NULL OR "failed_at" IS NULL OR "failed_at" >= "sent_at")
);

-- Standalone meetings must yield common executable tasks in any responsible
-- workstream, without a fake Project or bypass of Project parent/sprint FKs.
-- Retain the existing independent standalone-HR case and all Project tasks.
ALTER TABLE "tasks" DROP CONSTRAINT "tasks_nonproject_hr_scope_check";
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_nonproject_scope_check"
CHECK ("project_id" IS NOT NULL OR (
    ("workstream" = 'HR' OR "task_type" = 'MEETING')
    AND "parent_task_id" IS NULL AND "sprint_id" IS NULL
));

CREATE FUNCTION "prevent_meeting_status_history_mutation"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Meeting status history is append-only' USING ERRCODE = '23514';
END;
$$;
CREATE TRIGGER "meeting_history_append_only"
BEFORE UPDATE OR DELETE ON "meeting_status_history"
FOR EACH ROW EXECUTE FUNCTION "prevent_meeting_status_history_mutation"();
CREATE TRIGGER "meeting_history_no_truncate"
BEFORE TRUNCATE ON "meeting_status_history"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_meeting_status_history_mutation"();

COMMIT;
