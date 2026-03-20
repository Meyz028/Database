# Звіт з нормалізації бази даних (Лабораторна робота №5)

### 1. Аналіз початкової схеми (Лабораторна 2)
Аналізуючи початкову схему, було виявлено кілька аномалій та порушень нормальних форм. 

**Найвища нормальна форма початкової схеми:** Ненормалізована форма (0НФ / UNF).
**Пояснення:** Схема не відповідає навіть Першій нормальній формі (1НФ) через порушення принципу атомарності в таблиці `Customer`.

* **Проблемна таблиця Customer (Порушення 1НФ):** Поле `address` містить складені дані (місто, вулиця, будинок, квартира в одному рядку). Це порушує принцип атомарності, що унеможливлює повноцінний пошук чи фільтрацію за окремими елементами адреси.
* **Проблемна таблиця Orders (Порушення 3НФ):** * Поле `total_amount` є обчислюваним. Його значення безпосередньо залежить від суми вартості товарів у таблиці `OrderItem`. Це створює транзитивну залежність.
    * Поле `payment_method` як простий атрибут не дозволяє повноцінно фіксувати деталі платежу (час транзакції, точну суму), що вимагає винесення його в окрему сутність.

### 2. Функціональні залежності початкової схеми
Мінімальний набір функціональних залежностей (ФЗ) для проблемних таблиць:

* **Customer:** `customer_id` → `first_name`, `last_name`, `email`, `phone`, `address`, `registration_date`
* **Orders:** `order_id` → `customer_id`, `shipping_id`, `order_date`, `status`, `payment_method`, `total_amount`
* **Транзитивна залежність в Orders:** `order_id` → `OrderItem (quantity, unit_price)` → `total_amount`

### 3. Етапи нормалізації (Проміжні стани таблиць)

**Початковий стан (0НФ):**
* `Customer` (customer_id (PK), first_name, last_name, email, phone, address, registration_date)
* `Orders` (order_id (PK), customer_id (FK), shipping_id (FK), order_date, status, payment_method, total_amount)

**Крок 1: Перехід до 1НФ (Забезпечення атомарності)**
* **Виправлення:** Розділяємо складене поле `address` на окремі атомарні стовпці: `city`, `street`, `building`, `apartment`.
* **Структура таблиць після 1НФ:**
  * `Customer` (customer_id (PK), first_name, last_name, email, phone, city, street, building, apartment, registration_date)
  * `Orders` (без змін)

**Крок 2: Перехід до 2НФ (Усунення часткових залежностей)**
* **Перевірка:** Усі таблиці в нашій базі мають прості (одинарні) первинні ключі. Усі неключові атрибути повністю залежать від первинного ключа в цілому. 
* **Структура таблиць після 2НФ:** Схема залишається ідентичною до 1НФ.

**Крок 3: Перехід до 3НФ (Усунення транзитивних залежностей)**
* **Виправлення 1:** Видаляємо обчислюване поле `total_amount` з таблиці `Orders`, оскільки воно транзитивно залежить від товарів у замовленні.
* **Виправлення 2:** Виносимо інформацію про оплату в окрему таблицю `Payment`. Тепер усі атрибути в `Orders` залежать виключно від первинного ключа `order_id`.
* **Структура таблиць після 3НФ (Фінальна):**
  * `Customer` (customer_id (PK), first_name, last_name, email, phone, city, street, building, apartment, registration_date)
  * `Orders` (order_id (PK), customer_id (FK), shipping_id (FK), order_date, status)
  * `Payment` (payment_id (PK), order_id (FK), method, amount, payment_date)

---

### 4. Трансформація існуючого дизайну (команди ALTER TABLE)

Для трансформації таблиці **Customer** (до 1НФ):
```sql
ALTER TABLE Customer 
ADD COLUMN city VARCHAR(50),
ADD COLUMN street VARCHAR(100),
ADD COLUMN building VARCHAR(10),
ADD COLUMN apartment VARCHAR(10);

-- Перенесення даних (умовно) та видалення старого неатомарного поля
ALTER TABLE Customer DROP COLUMN address;
-- Видалення транзитивного поля обчислюваної суми
ALTER TABLE Orders DROP COLUMN total_amount;

-- Створення нової таблиці для платежів та перенесення даних
CREATE TABLE IF NOT EXISTS Payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES Orders(order_id) ON DELETE CASCADE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    method payment_method_enum NOT NULL,
    amount DECIMAL(10,2) NOT NULL
);

-- Видалення застарілого атрибута методу оплати з Orders
ALTER TABLE Orders DROP COLUMN payment_method;
```
### 5. Фінальні DDL-скрипти для переробленої схеми (3НФ)

-- Створення необхідних типів даних (ENUM)
CREATE TYPE order_status_enum AS ENUM ('Нове', 'В обробці', 'Відправлено', 'Доставлено', 'Скасовано');
CREATE TYPE payment_method_enum AS ENUM ('Картка', 'Готівка', 'Apple Pay', 'Google Pay', 'PayPal');

-- ==========================================
-- 1НФ: Таблиця Customer з атомарною адресою
-- ==========================================
CREATE TABLE Customer (
    customer_id SERIAL PRIMARY KEY, 
    first_name VARCHAR(50) NOT NULL, 
    last_name VARCHAR(50) NOT NULL, 
    email VARCHAR(100) UNIQUE NOT NULL, 
    phone VARCHAR(20) NOT NULL, 
    city VARCHAR(50) NOT NULL,
    street VARCHAR(100) NOT NULL,
    building VARCHAR(10) NOT NULL,
    apartment VARCHAR(10), -- Може бути NULL для приватних будинків
    registration_date DATE DEFAULT CURRENT_DATE
);

-- ==========================================
-- 3НФ: Таблиця Orders без транзитивних залежностей
-- ==========================================
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customer(customer_id) ON DELETE CASCADE, 
    shipping_id INT NOT NULL REFERENCES ShippingMethod(shipping_id), 
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    status order_status_enum DEFAULT 'Нове'
);

-- ==========================================
-- 3НФ: Нова таблиця Payment для деталей оплати
-- ==========================================
CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES Orders(order_id) ON DELETE CASCADE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    method payment_method_enum NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0)
);

-- ==========================================
-- Додаткова таблиця Review 
-- ==========================================
CREATE TABLE Review (
    review_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES Product(product_id) ON DELETE CASCADE,
    customer_id INT NOT NULL REFERENCES Customer(customer_id) ON DELETE CASCADE,
    rating NUMERIC(3, 2) CHECK (rating >= 0 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);