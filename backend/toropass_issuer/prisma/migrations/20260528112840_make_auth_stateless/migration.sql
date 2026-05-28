/*
  Warnings:

  - You are about to drop the column `access_expires_at` on the `user_sessions` table. All the data in the column will be lost.
  - You are about to drop the column `access_token` on the `user_sessions` table. All the data in the column will be lost.
  - You are about to drop the column `refresh_expires_at` on the `user_sessions` table. All the data in the column will be lost.

*/
-- DropIndex
DROP INDEX "user_sessions_access_token_key";

-- AlterTable
ALTER TABLE "user_sessions" DROP COLUMN "access_expires_at",
DROP COLUMN "access_token",
DROP COLUMN "refresh_expires_at";
