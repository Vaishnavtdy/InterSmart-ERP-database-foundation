BEGIN;

-- CreateEnum
CREATE TYPE "AuditAction" AS ENUM ('CREATE', 'UPDATE', 'DELETE', 'VIEW', 'EXPORT', 'LOGIN', 'LOGOUT', 'LOGIN_FAILED', 'PASSWORD_CHANGED', 'PASSWORD_RESET', 'PERMISSION_CHANGED', 'ROLE_CHANGED', 'STATUS_CHANGED', 'APPROVAL', 'REJECTION', 'DOWNLOAD', 'UPLOAD', 'OTHER');

-- CreateEnum
CREATE TYPE "UserActivityType" AS ENUM ('LOGIN', 'LOGOUT', 'VIEW', 'CREATE', 'UPDATE', 'DELETE', 'EXPORT', 'DOWNLOAD', 'UPLOAD', 'SEARCH', 'OTHER');

-- CreateEnum
CREATE TYPE "AuthenticationEventType" AS ENUM ('LOGIN', 'LOGOUT', 'LOGIN_FAILED', 'PASSWORD_CHANGED', 'PASSWORD_RESET_REQUESTED', 'PASSWORD_RESET_COMPLETED', 'ACCOUNT_LOCKED', 'ACCOUNT_UNLOCKED', 'SESSION_EXPIRED', 'MFA_SUCCESS', 'MFA_FAILED', 'OTHER');

-- CreateEnum
CREATE TYPE "SecurityEventType" AS ENUM ('SUSPICIOUS_LOGIN', 'MULTIPLE_LOGIN_FAILURES', 'UNAUTHORIZED_ACCESS', 'PERMISSION_DENIED', 'ACCOUNT_LOCKED', 'SESSION_REVOKED', 'UNUSUAL_ACTIVITY', 'SECURITY_CONFIGURATION_CHANGED', 'OTHER');

-- CreateEnum
CREATE TYPE "SecurityEventSeverity" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "action" "AuditAction" NOT NULL,
    "entity_type" VARCHAR(64) NOT NULL,
    "entity_id" UUID,
    "description" TEXT,
    "ip_address" INET,
    "user_agent" VARCHAR(2048),
    "request_id" VARCHAR(128),
    "metadata" JSONB,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_activity_logs" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "activity_type" "UserActivityType" NOT NULL,
    "entity_type" VARCHAR(64),
    "entity_id" UUID,
    "description" TEXT,
    "ip_address" INET,
    "user_agent" VARCHAR(2048),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_activity_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "authentication_events" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "event_type" "AuthenticationEventType" NOT NULL,
    "success" BOOLEAN NOT NULL,
    "ip_address" INET,
    "user_agent" VARCHAR(2048),
    "failure_reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "authentication_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_sessions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "session_identifier" UUID NOT NULL,
    "ip_address" INET,
    "user_agent" VARCHAR(2048),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_activity_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "revoked_at" TIMESTAMPTZ(6),
    "revoked_by_id" UUID,
    "revoke_reason" TEXT,

    CONSTRAINT "user_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "security_events" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "event_type" "SecurityEventType" NOT NULL,
    "severity" "SecurityEventSeverity" NOT NULL,
    "description" TEXT NOT NULL,
    "ip_address" INET,
    "user_agent" VARCHAR(2048),
    "entity_type" VARCHAR(64),
    "entity_id" UUID,
    "metadata" JSONB,
    "resolved_at" TIMESTAMPTZ(6),
    "resolved_by_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "security_events_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "audit_logs_user_id_created_at_idx" ON "audit_logs"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "audit_logs_entity_type_entity_id_created_at_idx" ON "audit_logs"("entity_type", "entity_id", "created_at");

-- CreateIndex
CREATE INDEX "audit_logs_entity_id_idx" ON "audit_logs"("entity_id");

-- CreateIndex
CREATE INDEX "audit_logs_action_created_at_idx" ON "audit_logs"("action", "created_at");

-- CreateIndex
CREATE INDEX "audit_logs_created_at_idx" ON "audit_logs"("created_at");

-- CreateIndex
CREATE INDEX "audit_logs_request_id_idx" ON "audit_logs"("request_id");

-- CreateIndex
CREATE INDEX "user_activity_logs_user_id_created_at_idx" ON "user_activity_logs"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "user_activity_logs_created_at_idx" ON "user_activity_logs"("created_at");

-- CreateIndex
CREATE INDEX "user_activity_logs_entity_type_entity_id_created_at_idx" ON "user_activity_logs"("entity_type", "entity_id", "created_at");

-- CreateIndex
CREATE INDEX "user_activity_logs_entity_id_idx" ON "user_activity_logs"("entity_id");

-- CreateIndex
CREATE INDEX "authentication_events_user_id_created_at_idx" ON "authentication_events"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "authentication_events_event_type_created_at_idx" ON "authentication_events"("event_type", "created_at");

-- CreateIndex
CREATE INDEX "authentication_events_created_at_idx" ON "authentication_events"("created_at");

-- CreateIndex
CREATE INDEX "authentication_events_success_created_at_idx" ON "authentication_events"("success", "created_at");

-- CreateIndex
CREATE UNIQUE INDEX "user_sessions_session_identifier_key" ON "user_sessions"("session_identifier");

-- CreateIndex
CREATE INDEX "user_sessions_user_id_created_at_idx" ON "user_sessions"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "user_sessions_expires_at_idx" ON "user_sessions"("expires_at");

-- CreateIndex
CREATE INDEX "user_sessions_revoked_at_idx" ON "user_sessions"("revoked_at");

-- CreateIndex
CREATE INDEX "user_sessions_last_activity_at_idx" ON "user_sessions"("last_activity_at");

-- CreateIndex
CREATE INDEX "user_sessions_revoked_by_id_idx" ON "user_sessions"("revoked_by_id");

-- CreateIndex
CREATE INDEX "user_sessions_created_at_idx" ON "user_sessions"("created_at");

-- CreateIndex
CREATE INDEX "security_events_user_id_created_at_idx" ON "security_events"("user_id", "created_at");

-- CreateIndex
CREATE INDEX "security_events_event_type_created_at_idx" ON "security_events"("event_type", "created_at");

-- CreateIndex
CREATE INDEX "security_events_severity_created_at_idx" ON "security_events"("severity", "created_at");

-- CreateIndex
CREATE INDEX "security_events_created_at_idx" ON "security_events"("created_at");

-- CreateIndex
CREATE INDEX "security_events_resolved_at_severity_created_at_idx" ON "security_events"("resolved_at", "severity", "created_at");

-- CreateIndex
CREATE INDEX "security_events_resolved_by_id_idx" ON "security_events"("resolved_by_id");

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_activity_logs" ADD CONSTRAINT "user_activity_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "authentication_events" ADD CONSTRAINT "authentication_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_sessions" ADD CONSTRAINT "user_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_sessions" ADD CONSTRAINT "user_sessions_revoked_by_id_fkey" FOREIGN KEY ("revoked_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "security_events" ADD CONSTRAINT "security_events_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "security_events" ADD CONSTRAINT "security_events_resolved_by_id_fkey" FOREIGN KEY ("resolved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Shape/integrity only, not a sanitizer: future writers must allowlist safe
-- context and redact credentials, confidential data and untrusted free text.
ALTER TABLE "audit_logs"
  ADD CONSTRAINT "audit_log_entity_type_check"
    CHECK (length(btrim("entity_type")) > 0),
  ADD CONSTRAINT "audit_log_request_id_check"
    CHECK ("request_id" IS NULL OR length(btrim("request_id")) > 0),
  ADD CONSTRAINT "audit_log_metadata_object_check"
    CHECK ("metadata" IS NULL OR jsonb_typeof("metadata") = 'object');

ALTER TABLE "user_activity_logs"
  ADD CONSTRAINT "user_activity_entity_type_check"
    CHECK ("entity_type" IS NULL OR length(btrim("entity_type")) > 0),
  ADD CONSTRAINT "user_activity_entity_reference_check"
    CHECK ("entity_id" IS NULL OR "entity_type" IS NOT NULL);

ALTER TABLE "authentication_events"
  ADD CONSTRAINT "authentication_event_outcome_check"
    CHECK (
      ("event_type" NOT IN ('LOGIN_FAILED', 'MFA_FAILED') OR NOT "success")
      AND ("event_type" <> 'MFA_SUCCESS' OR "success")
    );

ALTER TABLE "user_sessions"
  ADD CONSTRAINT "user_session_expiry_check"
    CHECK ("expires_at" > "created_at"),
  ADD CONSTRAINT "user_session_activity_time_check"
    CHECK ("last_activity_at" >= "created_at"),
  ADD CONSTRAINT "user_session_revocation_time_check"
    CHECK ("revoked_at" IS NULL OR "revoked_at" >= "created_at"),
  ADD CONSTRAINT "user_session_revocation_context_check"
    CHECK (
      ("revoked_by_id" IS NULL AND "revoke_reason" IS NULL)
      OR "revoked_at" IS NOT NULL
    );

ALTER TABLE "security_events"
  ADD CONSTRAINT "security_event_description_check"
    CHECK (length(btrim("description")) > 0),
  ADD CONSTRAINT "security_event_entity_type_check"
    CHECK ("entity_type" IS NULL OR length(btrim("entity_type")) > 0),
  ADD CONSTRAINT "security_event_entity_reference_check"
    CHECK ("entity_id" IS NULL OR "entity_type" IS NOT NULL),
  ADD CONSTRAINT "security_event_metadata_object_check"
    CHECK ("metadata" IS NULL OR jsonb_typeof("metadata") = 'object'),
  ADD CONSTRAINT "security_event_resolution_time_check"
    CHECK ("resolved_at" IS NULL OR "resolved_at" >= "created_at"),
  ADD CONSTRAINT "security_event_resolution_actor_check"
    CHECK ("resolved_by_id" IS NULL OR "resolved_at" IS NOT NULL);

-- inet supports both address families. Store a host, not a network range.
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_log_ip_host_check"
  CHECK ("ip_address" IS NULL OR masklen("ip_address") = CASE family("ip_address") WHEN 4 THEN 32 ELSE 128 END);
ALTER TABLE "user_activity_logs" ADD CONSTRAINT "user_activity_ip_host_check"
  CHECK ("ip_address" IS NULL OR masklen("ip_address") = CASE family("ip_address") WHEN 4 THEN 32 ELSE 128 END);
ALTER TABLE "authentication_events" ADD CONSTRAINT "authentication_event_ip_host_check"
  CHECK ("ip_address" IS NULL OR masklen("ip_address") = CASE family("ip_address") WHEN 4 THEN 32 ELSE 128 END);
ALTER TABLE "user_sessions" ADD CONSTRAINT "user_session_ip_host_check"
  CHECK ("ip_address" IS NULL OR masklen("ip_address") = CASE family("ip_address") WHEN 4 THEN 32 ELSE 128 END);
ALTER TABLE "security_events" ADD CONSTRAINT "security_event_ip_host_check"
  CHECK ("ip_address" IS NULL OR masklen("ip_address") = CASE family("ip_address") WHEN 4 THEN 32 ELSE 128 END);

COMMIT;
