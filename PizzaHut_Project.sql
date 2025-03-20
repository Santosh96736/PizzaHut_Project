CREATE DATABASE IF NOT EXISTS PizzaHut;

USE PizzaHut;

CREATE TABLE pizza_types( 
pizza_type_id VARCHAR(15), 
name VARCHAR(50),  
category VARCHAR(10),  
ingredients VARCHAR(100), 
PRIMARY KEY (pizza_type_id) 
);


CREATE TABLE orders( 
order_id INT, 
date DATE, 
time TIME, 
PRIMARY KEY (order_id) 
);


CREATE TABLE pizzas( 
pizza_id VARCHAR(20), 
pizza_type_id VARCHAR(15), 
size VARCHAR(5),  
price DECIMAL(10,2), 
PRIMARY KEY (pizza_id), 
FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id) 
);


CREATE TABLE order_details( 
order_details_id INT, 
order_id INT,  
pizza_id VARCHAR(20),  
quantity INT, 
PRIMARY KEY (order_details_id), 
FOREIGN KEY (order_id) REFERENCES orders(order_id), 
FOREIGN KEY (pizza_id) REFERENCES pizzas(pizza_id) 
);


-- CREATING INDEX 

CREATE INDEX idx_pizza_type_category ON pizza_types(category);

CREATE INDEX idx_pizza_type_id ON pizzas(pizza_type_id);

CREATE INDEX idx_order_id ON order_details(order_id);

CREATE INDEX idx_pizza_id ON order_details(pizza_id);

CREATE INDEX idx_order_date ON orders(date);



-- RETRIEVE TOP 10 ROWS FROM EACH TABLE -- 

SELECT pizza_type_id, name, category, ingredients FROM pizza_types LIMIT 10;

SELECT order_id, date, time FROM orders LIMIT 10;

SELECT pizza_id, pizza_type_id, size, price FROM pizzas LIMIT 10;

SELECT order_details_id, order_id, pizza_id, quantity FROM order_details LIMIT 10;



-- RETRIEVE DISTINCT PIZZA NAMES -- 

SELECT DISTINCT name FROM pizza_types;


-- RETRIEVE PIZZA CATEGORY -- 

SELECT DISTINCT category FROM pizza_types;



-- RETRIEVE SIZES -- 

SELECT DISTINCT size FROM pizzas;


-- RETRIEVE TOTAL QUANTITY SOLD -- 

SELECT SUM(quantity) AS total_quantity FROM order_details;



-- RETRIEVE WHICH PIZZA SOLD MOST -- 


SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 1;



-- RETRIEVE HOW MUCH EACH CATEGORY EARNS -- 

WITH category_data AS (SELECT pt.category, p.pizza_id, p.price
FROM pizza_types AS pt
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id)

SELECT cd.category, SUM(cd.price * od.quantity) AS revenue
FROM category_data AS cd
JOIN order_details AS od ON cd.pizza_id = od.pizza_id
GROUP BY cd.category
ORDER BY revenue DESC;


-- RETRIEVE MOST QUANTITY SALE DATE -- 

SELECT date, SUM(od.quantity) AS total_quantity
FROM orders AS o
JOIN order_details AS od ON o.order_id = od.order_id
GROUP BY o.date
ORDER BY total_quantity DESC
LIMIT 1;

-- RETRIEVE TOP 3 MOST EARNING MONTHS -- 

WITH revenue_data AS (SELECT od.order_id, SUM(p.price * od.quantity) AS revenue
FROM pizzas AS p
JOIN order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY od.order_id)

SELECT DATE_FORMAT(o.date, "%M") AS month, SUM(rd.revenue) AS revenue
FROM orders AS o
JOIN revenue_data AS rd ON o.order_id = rd.order_id
GROUP BY month 
ORDER BY revenue DESC
LIMIT 3;

-- RETRIEVE TOP 5 MOST QUANTITY SOLD HOUR -- 

SELECT HOUR(o.time) AS hour, SUM(od.quantity) AS total_quantity
FROM orders AS o
JOIN order_details AS od ON o.order_id = od.order_id
GROUP BY hour
ORDER BY total_quantity DESC
LIMIT 5;

-- RETRIEVE WHICH SIZE DEMAND LESS -- 

SELECT p.size, COUNT(od.order_details_id) AS total_order_count
FROM pizzas AS p
JOIN order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_order_count
LIMIT 1;


-- RETRIEVE MOST EXPENSIVE PIZZA -- 

SELECT pt.name, p.price
FROM pizza_types AS pt
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;



-- RETRIEVE AVERAGE NUMBER OF PIZZA SOLD PER DAY -- 

SELECT ROUND(SUM(od.quantity) / COUNT(DISTINCT o.date)) AS Avg_pizza_sold_per_day
FROM order_details od
JOIN orders o ON od.order_id = o.order_id;

-- HOW MUCH EACH CATEGORY CONTRIBUTES TOWARDS REVENUE -- 

WITH category_data AS (SELECT pt.category, p.pizza_id, p.price
FROM pizza_types AS pt
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id)

SELECT cd.category, CONCAT(ROUND((SUM(cd.price * od.quantity) / 
                    (SELECT SUM(p.price * od.quantity) FROM pizzas AS p 
                    JOIN order_details AS od ON p.pizza_id = od.pizza_id)) * 100), " ", "%") AS revenue_contribution
FROM category_data AS cd
JOIN order_details AS od ON cd.pizza_id = od.pizza_id
GROUP BY cd.category
ORDER BY revenue_contribution DESC;



-- RETRIEVE WEEKLY RUNNING TOTAL INCOME -- 

WITH order_data AS (SELECT od.order_id, SUM(p.price * od.quantity) AS revenue
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
GROUP BY od.order_id),

date_data AS (SELECT o.date, SUM(od.revenue) AS revenue
FROM order_data AS od
JOIN orders AS o ON od.order_id = o.order_id
GROUP BY o.date) 

SELECT date, revenue,
       SUM(revenue) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS running_weekly_income
FROM date_data;



-- SELECT CUMULATIVE MONTHLY INCOME -- 

WITH order_data AS (SELECT od.order_id, SUM(p.price * od.quantity) AS revenue
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
GROUP BY od.order_id),

date_data AS (SELECT MONTH(o.date) AS month, SUM(od.revenue) AS revenue
FROM order_data AS od
JOIN orders AS o ON od.order_id = o.order_id
GROUP BY month) 

SELECT month, revenue,
       SUM(revenue) OVER(ORDER BY month) AS cumulative_monthly_income
FROM date_data;



-- RETRIEVE DIFFERENCE OF INCOME FROM PREVIOUS MONTH -- 


WITH order_data AS (SELECT od.order_id, SUM(p.price * od.quantity) AS revenue
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
GROUP BY od.order_id),

date_data AS (SELECT MONTH(o.date) AS month_number, DATE_FORMAT(o.date, "%M") AS month_name, SUM(od.revenue) AS revenue
FROM order_data AS od
JOIN orders AS o ON od.order_id = o.order_id
GROUP BY month_number, month_name) 

SELECT month_name AS month, revenue,
      (revenue - LAG(revenue) OVER(ORDER BY month_number)) AS difference_in_income
FROM date_data;







