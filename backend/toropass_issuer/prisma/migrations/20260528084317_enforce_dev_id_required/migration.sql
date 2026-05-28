/*
  Warnings:

  - Made the column `developer_id` on table `oauth_apps` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "oauth_apps" ALTER COLUMN "developer_id" SET NOT NULL;
