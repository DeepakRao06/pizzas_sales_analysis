-- ======================================
-- PIZZA HUT SALES ANALYSIS PROJECT
-- ======================================

USE pizzahut;

-- 1. Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;


-- 2. Total Revenue
SELECT ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id;


-- 3. Highest Price Pizza
SELECT pt.name, p.price
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- 4. Most Common Pizza Size
SELECT p.size,
       COUNT(od.order_details_id) AS order_count
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;


-- 5. Top 5 Most Ordered Pizza Types
SELECT pt.name,
       SUM(od.quantity) AS quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;


-- 6. Category-wise Quantity Sold
SELECT pt.category,
       SUM(od.quantity) AS quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;


-- 7. Orders by Hour
SELECT HOUR(order_time) AS hour,
       COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time)
ORDER BY order_count DESC
LIMIT 5;


-- 8. Average Pizzas Ordered Per Day
SELECT ROUND(AVG(quantity), 0) AS avg_orders
FROM (
    SELECT o.order_date,
           SUM(od.quantity) AS quantity
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    GROUP BY o.order_date
) AS daily_orders;


-- 9. Top 3 Revenue Pizza Types
SELECT pt.name,
       ROUND(SUM(p.price * od.quantity), 2) AS revenue
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;


-- 10. Revenue Contribution by Category
SELECT pt.category,
       SUM(p.price * od.quantity) /
       (SELECT SUM(p2.price * od2.quantity)
        FROM pizzas p2
        JOIN order_details od2 ON p2.pizza_id = od2.pizza_id
       ) * 100 AS revenue_percent
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue_percent DESC;


-- 11. Cumulative Revenue Over Time
SELECT order_date,
       SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT o.order_date,
           SUM(p.price * od.quantity) AS revenue
    FROM pizzas p
    JOIN order_details od ON p.pizza_id = od.pizza_id
    JOIN orders o ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS sales;


-- 12. Top 3 Pizzas per Category (Revenue Ranking)
SELECT *
FROM (
    SELECT pt.name,
           pt.category,
           SUM(p.price * od.quantity) AS revenue,
           RANK() OVER (PARTITION BY pt.category ORDER BY SUM(p.price * od.quantity) DESC) AS rnk
    FROM pizzas p
    JOIN order_details od ON p.pizza_id = od.pizza_id
    JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
    GROUP BY pt.name, pt.category
) ranked
WHERE rnk <= 3;