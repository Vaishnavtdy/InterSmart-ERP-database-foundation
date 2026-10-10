# Architecture

InterSmart ERP is a single-organization internal system for InterSmart
Technologies. The planned application stack is a NestJS API, a Next.js and
TypeScript web app, PostgreSQL with Prisma, MinIO for file storage, and JWT
authentication with Argon2. Redis and BullMQ may be considered later.

This repository step establishes the database package and documents the
architecture without implementing API or frontend modules.
