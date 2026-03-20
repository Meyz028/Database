-- Створюємо тип для статусу замовлення, щоб не можна було ввести випадковий текст
CREATE TYPE order_status_enum AS ENUM ('Нове', 'В обробці', 'Відправлено', 'Доставлено', 'Скасовано');

-- Створюємо тип для методів оплати
CREATE TYPE payment_method_enum AS ENUM ('Картка', 'Готівка', 'Apple Pay', 'Google Pay', 'PayPal');

-- Таблиця Клієнтів
CREATE TABLE IF NOT EXISTS Customer (
    customer_id SERIAL PRIMARY KEY, -- Унікальний ідентифікатор клієнта (автозбільшення)
    first_name VARCHAR(50) NOT NULL, -- Ім'я (обов'язкове поле)
    last_name VARCHAR(50) NOT NULL, -- Прізвище (обов'язкове поле)
    email VARCHAR(100) UNIQUE NOT NULL, -- Електронна пошта (повинна бути унікальною)
    phone VARCHAR(20) NOT NULL, -- Номер телефону
    address TEXT NOT NULL, -- Адреса доставки
    registration_date DATE DEFAULT CURRENT_DATE -- Дата реєстрації (за замовчуванням - поточна дата)
);

-- Таблиця Категорій товарів
CREATE TABLE IF NOT EXISTS Category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE, -- Назва категорії (не може повторюватись)
    description TEXT -- Опис категорії
);

-- Таблиця Способів доставки
CREATE TABLE IF NOT EXISTS ShippingMethod (
    shipping_id SERIAL PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0), -- Обмеження: ціна доставки не може бути від'ємною
    estimated_days INT NOT NULL CHECK (estimated_days > 0) -- Обмеження: дні доставки повинні бути > 0
);

-- Таблиця Тегів (наприклад: "Новинка", "Знижка")
CREATE TABLE IF NOT EXISTS Tag (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(50) NOT NULL UNIQUE
);


-- Таблиця Товарів
CREATE TABLE IF NOT EXISTS Product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0), -- Обмеження: ціна товару > 0
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0), -- Обмеження: кількість на складі не може бути від'ємною
    category_id INT NOT NULL REFERENCES Category(category_id) ON DELETE RESTRICT -- Зв'язок з категорією. RESTRICT забороняє видаляти категорію, якщо в ній є товари
);

-- Зв'язувальна таблиця для відношення "Багато-до-багатьох" (Товари та Теги)
CREATE TABLE IF NOT EXISTS ProductTag (
    product_id INT NOT NULL REFERENCES Product(product_id) ON DELETE CASCADE, -- CASCADE: при видаленні товару видаляються і його теги
    tag_id INT NOT NULL REFERENCES Tag(tag_id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, tag_id) -- Композитний первинний ключ
);

-- Таблиця Замовлень ("Шапка" замовлення)
CREATE TABLE IF NOT EXISTS Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES Customer(customer_id) ON DELETE CASCADE, -- Хто зробив замовлення
    shipping_id INT NOT NULL REFERENCES ShippingMethod(shipping_id), -- Як доставляти
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Точний час замовлення
    status order_status_enum DEFAULT 'Нове', -- Статус із нашого ENUM
    payment_method payment_method_enum NOT NULL, -- Метод оплати із нашого ENUM
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0) -- Загальна сума замовлення
);

-- Таблиця Деталей замовлення (Кошик товарів у конкретному замовленні)
CREATE TABLE IF NOT EXISTS OrderItem (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES Orders(order_id) ON DELETE CASCADE, -- До якого замовлення належить
    product_id INT NOT NULL REFERENCES Product(product_id) ON DELETE RESTRICT, -- Який товар купили
    quantity INT NOT NULL CHECK (quantity > 0), -- Кількість купленого товару
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0) -- Ціна за одиницю на момент покупки
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
INSERT INTO Tag (tag_name) VALUES
('Новинка'),
('Топ продажів'),
('Знижка'),
('Еко'),
('Преміум');

-- Додаємо 6 товарів із зазначенням їхньої категорії (category_id)
INSERT INTO Product (product_name, description, price, stock_quantity, category_id) VALUES
('Смартфон Apple iPhone 15', 'Остання модель смартфона від Apple', 45000.00, 50, 1),
('Ноутбук ASUS ROG', 'Ігровий ноутбук для складних задач', 65000.00, 20, 1),
('Футболка базова біла', 'Бавовняна футболка унісекс', 500.00, 200, 2),
('Кросівки Nike Air Max', 'Зручні кросівки для бігу', 4500.00, 40, 3),
('Книга "1984" Дж. Орвелл', 'Класична антиутопія', 350.00, 100, 4),
('Гантелі розбірні 15 кг', 'Металеві гантелі для тренувань', 1200.00, 30, 5);

-- Привласнюємо теги товарам (зв'язок товарів та тегів)
INSERT INTO ProductTag (product_id, tag_id) VALUES
(1, 1), (1, 2), (1, 5), -- iPhone 15: Новинка, Топ продажів, Преміум
(2, 5),                 -- Ноутбук: Преміум
(3, 2),                 -- Футболка: Топ продажів
(4, 1), (4, 2),         -- Кросівки: Новинка, Топ продажів
(5, 3);                 -- Книга: Знижка

-- Створюємо 5 замовлень (хто замовив, як доставити, статус, оплата, сума)
INSERT INTO Orders (customer_id, shipping_id, status, payment_method, total_amount) VALUES
(1, 2, 'Доставлено', 'Apple Pay', 45120.00),
(2, 1, 'Відправлено', 'Картка', 5000.00),
(3, 4, 'Нове', 'Готівка', 350.00),
(4, 1, 'В обробці', 'Google Pay', 66200.00),
(5, 3, 'Скасовано', 'PayPal', 1250.00);

-- Додаємо конкретні товари в створені замовлення
INSERT INTO OrderItem (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 45000.00), -- У замовлення №1 додали 1 iPhone
(2, 3, 1, 500.00),   -- У замовлення №2 додали 1 футболку
(2, 4, 1, 4500.00),  -- У замовлення №2 додали 1 пару кросівок
(3, 5, 1, 350.00),   -- У замовлення №3 додали 1 книгу
(4, 2, 1, 65000.00), -- У замовлення №4 додали 1 ноутбук
(4, 6, 1, 1200.00),  -- У замовлення №4 додали гантелі
(5, 6, 1, 1200.00);  -- У замовлення №5 додали гантелі
