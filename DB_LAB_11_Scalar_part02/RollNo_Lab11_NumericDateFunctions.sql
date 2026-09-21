-- ============================================================
-- Lab 11: Scalar SQL Functions - Numeric & Date/Time Functions (Part B)
-- Name: Shahzad Ahmed Awan    Roll No: 2024-SE-15
-- Submitted to: Sir Awais Rathore
-- ============================================================
-- Setup script (run once before the tasks below)
CREATE DATABASE IF NOT EXISTS scalar_lab;
USE scalar_lab;

DROP TABLE IF EXISTS Product, Customer;

CREATE TABLE Customer (
    CustID INT PRIMARY KEY,
    CustName VARCHAR(60) NOT NULL,
    Email VARCHAR(80),
    City VARCHAR(30),
    Phone VARCHAR(20),
    JoinDate DATE,
    DOB DATE
);

CREATE TABLE Product (
    ProdID INT PRIMARY KEY,
    ProdName VARCHAR(60) NOT NULL,
    Category VARCHAR(30),
    Price DECIMAL(10,2),
    StockQty INT,
    LaunchDate DATE
);

INSERT INTO Customer VALUES
(1, ' Ali Khan ', 'ali.khan@MAIL.com', 'Lahore', '0300-1112233','2022-01-15','1995-04-12'),
(2, 'Sara Iqbal', 'sara@example.com', 'Karachi', '0301-4445566','2022-04-22','1998-11-20'),
(3, 'HAMZA RAZA', 'hamza@example.com', 'Lahore', '0302-7778899','2023-02-10','1997-08-05'),
(4, 'Ayesha Noor', NULL, 'Islamabad', '0303-1234567','2023-05-18','1999-02-14'),
(5, 'bilal ahmed', 'bilal@MAIL.COM', 'Karachi', '0304-2345678','2023-09-01','2000-06-30'),
(6, 'Fatima Sheikh', 'fatima@example.com', NULL, '0305-3456789','2024-01-12','1996-10-25'),
(7, 'Usman Tariq', 'usman@example.com', 'Lahore', NULL, '2024-06-30','2001-03-18'),
(8, 'Maira Javed', 'maira@example.com', 'Islamabad', '0307-5678901','2024-08-25','1994-12-09');

INSERT INTO Product VALUES
(101,'Laptop Pro 15', 'Electronics', 185000.00, 12, '2023-03-10'),
(102,'Wireless Mouse', 'Electronics', 2500.00, 50, '2022-07-22'),
(103,'USB-C Cable', 'Electronics', 800.00, 100,'2021-11-05'),
(104,'Office Chair', 'Furniture', 18500.00, 8, '2023-01-15'),
(105,'Standing Desk', 'Furniture', 45000.50, 5, '2024-02-28'),
(106,'Notebook A4', 'Stationery', 350.00, 200,'2020-04-01'),
(107,'Ballpoint Pen 10pk','Stationery', 450.00, 150,'2020-04-01'),
(108,'Coffee Beans 1kg', 'Grocery', 1899.99, 30, '2023-09-20'),
(109,'Green Tea Box', 'Grocery', 650.00, 45, '2022-12-12'),
(110,'Bluetooth Speaker', 'Electronics', 7500.00, 18, '2024-05-18');

-- Task B1: Apply a 15% discount to every product
SELECT ProdName,
       Price,
       ROUND(Price * 0.85, 2) AS DiscountedPrice
FROM Product;

-- Task B2: 17% sales tax and final price (price + tax)
SELECT ProdName,
       ROUND(Price * 0.17, 2) AS Tax,
       ROUND(Price * 1.17, 2) AS PriceWithTax
FROM Product;

-- Task B3: Floor and ceiling of each product's price divided by 1000
SELECT ProdName,
       Price,
       FLOOR(Price / 1000) AS FloorVal,
       CEIL(Price / 1000) AS CeilVal
FROM Product;

-- Task B4: Round each product's price to the nearest hundred
SELECT ProdName,
       Price,
       ROUND(Price, -2) AS RoundedToHundred
FROM Product;

-- Task B5: Products with an odd ProdID
SELECT ProdID, ProdName
FROM Product
WHERE MOD(ProdID, 2) = 1;

-- Task B6: Year, month name, and day of week each customer joined
SELECT CustName,
       JoinDate,
       YEAR(JoinDate) AS JoinYear,
       MONTHNAME(JoinDate) AS JoinMonth,
       DAYNAME(JoinDate) AS JoinDay
FROM Customer;

-- Task B7: DOB formatted as 'DD-Month-YYYY'
SELECT CustName,
       DOB,
       DATE_FORMAT(DOB, '%d-%M-%Y') AS FormattedDOB
FROM Customer;

-- Task B8: Current age in years (TIMESTAMPDIFF)
SELECT CustName,
       DOB,
       TIMESTAMPDIFF(YEAR, DOB, CURDATE()) AS Age
FROM Customer;

-- Task B9: Days since each customer joined (from today)
SELECT CustName,
       JoinDate,
       DATEDIFF(CURDATE(), JoinDate) AS DaysSinceJoin
FROM Customer;

-- Task B10: Customers who joined in the year 2023 (using a date function)
SELECT CustName, JoinDate
FROM Customer
WHERE YEAR(JoinDate) = 2023;

-- Task B11: Products launched in any year's Q4 (Oct, Nov, Dec)
SELECT ProdName, LaunchDate
FROM Product
WHERE MONTH(LaunchDate) IN (10, 11, 12);

-- Task B12: Customers who joined within the last 6 months from today
SELECT CustName, JoinDate
FROM Customer
WHERE JoinDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

-- Task B13: Each product's age in days (days since launch)
SELECT ProdName,
       LaunchDate,
       DATEDIFF(CURDATE(), LaunchDate) AS AgeInDays
FROM Product;

-- Task B14: Date exactly 90 days after each product's LaunchDate
SELECT ProdName,
       LaunchDate,
       DATE_ADD(LaunchDate, INTERVAL 90 DAY) AS NinetyDaysLater
FROM Product;

-- Task B15: Combined challenge - 'Hello ALI KHAN, age 31, joined Jan 2022'
SELECT CONCAT(
           'Hello ', UPPER(TRIM(CustName)),
           ', age ', TIMESTAMPDIFF(YEAR, DOB, CURDATE()),
           ', joined ', DATE_FORMAT(JoinDate, '%b %Y')
       ) AS Summary
FROM Customer;
