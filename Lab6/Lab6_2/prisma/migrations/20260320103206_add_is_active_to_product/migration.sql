-- AlterTable
ALTER TABLE "orders" ALTER COLUMN "status" SET DEFAULT 'Нове';

-- AlterTable
ALTER TABLE "product" ADD COLUMN     "is_active" BOOLEAN NOT NULL DEFAULT true;
