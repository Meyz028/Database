-- 1. Використання базових агрегатних функцій (COUNT, SUM, AVG, MIN, MAX)
-- Аналіз цін товарів у магазині
SELECT 
    COUNT(product_id) AS total_products,
    ROUND(AVG(price), 2) AS average_price,
    MIN(price) AS cheapest_product_price,
    MAX(price) AS most_expensive_product_price
FROM Product;

-- 2. Використання GROUP BY
-- Підрахунок кількості товарів у кожній категорії
SELECT 
    c.category_name, 
    COUNT(p.product_id) AS number_of_products
FROM Category c
INNER JOIN Product p ON c.category_id = p.category_id
GROUP BY c.category_name;

-- 3. Використання GROUP BY та HAVING
-- Визначення категорій товарів, середня ціна яких перевищує 1000 грн
SELECT 
    c.category_name, 
    ROUND(AVG(p.price), 2) AS average_category_price
FROM Category c
INNER JOIN Product p ON c.category_id = p.category_id
GROUP BY c.category_name
HAVING AVG(p.price) > 1000.00;

-- 4. Використання INNER JOIN
-- Отримання інформації про замовлення разом з іменами клієнтів
SELECT 
    o.order_id, 
    c.first_name, 
    c.last_name, 
    o.status, 
    o.total_amount
FROM Orders o
INNER JOIN Customer c ON o.customer_id = c.customer_id;

-- 5. Використання LEFT JOIN
-- Виведення всіх клієнтів і їхніх замовлень (якщо замовлень немає, буде NULL)
SELECT 
    c.first_name, 
    c.last_name, 
    o.order_id, 
    o.total_amount
FROM Customer c
LEFT JOIN Orders o ON c.customer_id = o.customer_id;

-- 6. Складний об'єднаний запит (JOIN + GROUP BY + SUM + ORDER BY)
-- Рейтинг клієнтів за загальною сумою витрачених коштів (від найбільшого до найменшого)
SELECT 
    c.first_name, 
    c.last_name, 
    SUM(o.total_amount) AS total_spent_money
FROM Customer c
INNER JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY total_spent_money DESC;