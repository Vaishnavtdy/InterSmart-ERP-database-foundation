BEGIN;

-- CreateEnum
CREATE TYPE "InfrastructureStatus" AS ENUM ('DRAFT', 'PLANNING', 'IN_PROGRESS', 'READY', 'IN_REVIEW', 'APPROVED', 'COMPLETED', 'ON_HOLD', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ServerType" AS ENUM ('APPLICATION', 'DATABASE', 'WEB', 'API', 'FILE_STORAGE', 'CACHE', 'PROXY', 'CI_CD', 'MONITORING', 'OTHER');

-- CreateEnum
CREATE TYPE "InfrastructureProvider" AS ENUM ('SELF_HOSTED', 'VPS', 'DEDICATED_SERVER', 'SHARED_HOSTING', 'HOSTINGER', 'GODADDY', 'DIGITALOCEAN', 'HETZNER', 'LINODE', 'OTHER');

-- CreateEnum
CREATE TYPE "DomainType" AS ENUM ('PRIMARY', 'SUBDOMAIN', 'API', 'ADMIN', 'STAGING', 'DEVELOPMENT', 'OTHER');

-- CreateEnum
CREATE TYPE "DomainStatus" AS ENUM ('PLANNED', 'ACTIVE', 'INACTIVE', 'EXPIRED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "DnsRecordType" AS ENUM ('A', 'AAAA', 'CNAME', 'MX', 'TXT', 'NS', 'SRV', 'CAA', 'OTHER');

-- CreateEnum
CREATE TYPE "SslCertificateType" AS ENUM ('LETS_ENCRYPT', 'COMMERCIAL', 'SELF_SIGNED', 'OTHER');

-- CreateEnum
CREATE TYPE "SslCertificateStatus" AS ENUM ('PENDING', 'ACTIVE', 'EXPIRING_SOON', 'EXPIRED', 'REVOKED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "SslRenewalMethod" AS ENUM ('CERTBOT', 'MANUAL', 'HOSTING_PANEL', 'OTHER');

-- CreateEnum
CREATE TYPE "GoLiveStatus" AS ENUM ('PLANNED', 'READY', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'ROLLED_BACK', 'CANCELLED');

-- CreateEnum
CREATE TYPE "GoLiveChecklistCategory" AS ENUM ('SERVER', 'DOMAIN', 'DNS', 'SSL', 'DATABASE', 'APPLICATION', 'FILES', 'BACKUP', 'EMAIL', 'PAYMENT', 'SECURITY', 'SEO', 'ANALYTICS', 'TESTING', 'CLIENT_APPROVAL', 'DOCUMENTATION', 'OTHER');

-- CreateEnum
CREATE TYPE "GoLiveChecklistStatus" AS ENUM ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'BLOCKED', 'NOT_APPLICABLE');

-- CreateEnum
CREATE TYPE "HandoverStatus" AS ENUM ('DRAFT', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "BackupType" AS ENUM ('DATABASE', 'FILES', 'SERVER', 'APPLICATION', 'CONFIGURATION', 'OTHER');

-- CreateEnum
CREATE TYPE "BackupStatus" AS ENUM ('NOT_CONFIGURED', 'ACTIVE', 'WARNING', 'FAILED', 'DISABLED');

-- AlterEnum
ALTER TYPE "ProjectResourceType" ADD VALUE 'INFRASTRUCTURE';

-- AlterEnum
ALTER TYPE "ProjectRole" ADD VALUE 'SYSTEM_ADMIN';

-- AlterEnum
ALTER TYPE "TaskWorkstream" ADD VALUE 'SYSTEM_ADMIN';

-- AlterTable
ALTER TABLE "development_deployments" ADD COLUMN     "server_id" UUID;

-- CreateTable
CREATE TABLE "project_infrastructure" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "version_number" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "status" "InfrastructureStatus" NOT NULL DEFAULT 'DRAFT',
    "infrastructure_notes" TEXT,
    "monitoring_enabled" BOOLEAN NOT NULL DEFAULT false,
    "monitoring_notes" TEXT,
    "monitoring_url" VARCHAR(2048),
    "created_by_id" UUID NOT NULL,
    "approved_by_id" UUID,
    "approved_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_infrastructure_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_servers" (
    "id" UUID NOT NULL,
    "project_infrastructure_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "server_type" "ServerType" NOT NULL DEFAULT 'OTHER',
    "provider" "InfrastructureProvider" NOT NULL DEFAULT 'OTHER',
    "hostname" VARCHAR(255),
    "ip_address" VARCHAR(45),
    "operating_system" VARCHAR(100),
    "os_version" VARCHAR(100),
    "environment" "DevelopmentEnvironmentType" NOT NULL DEFAULT 'OTHER',
    "region" VARCHAR(100),
    "datacenter" VARCHAR(100),
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "credential_reference" VARCHAR(255),
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_servers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_domains" (
    "id" UUID NOT NULL,
    "project_infrastructure_id" UUID NOT NULL,
    "server_id" UUID,
    "domain" VARCHAR(253) NOT NULL,
    "domain_type" "DomainType" NOT NULL DEFAULT 'OTHER',
    "environment" "DevelopmentEnvironmentType" NOT NULL DEFAULT 'OTHER',
    "provider" "InfrastructureProvider" NOT NULL DEFAULT 'OTHER',
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "status" "DomainStatus" NOT NULL DEFAULT 'PLANNED',
    "expires_at" TIMESTAMPTZ(6),
    "auto_renew" BOOLEAN NOT NULL DEFAULT false,
    "notes" TEXT,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_domains_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dns_records" (
    "id" UUID NOT NULL,
    "project_infrastructure_id" UUID NOT NULL,
    "project_domain_id" UUID NOT NULL,
    "record_type" "DnsRecordType" NOT NULL DEFAULT 'OTHER',
    "name" VARCHAR(255) NOT NULL,
    "value" TEXT NOT NULL,
    "ttl" INTEGER,
    "priority" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "dns_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ssl_certificates" (
    "id" UUID NOT NULL,
    "project_infrastructure_id" UUID NOT NULL,
    "project_domain_id" UUID,
    "certificate_name" VARCHAR(255) NOT NULL,
    "issuer" VARCHAR(255),
    "certificate_type" "SslCertificateType" NOT NULL DEFAULT 'OTHER',
    "status" "SslCertificateStatus" NOT NULL DEFAULT 'PENDING',
    "issued_at" TIMESTAMPTZ(6),
    "expires_at" TIMESTAMPTZ(6),
    "auto_renew" BOOLEAN NOT NULL DEFAULT false,
    "renewal_method" "SslRenewalMethod" NOT NULL DEFAULT 'OTHER',
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "ssl_certificates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_go_live" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "project_infrastructure_id" UUID NOT NULL,
    "deployment_id" UUID,
    "planned_date" TIMESTAMPTZ(6),
    "actual_date" TIMESTAMPTZ(6),
    "status" "GoLiveStatus" NOT NULL DEFAULT 'PLANNED',
    "production_url" VARCHAR(2048),
    "go_live_notes" TEXT,
    "rollback_notes" TEXT,
    "approved_by_id" UUID,
    "approved_at" TIMESTAMPTZ(6),
    "completed_by_id" UUID,
    "completed_at" TIMESTAMPTZ(6),
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_go_live_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "go_live_checklist_items" (
    "id" UUID NOT NULL,
    "project_go_live_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "category" "GoLiveChecklistCategory" NOT NULL DEFAULT 'OTHER',
    "status" "GoLiveChecklistStatus" NOT NULL DEFAULT 'PENDING',
    "is_required" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "assigned_to_id" UUID,
    "completed_by_id" UUID,
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "go_live_checklist_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "infrastructure_task_links" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "project_infrastructure_id" UUID,
    "project_server_id" UUID,
    "project_domain_id" UUID,
    "project_go_live_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "infrastructure_task_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "production_handovers" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "project_go_live_id" UUID NOT NULL,
    "handed_over_by_id" UUID NOT NULL,
    "received_by_id" UUID,
    "handover_date" TIMESTAMPTZ(6),
    "status" "HandoverStatus" NOT NULL DEFAULT 'DRAFT',
    "application_url" VARCHAR(2048),
    "admin_url" VARCHAR(2048),
    "documentation_completed" BOOLEAN NOT NULL DEFAULT false,
    "backup_configured" BOOLEAN NOT NULL DEFAULT false,
    "monitoring_configured" BOOLEAN NOT NULL DEFAULT false,
    "ssl_configured" BOOLEAN NOT NULL DEFAULT false,
    "domain_configured" BOOLEAN NOT NULL DEFAULT false,
    "notes" TEXT,
    "support_notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "production_handovers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "infrastructure_backups" (
    "id" UUID NOT NULL,
    "project_infrastructure_id" UUID NOT NULL,
    "server_id" UUID,
    "backup_type" "BackupType" NOT NULL DEFAULT 'OTHER',
    "provider" "InfrastructureProvider" NOT NULL DEFAULT 'OTHER',
    "frequency" VARCHAR(100),
    "retention_period" VARCHAR(100),
    "last_backup_at" TIMESTAMPTZ(6),
    "status" "BackupStatus" NOT NULL DEFAULT 'NOT_CONFIGURED',
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "infrastructure_backups_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "project_infrastructure_status_idx" ON "project_infrastructure"("status");

-- CreateIndex
CREATE INDEX "project_infrastructure_created_by_id_idx" ON "project_infrastructure"("created_by_id");

-- CreateIndex
CREATE INDEX "project_infrastructure_approved_by_id_idx" ON "project_infrastructure"("approved_by_id");

-- CreateIndex
CREATE INDEX "project_infrastructure_created_at_idx" ON "project_infrastructure"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "project_infrastructure_project_id_version_number_key" ON "project_infrastructure"("project_id", "version_number");

-- CreateIndex
CREATE UNIQUE INDEX "project_infrastructure_project_id_id_key" ON "project_infrastructure"("project_id", "id");

-- CreateIndex
CREATE INDEX "project_servers_project_infrastructure_id_is_active_idx" ON "project_servers"("project_infrastructure_id", "is_active");

-- CreateIndex
CREATE INDEX "project_servers_server_type_idx" ON "project_servers"("server_type");

-- CreateIndex
CREATE INDEX "project_servers_environment_idx" ON "project_servers"("environment");

-- CreateIndex
CREATE INDEX "project_servers_provider_idx" ON "project_servers"("provider");

-- CreateIndex
CREATE INDEX "project_servers_is_active_idx" ON "project_servers"("is_active");

-- CreateIndex
CREATE INDEX "project_servers_created_by_id_idx" ON "project_servers"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_servers_project_infrastructure_id_id_key" ON "project_servers"("project_infrastructure_id", "id");

-- CreateIndex
CREATE UNIQUE INDEX "project_domains_domain_key" ON "project_domains"("domain");

-- CreateIndex
CREATE INDEX "project_domains_status_idx" ON "project_domains"("status");

-- CreateIndex
CREATE INDEX "project_domains_environment_idx" ON "project_domains"("environment");

-- CreateIndex
CREATE INDEX "project_domains_server_id_idx" ON "project_domains"("server_id");

-- CreateIndex
CREATE INDEX "project_domains_created_by_id_idx" ON "project_domains"("created_by_id");

-- CreateIndex
CREATE INDEX "project_domains_expires_at_idx" ON "project_domains"("expires_at");

-- CreateIndex
CREATE UNIQUE INDEX "project_domains_project_infrastructure_id_id_key" ON "project_domains"("project_infrastructure_id", "id");

-- CreateIndex
CREATE INDEX "dns_records_project_infrastructure_id_idx" ON "dns_records"("project_infrastructure_id");

-- CreateIndex
CREATE INDEX "dns_records_project_domain_id_idx" ON "dns_records"("project_domain_id");

-- CreateIndex
CREATE INDEX "dns_records_record_type_idx" ON "dns_records"("record_type");

-- CreateIndex
CREATE INDEX "dns_records_name_idx" ON "dns_records"("name");

-- CreateIndex
CREATE INDEX "dns_records_is_active_idx" ON "dns_records"("is_active");

-- CreateIndex
CREATE INDEX "ssl_certificates_project_infrastructure_id_idx" ON "ssl_certificates"("project_infrastructure_id");

-- CreateIndex
CREATE INDEX "ssl_certificates_project_domain_id_idx" ON "ssl_certificates"("project_domain_id");

-- CreateIndex
CREATE INDEX "ssl_certificates_status_idx" ON "ssl_certificates"("status");

-- CreateIndex
CREATE INDEX "ssl_certificates_expires_at_idx" ON "ssl_certificates"("expires_at");

-- CreateIndex
CREATE INDEX "project_go_live_project_id_status_idx" ON "project_go_live"("project_id", "status");

-- CreateIndex
CREATE INDEX "project_go_live_project_infrastructure_id_idx" ON "project_go_live"("project_infrastructure_id");

-- CreateIndex
CREATE INDEX "project_go_live_deployment_id_idx" ON "project_go_live"("deployment_id");

-- CreateIndex
CREATE INDEX "project_go_live_status_idx" ON "project_go_live"("status");

-- CreateIndex
CREATE INDEX "project_go_live_planned_date_idx" ON "project_go_live"("planned_date");

-- CreateIndex
CREATE INDEX "project_go_live_actual_date_idx" ON "project_go_live"("actual_date");

-- CreateIndex
CREATE INDEX "project_go_live_approved_by_id_idx" ON "project_go_live"("approved_by_id");

-- CreateIndex
CREATE INDEX "project_go_live_completed_by_id_idx" ON "project_go_live"("completed_by_id");

-- CreateIndex
CREATE INDEX "project_go_live_created_by_id_idx" ON "project_go_live"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_go_live_project_id_id_key" ON "project_go_live"("project_id", "id");

-- CreateIndex
CREATE INDEX "go_live_checklist_items_project_go_live_id_sort_order_idx" ON "go_live_checklist_items"("project_go_live_id", "sort_order");

-- CreateIndex
CREATE INDEX "go_live_checklist_items_status_idx" ON "go_live_checklist_items"("status");

-- CreateIndex
CREATE INDEX "go_live_checklist_items_category_idx" ON "go_live_checklist_items"("category");

-- CreateIndex
CREATE INDEX "go_live_checklist_items_assigned_to_id_idx" ON "go_live_checklist_items"("assigned_to_id");

-- CreateIndex
CREATE INDEX "go_live_checklist_items_completed_by_id_idx" ON "go_live_checklist_items"("completed_by_id");

-- CreateIndex
CREATE INDEX "infrastructure_task_links_task_id_idx" ON "infrastructure_task_links"("task_id");

-- CreateIndex
CREATE INDEX "infrastructure_task_links_project_infrastructure_id_idx" ON "infrastructure_task_links"("project_infrastructure_id");

-- CreateIndex
CREATE INDEX "infrastructure_task_links_project_server_id_idx" ON "infrastructure_task_links"("project_server_id");

-- CreateIndex
CREATE INDEX "infrastructure_task_links_project_domain_id_idx" ON "infrastructure_task_links"("project_domain_id");

-- CreateIndex
CREATE INDEX "infrastructure_task_links_project_go_live_id_idx" ON "infrastructure_task_links"("project_go_live_id");

-- CreateIndex
CREATE INDEX "production_handovers_project_id_idx" ON "production_handovers"("project_id");

-- CreateIndex
CREATE INDEX "production_handovers_project_go_live_id_idx" ON "production_handovers"("project_go_live_id");

-- CreateIndex
CREATE INDEX "production_handovers_status_idx" ON "production_handovers"("status");

-- CreateIndex
CREATE INDEX "production_handovers_handover_date_idx" ON "production_handovers"("handover_date");

-- CreateIndex
CREATE INDEX "production_handovers_handed_over_by_id_idx" ON "production_handovers"("handed_over_by_id");

-- CreateIndex
CREATE INDEX "production_handovers_received_by_id_idx" ON "production_handovers"("received_by_id");

-- CreateIndex
CREATE INDEX "infrastructure_backups_project_infrastructure_id_idx" ON "infrastructure_backups"("project_infrastructure_id");

-- CreateIndex
CREATE INDEX "infrastructure_backups_server_id_idx" ON "infrastructure_backups"("server_id");

-- CreateIndex
CREATE INDEX "infrastructure_backups_status_idx" ON "infrastructure_backups"("status");

-- CreateIndex
CREATE INDEX "infrastructure_backups_last_backup_at_idx" ON "infrastructure_backups"("last_backup_at");

-- CreateIndex
CREATE INDEX "infrastructure_backups_backup_type_idx" ON "infrastructure_backups"("backup_type");

-- CreateIndex
CREATE INDEX "infrastructure_backups_provider_idx" ON "infrastructure_backups"("provider");

-- CreateIndex
CREATE INDEX "development_deployments_server_id_idx" ON "development_deployments"("server_id");

-- AddForeignKey
ALTER TABLE "development_deployments" ADD CONSTRAINT "development_deployments_server_id_fkey" FOREIGN KEY ("server_id") REFERENCES "project_servers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_infrastructure" ADD CONSTRAINT "project_infrastructure_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_infrastructure" ADD CONSTRAINT "project_infrastructure_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_infrastructure" ADD CONSTRAINT "project_infrastructure_approved_by_id_fkey" FOREIGN KEY ("approved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_servers" ADD CONSTRAINT "project_servers_project_infrastructure_id_fkey" FOREIGN KEY ("project_infrastructure_id") REFERENCES "project_infrastructure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_servers" ADD CONSTRAINT "project_servers_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_domains" ADD CONSTRAINT "project_domains_project_infrastructure_id_fkey" FOREIGN KEY ("project_infrastructure_id") REFERENCES "project_infrastructure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_domains" ADD CONSTRAINT "project_domains_project_infrastructure_id_server_id_fkey" FOREIGN KEY ("project_infrastructure_id", "server_id") REFERENCES "project_servers"("project_infrastructure_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "project_domains" ADD CONSTRAINT "project_domains_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dns_records" ADD CONSTRAINT "dns_records_project_infrastructure_id_fkey" FOREIGN KEY ("project_infrastructure_id") REFERENCES "project_infrastructure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dns_records" ADD CONSTRAINT "dns_records_project_infrastructure_id_project_domain_id_fkey" FOREIGN KEY ("project_infrastructure_id", "project_domain_id") REFERENCES "project_domains"("project_infrastructure_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ssl_certificates" ADD CONSTRAINT "ssl_certificates_project_infrastructure_id_fkey" FOREIGN KEY ("project_infrastructure_id") REFERENCES "project_infrastructure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ssl_certificates" ADD CONSTRAINT "ssl_certificates_project_infrastructure_id_project_domain__fkey" FOREIGN KEY ("project_infrastructure_id", "project_domain_id") REFERENCES "project_domains"("project_infrastructure_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "project_go_live" ADD CONSTRAINT "project_go_live_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_go_live" ADD CONSTRAINT "project_go_live_project_id_project_infrastructure_id_fkey" FOREIGN KEY ("project_id", "project_infrastructure_id") REFERENCES "project_infrastructure"("project_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "project_go_live" ADD CONSTRAINT "project_go_live_deployment_id_fkey" FOREIGN KEY ("deployment_id") REFERENCES "development_deployments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_go_live" ADD CONSTRAINT "project_go_live_approved_by_id_fkey" FOREIGN KEY ("approved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_go_live" ADD CONSTRAINT "project_go_live_completed_by_id_fkey" FOREIGN KEY ("completed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_go_live" ADD CONSTRAINT "project_go_live_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "go_live_checklist_items" ADD CONSTRAINT "go_live_checklist_items_project_go_live_id_fkey" FOREIGN KEY ("project_go_live_id") REFERENCES "project_go_live"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "go_live_checklist_items" ADD CONSTRAINT "go_live_checklist_items_assigned_to_id_fkey" FOREIGN KEY ("assigned_to_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "go_live_checklist_items" ADD CONSTRAINT "go_live_checklist_items_completed_by_id_fkey" FOREIGN KEY ("completed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "infrastructure_task_links" ADD CONSTRAINT "infrastructure_task_links_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "infrastructure_task_links" ADD CONSTRAINT "infrastructure_task_links_project_infrastructure_id_fkey" FOREIGN KEY ("project_infrastructure_id") REFERENCES "project_infrastructure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "infrastructure_task_links" ADD CONSTRAINT "infrastructure_task_links_project_server_id_fkey" FOREIGN KEY ("project_server_id") REFERENCES "project_servers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "infrastructure_task_links" ADD CONSTRAINT "infrastructure_task_links_project_domain_id_fkey" FOREIGN KEY ("project_domain_id") REFERENCES "project_domains"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "infrastructure_task_links" ADD CONSTRAINT "infrastructure_task_links_project_go_live_id_fkey" FOREIGN KEY ("project_go_live_id") REFERENCES "project_go_live"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "production_handovers" ADD CONSTRAINT "production_handovers_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "production_handovers" ADD CONSTRAINT "production_handovers_project_id_project_go_live_id_fkey" FOREIGN KEY ("project_id", "project_go_live_id") REFERENCES "project_go_live"("project_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "production_handovers" ADD CONSTRAINT "production_handovers_handed_over_by_id_fkey" FOREIGN KEY ("handed_over_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "production_handovers" ADD CONSTRAINT "production_handovers_received_by_id_fkey" FOREIGN KEY ("received_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "infrastructure_backups" ADD CONSTRAINT "infrastructure_backups_project_infrastructure_id_fkey" FOREIGN KEY ("project_infrastructure_id") REFERENCES "project_infrastructure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "infrastructure_backups" ADD CONSTRAINT "infrastructure_backups_project_infrastructure_id_server_id_fkey" FOREIGN KEY ("project_infrastructure_id", "server_id") REFERENCES "project_servers"("project_infrastructure_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

ALTER TABLE "project_infrastructure" ADD CONSTRAINT "project_infrastructure_version_positive_check"
CHECK ("version_number" > 0);
ALTER TABLE "project_infrastructure" ADD CONSTRAINT "project_infrastructure_approval_pair_check"
CHECK (("approved_by_id" IS NULL) = ("approved_at" IS NULL));
ALTER TABLE "dns_records" ADD CONSTRAINT "dns_records_ttl_nonnegative_check"
CHECK ("ttl" IS NULL OR "ttl" >= 0);
ALTER TABLE "dns_records" ADD CONSTRAINT "dns_records_priority_range_check"
CHECK ("priority" IS NULL OR "priority" BETWEEN 0 AND 65535);
ALTER TABLE "ssl_certificates" ADD CONSTRAINT "ssl_certificates_date_order_check"
CHECK ("issued_at" IS NULL OR "expires_at" IS NULL OR "expires_at" >= "issued_at");
ALTER TABLE "project_go_live" ADD CONSTRAINT "project_go_live_approval_pair_check"
CHECK (("approved_by_id" IS NULL) = ("approved_at" IS NULL));
ALTER TABLE "project_go_live" ADD CONSTRAINT "project_go_live_completion_pair_check"
CHECK (("completed_by_id" IS NULL) = ("completed_at" IS NULL));
ALTER TABLE "go_live_checklist_items" ADD CONSTRAINT "go_live_checklist_items_order_nonnegative_check"
CHECK ("sort_order" >= 0);
ALTER TABLE "go_live_checklist_items" ADD CONSTRAINT "go_live_checklist_items_completion_pair_check"
CHECK (("completed_by_id" IS NULL) = ("completed_at" IS NULL));

-- Domain names are case-insensitive; future writers still normalize IDNA,
-- trailing dots and validate host-only names. No duplicate registry table.
CREATE UNIQUE INDEX "project_domains_case_insensitive_key"
ON "project_domains" (LOWER("domain"));

-- Match QA nullable-context linking without reserving a real UUID.
-- Prisma cannot express these indexes; retain them in migration SQL.
CREATE UNIQUE INDEX "infrastructure_task_links_context_key"
ON "infrastructure_task_links" (
    "task_id",
    COALESCE("project_infrastructure_id"::text, ''),
    COALESCE("project_server_id"::text, ''),
    COALESCE("project_domain_id"::text, ''),
    COALESCE("project_go_live_id"::text, '')
);

COMMIT;
