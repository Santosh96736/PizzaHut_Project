# PizzaHut Data Analysis Using MySQL.

![PizzaHut Logo](https://github.com/Santosh96736/PizzaHut_Project/blob/main/PizzaHut.png)

## TABLE OF CONTENTS 
1. [PROJECT OVERVIEW](#1-PROJECT-OVERVIEW)
2. [PROJECT OBJECTIVE](#2-PROJECT-OBJECTIVE)
3. [DATABASE SCHEMA](#3-DATABASE-SCHEMA)
4. [SQL QUERIES](#4-SQL-QUERIES)
5. [KEY FINDINGS](#5-KEY-FINDINGS)
6. [RECOMMENDATIONS & SUGGESTIONS](#6-Recommendations-&-Suggestions)
7. [REPOSITORY DETAILS](#7-REPOSITORY-DETAILS)


## 1. PROJECT OVERVIEW
  *   This project involves an in-depth analysis of PizzaHut's sales database using MySQL to extract valuable business insights,
      optimize performance, and understand customer preferences.  
      Download the Dataset : [Pizza Place Sales](https://www.kaggle.com/datasets/mysarahmadbhat/pizza-place-sales?select=pizzas.csv)

## 2. PROJECT OBJECTIVE
  * **Create Database:** Design a structured relational database.
  * **Load Data:** Import CSV files using MySQL Import Wizard.
  * **Optimize Performance:** Use indexing for efficient query execution.
  * **Extract Insights:** Perform complex SQL queries for business analytics.
  * **Use Window Functions:** Analyze trends, running totals, and cumulative calculations.  
  

## 3. Database Schema

> | Table Name      | Column Names |
> |----------------|----------------------------------------------------|
> | **pizza_types**  | `pizza_type_id`, `name`, `category`, `ingredients` |
> | **orders**       | `order_id`, `date`, `time` |
> | **pizzas**       | `pizza_id`, `pizza_type_id`, `size`, `price` |
> | **order_details**| `order_details_id`, `order_id`, `pizza_id`, `quantity` |
  Download the Schema : [PizzaHut Schema](https://github.com/Santosh96736/PizzaHut_Project/blob/main/PizzaHut_Schema_SQL.sql)


## 4. SQL QUERIES
```sql
-- CREATING INDEX 

CREATE INDEX idx_pizza_type_category ON pizza_types(category);

CREATE INDEX idx_order_date ON orders(date);
```

```sql
-- RETRIEVE TOTAL QUANTITY SOLD -- 
SELECT SUM(quantity) AS total_quantity FROM order_details;
```
![Total Quantity Sold](https://github.com/Santosh96736/PizzaHut_Project/blob/main/Screenshot%202025-06-15%20112018.png)


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
![Best Selling Pizza](https://github.com/Santosh96736/PizzaHut_Project/blob/main/Screenshot%202025-06-15%20111950.png)

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
![Category Wise Earning](https://github.com/Santosh96736/PizzaHut_Project/blob/main/Screenshot%202025-06-15%20111922.png)

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
![Difference In Income](https://github.com/Santosh96736/PizzaHut_Project/blob/main/Screenshot%202025-06-15%20111847.png)

  Download SQL Queries : [PizzaHut Queries](https://github.com/Santosh96736/PizzaHut_Project/blob/main/PizzaHt_Queries_SQL.sql)
  
  
## 5. KEY FINDINGS
   *  **Average Daily Pizza Sales:** Approximately 138 pizzas sold per day, indicating steady customer demand.
   *  **Best-Selling Pizza:** The Classic Deluxe Pizza leads in popularity and sales volume.
   *  **Peak Sales Hour:** Highest sales occur at 12:00 PM (noon), highlighting the lunch-time rush.
   *  **Lowest Demand Size:** The XXL size is the least popular among customers.
   *  **Most Expensive Pizza:** The Greek Pizza commands the highest price point.
   *  **Top Revenue-Generating Category:** The Classic pizza category contributes the most to overall revenue.

## 6. RECOMMENDATIONS & SUGGESTIONS
   * **Focus Marketing on Best Sellers:** Highlight the Classic Deluxe Pizza and other popular options in promotions and advertising campaigns to leverage their strong demand.
   * **Optimize Peak Hour Sales:** Introduce targeted offers or combo deals during peak hours (around 12 PM) to increase order size and customer retention.
   * **Upsell Premium Products:** Promote higher-priced pizzas like the Greek Pizza via upselling tactics during order placement and special occasion menus to increase average transaction value.
   * **Expand Classic Category:** Develop new pizza varieties under the popular Classic category to capitalize on its strong revenue contribution and customer loyalty.
   * **Implement Off-Peak Promotions:** Use discounts and bundle offers during non-peak hours to smooth demand throughout the day and increase overall sales volume.

## 7. REPOSITORY DETAILS

- **Repository Name:** PizzaHut Data Analysis  
- **Description:** Analyzing PizzaHut sales data using MySQL to extract insights and optimize performance.  
- **LinkedIn:** [Santosh Kumar Sahu](https://www.linkedin.com/in/santosh-kumar-sahu-data-analyst)
- **Mail:** [santosh96736@gmail.com](santosh96736@gmail.com)
- **GitHub Repository:** [PizzaHut_Project](https://github.com/Santosh96736/PizzaHut_Project)  






