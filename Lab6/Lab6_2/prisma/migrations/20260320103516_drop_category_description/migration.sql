/*
  Warnings:

  - You are about to drop the column `description` on the `category` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "category" DROP COLUMN "description";

-- AlterTable
ALTER TABLE "orders" ALTER COLUMN "status" SET DEFAULT 'Нове';
