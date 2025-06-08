CREATE DATABASE IF NOT EXISTS PizzaHut;

USE PizzaHut;

CREATE TABLE IF NOT EXISTS pizza_types( 
pizza_type_id VARCHAR(15) NOT NULL, 
name VARCHAR(50) NOT NULL,  
category VARCHAR(10),  
ingredients VARCHAR(100), 
PRIMARY KEY (pizza_type_id) 
);


CREATE TABLE IF NOT EXISTS orders( 
order_id INT NOT NULL, 
date DATE NOT NULL, 
time TIME, 
PRIMARY KEY (order_id) 
);

CREATE TABLE IF NOT EXISTS pizzas( 
pizza_id VARCHAR(20) NOT NULL, 
pizza_type_id VARCHAR(15) NOT NULL, 
size ENUM("S","M","L","XL","XXL") NOT NULL,  
price DECIMAL(10,2), 
PRIMARY KEY (pizza_id), 
FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id) 
);

CREATE TABLE IF NOT EXISTS order_details( 
order_details_id INT NOT NULL,
order_id INT NOT NULL,  
pizza_id VARCHAR(20) NOT NULL,  
quantity INT NOT NULL, 
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

CREATE INDEX idx_order_time ON orders(time);



