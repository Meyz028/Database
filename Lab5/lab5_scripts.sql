-- ====================================================================
-- ЧАСТИНА 1: СТВОРЕННЯ ПОЧАТКОВОЇ БАЗИ З ЛАБОРАТОРНОЇ 2
-- ====================================================================

-- Очищення перед запуском (щоб можна було запускати скрипт багато разів)
DROP TABLE IF EXISTS Payment CASCADE;
DROP TABLE IF EXISTS Review CASCADE;
DROP TABLE IF EXISTS OrderItem CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS ProductTag CASCADE;
DROP TABLE IF EXISTS Product CASCADE;
DROP TABLE IF EXISTS Tag CASCADE;
DROP TABLE IF EXISTS ShippingMethod CASCADE;
DROP TABLE IF EXISTS Category CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TYPE IF EXISTS order_status_enum CASCADE;
DROP TYPE IF EXISTS payment_method_enum CASCADE;

-- Створюємо тип для статусу замовлення
CREATE TYPE order_status_enum AS ENUM ('Нове', 'В обробці', 'Відправлено', 'Доставлено', 'Скасовано');
 
-- Створюємо тип для методів оплати
CREATE TYPE payment_method_enum AS ENUM ('Картка', 'Готівка', 'Apple Pay', 'Google Pay', 'PayPal');
 
-- Таблиця Клієнтів
CREATE TABLE IF NOT EXISTS Customer (
    customer_id SERIAL PRIMARY KEY, 
    first_name VARCHAR(50) NOT NULL, 
    last_name VARCHAR(50) NOT NULL, 
    email VARCHAR(100) UNIQUE NOT NULL, 
    phone VARCHAR(20) NOT NULL, 
    address TEXT NOT NULL, 
    registration_date DATE DEFAULT CURRENT_DATE
);
 
-- Таблиця Категорій товарів
CREATE TABLE IF NOT EXISTS Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT 
);
 
-- Таблиця Способів доставки
CREATE TABLE IF NOT EXISTS ShippingMethod (
    shipping_id SERIAL PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0), 
    estimated_days INT NOT NULL CHECK (estimated_days > 0) 
);
 
-- Таблиця Тегів
CREATE TABLE IF NOT EXISTS Tag (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(50) NOT NULL UNIQUE
);
 
-- Таблиця Товарів
CREATE TABLE IF NOT EXISTS Product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0), 
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0), 
    category_id INT NOT NULL REFERENCES Category(category_id) ON DELETE RESTRICT 
);
 
-- Зв'язувальна таблиця (Товари та Теги)
CREATE TABLE IF NOT EXISTS ProductTag (
    product_id INT NOT NULL REFERENCES Product(product_id) ON DELETE CASCADE, 
    tag_id INT NOT NULL REFERENCES Tag(tag_id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, tag_id) 
);
 
-- Таблиця Замовлень
CREATE TABLE IF NOT EXISTS Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customer(customer_id) ON DELETE CASCADE, 
    shipping_id INT NOT NULL REFERENCES ShippingMethod(shipping_id), 
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    status order_status_enum DEFAULT 'Нове', 
    payment_method payment_method_enum NOT NULL, 
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0) 
);
 
-- Таблиця Деталей замовлення 
CREATE TABLE IF NOT EXISTS OrderItem (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES Orders(order_id) ON DELETE CASCADE, 
    product_id INT NOT NULL REFERENCES Product(product_id) ON DELETE RESTRICT, 
    quantity INT NOT NULL CHECK (quantity > 0), 
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0) 
);
 
-- Додаємо 5 клієнтів
INSERT INTO Customer (first_name, last_name, email, phone, address) VALUES
('Олександр', 'Петренко', 'alex.p@email.com', '+380501112233', 'Київ, вул. Хрещатик 10, кв 5'),
('Марія', 'Іванова', 'maria.i@email.com', '+380671112233', 'Львів, вул. Франка 20, кв 12'),
('Іван', 'Коваль', 'ivan.k@email.com', '+380631112233', 'Одеса, вул. Дерибасівська 5'),
('Анна', 'Шевченко', 'anna.s@email.com', '+380991112233', 'Дніпро, пр. Поля 15, кв 45'),
('Дмитро', 'Ткач', 'dima.t@email.com', '+380502223344', 'Харків, вул. Сумська 120');
 
-- Додаємо 5 категорій товарів
INSERT INTO Category (category_name, description) VALUES
('Електроніка', 'Смартфони, ноутбуки та гаджети'),
('Одяг', 'Чоловічий та жіночий одяг'),
('Взуття', 'Кросівки, туфлі, черевики'),
('Книги', 'Художня та наукова література'),
('Спорт', 'Товари для активного відпочинку');
 
-- Додаємо 5 способів доставки
INSERT INTO ShippingMethod (method_name, price, estimated_days) VALUES
('Нова Пошта (Відділення)', 80.00, 2),
('Нова Пошта (Кур''єр)', 120.00, 2),
('Укрпошта', 50.00, 5),
('Самовивіз з магазину', 0.00, 1),
('Meest Express', 70.00, 3);
 
-- Додаємо 5 тегів
INSERT INTO Tag (tag_name) VALUES ('Новинка'), ('Топ продажів'), ('Знижка'), ('Еко'), ('Преміум');
 
-- Додаємо 6 товарів
INSERT INTO Product (product_name, description, price, stock_quantity, category_id) VALUES
('Смартфон Apple iPhone 15', 'Остання модель смартфона від Apple', 45000.00, 50, 1),
('Ноутбук ASUS ROG', 'Ігровий ноутбук для складних задач', 65000.00, 20, 1),
('Футболка базова біла', 'Бавовняна футболка унісекс', 500.00, 200, 2),
('Кросівки Nike Air Max', 'Зручні кросівки для бігу', 4500.00, 40, 3),
('Книга "1984" Дж. Орвелл', 'Класична антиутопія', 350.00, 100, 4),
('Гантелі розбірні 15 кг', 'Металеві гантелі для тренувань', 1200.00, 30, 5);
 
-- Привласнюємо теги товарам
INSERT INTO ProductTag (product_id, tag_id) VALUES
(1, 1), (1, 2), (1, 5), 
(2, 5), 
(3, 2), 
(4, 1), (4, 2), 
(5, 3); 
 
-- Створюємо 5 замовлень
INSERT INTO Orders (customer_id, shipping_id, status, payment_method, total_amount) VALUES
(1, 2, 'Доставлено', 'Apple Pay', 45120.00),
(2, 1, 'Відправлено', 'Картка', 5000.00),
(3, 4, 'Нове', 'Готівка', 350.00),
(4, 1, 'В обробці', 'Google Pay', 66200.00),
(5, 3, 'Скасовано', 'PayPal', 1250.00);
 
-- Додаємо деталі замовлення
INSERT INTO OrderItem (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 45000.00), 
(2, 3, 1, 500.00), 
(2, 4, 1, 4500.00), 
(3, 5, 1, 350.00), 
(4, 2, 1, 65000.00), 
(4, 6, 1, 1200.00), 
(5, 6, 1, 1200.00); 


-- ====================================================================
-- ЧАСТИНА 2: НОРМАЛІЗАЦІЯ ДО 3НФ (Виконання Лабораторної 5)
-- ====================================================================

-- КРОК 1: Перехід до 1НФ (Атомарність таблиці Customer)
ALTER TABLE Customer 
ADD COLUMN city VARCHAR(50),
ADD COLUMN street VARCHAR(100),
ADD COLUMN building VARCHAR(10),
ADD COLUMN apartment VARCHAR(10);

-- Переносимо дані в нові стовпці
UPDATE Customer SET city = 'Київ', street = 'вул. Хрещатик', building = '10', apartment = 'кв 5' WHERE customer_id = 1;
UPDATE Customer SET city = 'Львів', street = 'вул. Франка', building = '20', apartment = 'кв 12' WHERE customer_id = 2;
UPDATE Customer SET city = 'Одеса', street = 'вул. Дерибасівська', building = '5' WHERE customer_id = 3;
UPDATE Customer SET city = 'Дніпро', street = 'пр. Поля', building = '15', apartment = 'кв 45' WHERE customer_id = 4;
UPDATE Customer SET city = 'Харків', street = 'вул. Сумська', building = '120' WHERE customer_id = 5;

-- Видаляємо старий неатомарний стовпець
ALTER TABLE Customer DROP COLUMN address;

-- КРОК 2: Перехід до 3НФ (Усунення транзитивних залежностей з Orders)
-- 1. Видаляємо обчислюване поле total_amount
ALTER TABLE Orders DROP COLUMN total_amount;

-- 2. Виносимо payment_method в окрему таблицю Payment
CREATE TABLE IF NOT EXISTS Payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES Orders(order_id) ON DELETE CASCADE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    method payment_method_enum NOT NULL,
    amount DECIMAL(10,2) NOT NULL
);

-- Переносимо дані про платежі зі старої таблиці Orders у Payment
INSERT INTO Payment (order_id, method, amount)
SELECT 
    o.order_id, 
    o.payment_method,
    COALESCE((SELECT SUM(quantity * unit_price) FROM OrderItem oi WHERE oi.order_id = o.order_id), 0)
FROM Orders o;

-- Видаляємо атрибут з Orders
ALTER TABLE Orders DROP COLUMN payment_method;

-- КРОК 3: Додаємо таблицю Review для повної відповідності новій ER-діаграмі
CREATE TABLE IF NOT EXISTS Review (
    review_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES Product(product_id) ON DELETE CASCADE,
    customer_id INT NOT NULL REFERENCES Customer(customer_id) ON DELETE CASCADE,
    rating NUMERIC(3, 2) CHECK (rating >= 0 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Review (product_id, customer_id, rating, comment) 
VALUES (1, 1, 5.0, 'Чудовий телефон, дуже задоволений!');