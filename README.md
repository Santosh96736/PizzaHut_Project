# PizzaHut Data Analysis Using MySQL.

![PizzaHut Logo](https://github.com/Santosh96736/PizzaHut_Project/blob/main/PizzaHut.png)

## TABLE CONTAINT 
1. PROJECT OVERVIEW
2. PROJECT OBJECT
3. DATABASAE SCHEMA
4. SQL QUERIES
5. KEY FINDINGS
6. CONTACT


## 1. PROJECT OVERVIEW
  *   Deep analysis of pizzaHut Database and finding usefull insights for business using MySQL.

## 2. PROJECT OBJECT

  * CREATE DATABASE   : Create a Structured Database for analysis
  * LOAD FILES        : Load files through import wizard
  * INDEX             : Creating indexes for speeding query performance
  * QUERY DATA        : Querying data for meaningfull business insight
  * WINDOW FUNCTION   : Using Window Functions for Time data, Running total and Cumulative Finding
  

## 3. DATABASE SCHEMA
   * There are four tables in the Database    
     | Table Name    |  Column Name                                   |  
   * |---------------|------------------------------------------------|  
   * | pizza_types   | pizza_type_id, name, category, ingredients     |  
   * | orders        | order_id, date, time                           |  
   * | pizzas        | pizza_id, pizza_type_id, size, price           |  
   * | order_details | order_details_id, order_id, pizza_id, quantity |  

## 4. SQL QUERIES

```sql
-- CREATING DATABASE

CREATE DATABASE IF NOT EXISTS PizzaHut;
```

```sql
-- USING DATABASE

USE PizzaHut;
```


```sql
-- CREATING TABLES AND IMPORTING DATA

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
```

```sql
-- CREATING INDEX 

CREATE INDEX idx_pizza_type_category ON pizza_types(category);

CREATE INDEX idx_pizza_type_id ON pizzas(pizza_type_id);

CREATE INDEX idx_order_id ON order_details(order_id);

CREATE INDEX idx_pizza_id ON order_details(pizza_id);

CREATE INDEX idx_order_date ON orders(date);

```

```sql

-- RETRIEVE TOP 10 ROWS FROM EACH TABLE -- 

SELECT pizza_type_id, name, category, ingredients FROM pizza_types LIMIT 10;

SELECT order_id, date, time FROM orders LIMIT 10;

SELECT pizza_id, pizza_type_id, size, price FROM pizzas LIMIT 10;

SELECT order_details_id, order_id, pizza_id, quantity FROM order_details LIMIT 10;
```


```sql
-- RETRIEVE DISTINCT PIZZA NAMES -- 

SELECT DISTINCT name FROM pizza_types;
```

```sql
-- RETRIEVE PIZZA CATEGORY -- 

SELECT DISTINCT category FROM pizza_types;
```


```sql
-- RETRIEVE SIZES -- 

SELECT DISTINCT size FROM pizzas;
```

```sql
-- RETRIEVE TOTAL QUANTITY SOLD -- 

SELECT SUM(quantity) AS total_quantity FROM order_details;
```


```sql
-- RETRIEVE WHICH PIZZA SOLD MOST -- 


SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 1;
```

```sql
-- RETRIEVE HOW MUCH EACH CATEGORY EARNS -- 

WITH category_data AS (SELECT pt.category, p.pizza_id, p.price
FROM pizza_types AS pt
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id)

SELECT cd.category, SUM(cd.price * od.quantity) AS revenue
FROM category_data AS cd
JOIN order_details AS od ON cd.pizza_id = od.pizza_id
GROUP BY cd.category
ORDER BY revenue DESC;
```

```sql
-- RETRIEVE MOST QUANTITY SALE DATE -- 

SELECT date, SUM(od.quantity) AS total_quantity
FROM orders AS o
JOIN order_details AS od ON o.order_id = od.order_id
GROUP BY o.date
ORDER BY total_quantity DESC
LIMIT 1;
```

```sql
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
```

```sql
-- RETERIEVE TOP 5 MOST QUANTITY SOLD HOUR -- 

SELECT HOUR(o.time) AS hour, SUM(od.quantity) AS total_quantity
FROM orders AS o
JOIN order_details AS od ON o.order_id = od.order_id
GROUP BY hour
ORDER BY total_quantity DESC
LIMIT 5;
```


```sql
-- RETRIEVE WHICH SIZE DEMAND LESS -- 

SELECT p.size, COUNT(od.order_details_id) AS total_order_count
FROM pizzas AS p
JOIN order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_order_count
LIMIT 1;
```

```sql
-- RETRIEVE MOST EXPENSIVE PIZZA -- 

SELECT pt.name, p.price
FROM pizza_types AS pt
JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;
```


```sql
-- RETRIEVE AVERAGE NUMBER OF PIZZA SOLD PER DAY -- 

SELECT ROUND(SUM(od.quantity) / COUNT(DISTINCT o.date)) AS Avg_pizza_sold_per_day
FROM order_details od
JOIN orders o ON od.order_id = o.order_id;
```

```sql
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
```


```sql
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
```


```sql
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
```


```sql
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
```

## 5. KEY FINDINGS
   *  AVGERAGE PIZZA SOLD PER DAY : 138 pizza were sold per day
   *  WHICH PIZZA SOLD MOST : The Classic Deluxe Pizza were sold most
   *  PICK SELLING HOUR : After noon 12 o'clock
   *  LESS SELLING SIZE : XXL were sold less than others
   *  MOST EXPENSIVE PIZZA : The Greek Pizza

## 6. CONTACT 

   EMAIL ADDRESS  : [santosh96736@gmail.com](santosh96736@gmail.com)  
   GITHUB ADDRESS : [https://github.com/Santosh96736/PizzaHut_Project/edit/main/README.md](https://github.com/Santosh96736/PizzaHut_Project)  






