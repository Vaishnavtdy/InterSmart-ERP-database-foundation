BEGIN;

-- CreateEnum
CREATE TYPE "ProjectResourceType" AS ENUM ('BRAND_BOOK', 'LOGO', 'DOMAIN', 'BROCHURE', 'PROPOSAL', 'BUSINESS_ANALYSIS', 'UI', 'UX', 'DEVELOPMENT', 'QA', 'OTHER');

-- CreateTable
CREATE TABLE "files" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "file_series_id" UUID NOT NULL,
    "uploaded_by_id" UUID NOT NULL,
    "file_name" VARCHAR(255) NOT NULL,
    "original_name" VARCHAR(255) NOT NULL,
    "storage_key" VARCHAR(1024) NOT NULL,
    "bucket" VARCHAR(255) NOT NULL,
    "mime_type" VARCHAR(255) NOT NULL,
    "size_bytes" BIGINT NOT NULL,
    "checksum" VARCHAR(255),
    "version" INTEGER NOT NULL DEFAULT 1,
    "is_current" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "files_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_resources" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "file_id" UUID NOT NULL,
    "resource_series_id" UUID NOT NULL,
    "resource_type" "ProjectResourceType" NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "version" INTEGER NOT NULL DEFAULT 1,
    "is_current" BOOLEAN NOT NULL DEFAULT true,
    "uploaded_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_resources_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "files_storage_key_key" ON "files"("storage_key");

-- CreateIndex
CREATE INDEX "files_project_id_is_current_deleted_at_idx" ON "files"("project_id", "is_current", "deleted_at");

-- CreateIndex
CREATE INDEX "files_uploaded_by_id_idx" ON "files"("uploaded_by_id");

-- CreateIndex
CREATE INDEX "files_checksum_idx" ON "files"("checksum");

-- CreateIndex
CREATE INDEX "files_created_at_idx" ON "files"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "files_project_id_file_series_id_version_key" ON "files"("project_id", "file_series_id", "version");

-- CreateIndex
CREATE UNIQUE INDEX "files_project_id_id_key" ON "files"("project_id", "id");

-- CreateIndex
CREATE INDEX "project_resources_project_id_resource_type_is_current_idx" ON "project_resources"("project_id", "resource_type", "is_current");

-- CreateIndex
CREATE INDEX "project_resources_file_id_idx" ON "project_resources"("file_id");

-- CreateIndex
CREATE INDEX "project_resources_resource_type_idx" ON "project_resources"("resource_type");

-- CreateIndex
CREATE INDEX "project_resources_uploaded_by_id_idx" ON "project_resources"("uploaded_by_id");

-- CreateIndex
CREATE INDEX "project_resources_created_at_idx" ON "project_resources"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "project_resources_project_id_resource_type_resource_series__key" ON "project_resources"("project_id", "resource_type", "resource_series_id", "version");

-- AddForeignKey
ALTER TABLE "files" ADD CONSTRAINT "files_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "files" ADD CONSTRAINT "files_uploaded_by_id_fkey" FOREIGN KEY ("uploaded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_resources" ADD CONSTRAINT "project_resources_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_resources" ADD CONSTRAINT "project_resources_project_id_file_id_fkey" FOREIGN KEY ("project_id", "file_id") REFERENCES "files"("project_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "project_resources" ADD CONSTRAINT "project_resources_uploaded_by_id_fkey" FOREIGN KEY ("uploaded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Numeric metadata and soft-delete/current-state integrity.
ALTER TABLE "files" ADD CONSTRAINT "files_size_bytes_nonnegative_check"
CHECK ("size_bytes" >= 0);

ALTER TABLE "files" ADD CONSTRAINT "files_version_positive_check"
CHECK ("version" > 0);

ALTER TABLE "files" ADD CONSTRAINT "files_deleted_not_current_check"
CHECK ("deleted_at" IS NULL OR NOT "is_current");

ALTER TABLE "project_resources" ADD CONSTRAINT "project_resources_version_positive_check"
CHECK ("version" > 0);

COMMIT;
