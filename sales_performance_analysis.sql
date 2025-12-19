-- ============================================
-- Sales Performance Analysis Mini Project
-- Author: Sana
-- Database: sales_analysis
-- ============================================


-- Create Database
CREATE DATABASE sales_analysis;
USE sales_analysis;

-- Table Creation
-- customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(50)
);

-- products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- salespersons table
CREATE TABLE salespersons (
    salesperson_id INT PRIMARY KEY,
    salesperson_name VARCHAR(100),
    region VARCHAR(50)
);

-- sales table (with foreign keys)
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    salesperson_id INT,
    quantity INT,
    sale_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (salesperson_id) REFERENCES salespersons(salesperson_id)
);

-- 3. Data Insertion
-- customer table
INSERT INTO customers VALUES
(1, 'Amit Sharma', 'Delhi', 'North'),
(2, 'Neha Verma', 'Mumbai', 'West'),
(3, 'Rahul Singh', 'Bangalore', 'South'),
(4, 'Priya Mehta', 'Ahmedabad', 'West'),
(5, 'Suresh Kumar', 'Chennai', 'South'),
(6, 'Anita Roy', 'Kolkata', 'East'),
(7, 'Vikas Gupta', 'Delhi', 'North'),
(8, 'Pooja Nair', 'Kochi', 'South');

-- products table
INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 55000),
(102, 'Mobile Phone', 'Electronics', 25000),
(103, 'Headphones', 'Accessories', 2000),
(104, 'Keyboard', 'Accessories', 1500),
(105, 'Monitor', 'Electronics', 12000),
(106, 'Mouse', 'Accessories', 800);

-- salespersons table
INSERT INTO salespersons VALUES
(201, 'Ravi Patel', 'West'),
(202, 'Sunita Rao', 'South'),
(203, 'Aakash Malhotra', 'North'),
(204, 'Meena Das', 'East');
 
 -- sales table
 INSERT INTO sales VALUES
(1, 1, 101, 203, 1, '2024-01-10'),
(2, 2, 102, 201, 2, '2024-01-15'),
(3, 3, 103, 202, 3, '2024-02-05'),
(4, 4, 105, 201, 1, '2024-02-18'),
(5, 5, 101, 202, 1, '2024-03-02'),
(6, 6, 104, 204, 4, '2024-03-10'),
(7, 7, 102, 203, 1, '2024-03-15'),
(8, 8, 106, 202, 5, '2024-04-01'),
(9, 1, 105, 203, 2, '2024-04-10'),
(10, 2, 103, 201, 3, '2024-04-20'),
(11, 3, 101, 202, 1, '2024-05-05'),
(12, 4, 106, 201, 4, '2024-05-18'),
(13, 5, 102, 202, 2, '2024-06-01'),
(14, 6, 103, 204, 2, '2024-06-12'),
(15, 7, 104, 203, 3, '2024-06-20');


-- what is the total sales revenue?
SELECT 
SUM(p.price * s.quantity) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id;

-- monthly sales trend
SELECT
DATE_FORMAT(s.sale_date,'%Y-%m') AS month,
SUM(p.price * s.quantity) AS monthly_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY month;

-- top 5 best-selling products
SELECT 
    p.product_name,
    SUM(s.quantity) AS total_sold
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 5;

-- salesperson performance
SELECT 
    sp.salesperson_name,
    SUM(p.price * s.quantity) AS revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN salespersons sp ON s.salesperson_id = sp.salesperson_id
GROUP BY sp.salesperson_name
ORDER BY revenue DESC;

-- region wise sales
SELECT c.region,
	SUM(p.price * s.quantity) AS region_sales
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY c.region;

-- average order value per customers
SELECT c.customer_name,
	SUM(p.price * s.quantity)/COUNT(s.sale_id) AS avg_ord_value
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY c.customer_name
ORDER BY avg_ord_value DESC;

-- sales category performance
SELECT p.category,
		SUM(p.price * s.quantity) AS cat_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY cat_sales DESC;

-- rank by salespersons revenue
SELECT sp.salesperson_name,
	SUM(p.price * s.quantity) AS revenue,
    RANK() OVER(ORDER BY SUM(p.price * s.quantity) DESC) AS sales_rank
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN salespersons sp ON s.salesperson_id = sp.salesperson_id
GROUP BY sp.salesperson_name;

-- performace of products
SELECT p.product_name,
	SUM(p.price * s.quantity) AS total_sales
FROM sales s
JOIN products p ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY total_sales ASC;

-- Performance Category using CASE WHEN
SELECT 
    sp.salesperson_name,
    SUM(p.price * s.quantity) AS revenue,
    CASE
        WHEN SUM(p.price * s.quantity) >= 100000 THEN 'Excellent'
        WHEN SUM(p.price * s.quantity) >= 50000 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN salespersons sp ON s.salesperson_id = sp.salesperson_id
GROUP BY sp.salesperson_name;
    
-- Customer retention: repeat vs one-time customers
SELECT c.customer_name,
COUNT(s.sale_id) AS total_orders,
CASE
	WHEN COUNT(s.sale_id) =1 THEN 'One-time customer'
    ELSE 'Repeat customer'
END AS customer_type
FROM sales s
JOIN customers c ON c.customer_id = s.customer_id
GROUP BY c.customer_name
ORDER BY total_orders DESC;

-- Number of orders per customer
SELECT c.customer_name,
COUNT(s.sale_id) AS order_count
FROM sales s
JOIN customers c ON s.customer_id= c.customer_id
GROUP BY c.customer_name
ORDER BY order_count DESC;

-- Customer loyalty classification
SELECT c.customer_name,
COUNT(s.sale_id) AS total_orders,
CASE 
	WHEN COUNT(s.sale_id)=1 THEN 'New customer'
    WHEN COUNT(s.sale_id) BETWEEN 2 AND 3 THEN 'Repeat customer'
    ELSE 'Loyal customer'
END AS loyality_status
FROM sales s
JOIN customers c ON s.customer_id= c.customer_id
GROUP BY c.customer_name
ORDER BY total_orders DESC;

-- First and last purchase per customer
SELECT 
    c.customer_name,
    MIN(s.sale_date) AS first_purchase,
    MAX(s.sale_date) AS last_purchase
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_name;


    