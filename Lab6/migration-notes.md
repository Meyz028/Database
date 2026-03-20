# Звіт до лабораторної роботи №6: Міграції схем за допомогою Prisma ORM

**Мета:** Використати Prisma ORM для керування схемами, згенерувати та застосувати поступові зміни до існуючої бази даних PostgreSQL за допомогою міграцій.

В ході виконання роботи базу даних було синхронізовано з Prisma (створено базову міграцію з існуючих таблиць), після чого було виконано три ізольовані міграції для модифікації структури БД.

---

## Міграція 1: Додавання нової таблиці (`init-and-add-wishlist`)

**Опис:** Було створено нову таблицю `wishlist` (Список бажань), яка дозволяє клієнтам зберігати товари, які їм сподобалися. Таблиця має зв'язки "один-до-багатьох" з таблицями `customer` та `product`. Також було додано унікальний індекс на комбінацію `customer_id` та `product_id`, щоб уникнути дублювання однакових товарів у списку одного клієнта.

**Код ДО:**
*(Модель `wishlist` була відсутня в схемі)*

**Код ПІСЛЯ:**
Додано нову модель:
```prisma
model wishlist {
  wishlist_id Int       @id @default(autoincrement())
  customer_id Int
  product_id  Int
  added_at    DateTime? @default(now()) @db.Timestamp(6)
  customer    customer  @relation(fields: [customer_id], references: [customer_id], onDelete: Cascade, onUpdate: NoAction)
  product     product   @relation(fields: [product_id], references: [product_id], onDelete: Cascade, onUpdate: NoAction)

  @@unique([customer_id, product_id])
}
Міграція 2: Додавання нового поля (add-is-active-to-product)
Опис: Для того, щоб керувати наявністю товарів у продажу без їх фізичного видалення з бази даних, до таблиці product було додано логічне поле is_active (чи активний товар). За замовчуванням встановлено значення true.

Код ДО:

Фрагмент коду

model product {
  product_id     Int          @id @default(autoincrement())
  product_name   String       @db.VarChar(150)
  description    String?
  price          Decimal      @db.Decimal(10, 2)
  stock_quantity Int
  category_id    Int
  // ... зв'язки
}
Код ПІСЛЯ:

Фрагмент коду

model product {
  product_id     Int          @id @default(autoincrement())
  product_name   String       @db.VarChar(150)
  description    String?
  price          Decimal      @db.Decimal(10, 2)
  stock_quantity Int
  is_active      Boolean      @default(true) // <--- ДОДАНО ПОЛЕ
  category_id    Int
  // ... зв'язки
}
Міграція 3: Видалення поля (drop-category-description)
Опис: З таблиці category було видалено необов'язкове поле description, оскільки в поточній бізнес-логіці назви категорії (category_name) достатньо для ідентифікації типу товарів.

Код ДО:

Фрагмент коду

model category {
  category_id   Int       @id @default(autoincrement())
  category_name String    @unique @db.VarChar(100)
  description   String?   // <--- ПОЛЕ ПРИСУТНЄ
  product       product[]
}
Код ПІСЛЯ:

Фрагмент коду

model category {
  category_id   Int       @id @default(autoincrement())
  category_name String    @unique @db.VarChar(100)
  // Поле description успішно видалено зі схеми та бази даних
  product       product[]
}
Перевірка результатів (Тестування даних)
Для перевірки успішності внесених змін було використано Prisma Client для додавання запису в нову таблицю wishlist та зчитування активних товарів з таблиці product.

Тестовий скрипт (test.js):

JavaScript

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  // 1. Тестування таблиці Wishlist (Міграція 1)
  const newWishlistItem = await prisma.wishlist.create({
    data: {
      customer_id: 1, // Клієнт Олександр Петренко
      product_id: 2   // Ноутбук ASUS ROG
    }
  });
  console.log('Додано в список бажань:', newWishlistItem);

  // 2. Тестування поля is_active (Міграція 2)
  const activeProducts = await prisma.product.findMany({
    where: {
      is_active: true
    },
    select: {
      product_name: true,
      price: true,
      is_active: true
    }
  });
  console.log('Активні товари:', activeProducts);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });