-- ============================================================
-- Lab 12: Aggregate Functions - GROUP BY, HAVING, Joins (Part B)
-- Name: Shahzad Ahmed Awan    Roll No: 2024-SE-15
-- Submitted to: Sir Awais Rathore
-- ============================================================
-- Setup script (run once before the tasks below)
CREATE DATABASE IF NOT EXISTS agg_lab;
USE agg_lab;

DROP TABLE IF EXISTS OrderItem, Product, Customer;

CREATE TABLE Customer (
    CustID   INT PRIMARY KEY,
    CustName VARCHAR(60) NOT NULL,
    City     VARCHAR(30),
    JoinDate DATE
);

CREATE TABLE Product (
    ProdID   INT PRIMARY KEY,
    ProdName VARCHAR(60) NOT NULL,
    Category VARCHAR(30),
    Price    DECIMAL(10,2),
    StockQty INT
);

CREATE TABLE OrderItem (
    OrderID   INT PRIMARY KEY,
    CustID    INT,
    ProdID    INT,
    Quantity  INT,
    OrderDate DATE,
    FOREIGN KEY (CustID) REFERENCES Customer(CustID),
    FOREIGN KEY (ProdID) REFERENCES Product(ProdID)
);

INSERT INTO Customer VALUES
(1, 'Ali Khan', 'Lahore', '2022-01-15'),
(2, 'Sara Iqbal', 'Karachi', '2022-04-22'),
(3, 'Hamza Raza', 'Lahore', '2023-02-10'),
(4, 'Ayesha Noor', 'Islamabad', '2023-05-18'),
(5, 'Bilal Ahmed', 'Karachi', '2023-09-01'),
(6, 'Fatima Sheikh', NULL, '2024-01-12'),
(7, 'Usman Tariq', 'Lahore', '2024-06-30'),
(8, 'Maira Javed', 'Islamabad', '2024-08-25');

INSERT INTO Product VALUES
(101,'Laptop Pro 15', 'Electronics', 185000.00, 12),
(102,'Wireless Mouse', 'Electronics', 2500.00, 50),
(103,'USB-C Cable', 'Electronics', 800.00, 100),
(104,'Office Chair', 'Furniture', 18500.00, 8),
(105,'Standing Desk', 'Furniture', 45000.50, 5),
(106,'Notebook A4', 'Stationery', 350.00, 200),
(107,'Ballpoint Pen 10pk','Stationery', 450.00, 150),
(108,'Coffee Beans 1kg', 'Grocery', 1899.99, 30),
(109,'Green Tea Box', 'Grocery', 650.00, 45),
(110,'Bluetooth Speaker', 'Electronics', 7500.00, 18);

INSERT INTO OrderItem VALUES
(1001, 1, 101, 1, '2023-03-10'),
(1002, 1, 102, 2, '2023-03-10'),
(1003, 2, 104, 1, '2023-05-22'),
(1004, 2, 106, 5, '2023-05-22'),
(1005, 3, 101, 1, '2023-08-15'),
(1006, 3, 110, 1, '2023-08-15'),
(1007, 4, 108, 3, '2023-11-02'),
(1008, 5, 103, 4, '2024-01-20'),
(1009, 5, 102, 1, '2024-01-20'),
(1010, 6, 105, 1, '2024-02-14'),
(1011, 7, 107, 2, '2024-04-08'),
(1012, 7, 106, 10,'2024-04-08'),
(1013, 7, 109, 3, '2024-07-19'),
(1014, 2, 110, 1, '2024-09-05'),
(1015, 3, 108, 2, '2024-10-11');

-- Task B1: Number of customers in each city, sorted by count descending
SELECT City, COUNT(*) AS NumCustomers
FROM Customer
GROUP BY City
ORDER BY NumCustomers DESC;

-- Task B2: Number of products in each category, sorted by count descending
SELECT Category, COUNT(*) AS NumProducts
FROM Product
GROUP BY Category
ORDER BY NumProducts DESC;

-- Task B3: Average, minimum, and maximum price per category, sorted by avg price descending
SELECT Category,
       ROUND(AVG(Price), 2) AS AvgPrice,
       MIN(Price) AS MinPrice,
       MAX(Price) AS MaxPrice
FROM Product
GROUP BY Category
ORDER BY AvgPrice DESC;

-- Task B4: Total stock quantity per category, sorted by total descending
SELECT Category, SUM(StockQty) AS TotalStock
FROM Product
GROUP BY Category
ORDER BY TotalStock DESC;

-- Task B5: Number of orders placed each year, sorted by year
SELECT YEAR(OrderDate) AS OrderYear, COUNT(*) AS NumOrders
FROM OrderItem
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;

-- Task B6: Number of orders placed each month of 2024, sorted by month
SELECT MONTH(OrderDate) AS OrderMonth, COUNT(*) AS NumOrders
FROM OrderItem
WHERE YEAR(OrderDate) = 2024
GROUP BY MONTH(OrderDate)
ORDER BY OrderMonth;

-- Task B7: Product categories where the average price is greater than 5,000
SELECT Category, ROUND(AVG(Price), 2) AS AvgPrice
FROM Product
GROUP BY Category
HAVING AVG(Price) > 5000;

-- Task B8: Cities with more than 1 customer (excluding NULL city)
SELECT City, COUNT(*) AS NumCustomers
FROM Customer
WHERE City IS NOT NULL
GROUP BY City
HAVING COUNT(*) > 1
ORDER BY NumCustomers DESC;

-- Task B9: Number of orders per customer, including customers with zero orders
SELECT c.CustID,
       c.CustName,
       COUNT(o.OrderID) AS NumOrders
FROM Customer c
LEFT JOIN OrderItem o ON c.CustID = o.CustID
GROUP BY c.CustID, c.CustName;

-- Task B10: Total quantity sold per product, including products never sold
SELECT p.ProdName,
       SUM(o.Quantity) AS TotalQty
FROM Product p
LEFT JOIN OrderItem o ON p.ProdID = o.ProdID
GROUP BY p.ProdID, p.ProdName
ORDER BY TotalQty DESC;

-- Task B11: Total revenue per product category, sorted by revenue descending
SELECT p.Category,
       SUM(o.Quantity * p.Price) AS Revenue
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID
GROUP BY p.Category
ORDER BY Revenue DESC;

-- Task B12: Total spend per customer, including customers with no orders
SELECT c.CustName,
       SUM(o.Quantity * p.Price) AS TotalSpend
FROM Customer c
LEFT JOIN OrderItem o ON c.CustID = o.CustID
LEFT JOIN Product p ON o.ProdID = p.ProdID
GROUP BY c.CustID, c.CustName
ORDER BY TotalSpend DESC;

-- Task B13: Customers whose total spend exceeds 50,000
SELECT c.CustName,
       SUM(o.Quantity * p.Price) AS TotalSpend
FROM Customer c
JOIN OrderItem o ON c.CustID = o.CustID
JOIN Product p   ON o.ProdID = p.ProdID
GROUP BY c.CustID, c.CustName
HAVING SUM(o.Quantity * p.Price) > 50000;

-- Task B14: Per city, count of customers and total revenue; only cities with more than 1 customer
SELECT c.City,
       COUNT(DISTINCT c.CustID) AS NumCustomers,
       SUM(o.Quantity * p.Price) AS CityRevenue
FROM Customer c
JOIN OrderItem o ON c.CustID = o.CustID
JOIN Product p   ON o.ProdID = p.ProdID
GROUP BY c.City
HAVING COUNT(DISTINCT c.CustID) > 1;

-- Task B15: Top 3 best-selling products by total quantity sold
SELECT p.ProdName,
       SUM(o.Quantity) AS TotalQty
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID
GROUP BY p.ProdID, p.ProdName
ORDER BY TotalQty DESC
LIMIT 3;

-- Task B16: Total revenue per year, sorted by year
SELECT YEAR(o.OrderDate) AS OrderYear,
       SUM(o.Quantity * p.Price) AS Revenue
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID
GROUP BY YEAR(o.OrderDate)
ORDER BY OrderYear;

-- Task B17: Average order value (revenue per order)
SELECT ROUND(AVG(OrderValue), 2) AS AvgOrderValue
FROM (
    SELECT o.OrderID,
           SUM(o.Quantity * p.Price) AS OrderValue
    FROM OrderItem o
    JOIN Product p ON o.ProdID = p.ProdID
    GROUP BY o.OrderID
) AS OrderValues;
