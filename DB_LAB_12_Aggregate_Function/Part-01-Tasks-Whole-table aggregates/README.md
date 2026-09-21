# Lab 12: Aggregate Functions (Part A)

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1?logo=mysql&logoColor=white)
![Topic](https://img.shields.io/badge/Topic-COUNT%20%7C%20SUM%20%7C%20AVG%20%7C%20MIN%20%7C%20MAX-2E8B57)
![Tasks](https://img.shields.io/badge/Tasks-10%2F10-brightgreen)
![Status](https://img.shields.io/badge/Status-Completed-success)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | Whole-table aggregates: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `DISTINCT` |
| **Database / Tables** | `agg_lab` / `Customer`, `Product`, `OrderItem` |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Compute single-value summary statistics over an entire table (no `GROUP BY` yet) using MySQL's aggregate functions on an e-commerce style database (10 tasks).

## 2. Database Setup

### 2.1 Create and select database

```sql
CREATE DATABASE IF NOT EXISTS agg_lab;
USE agg_lab;
```

Result: database `agg_lab` created and selected.

### 2.2 Create tables

| Table | Columns | Keys |
|---|---|---|
| `Customer` | CustID, CustName, City, JoinDate | PK: CustID |
| `Product` | ProdID, ProdName, Category, Price, StockQty | PK: ProdID |
| `OrderItem` | OrderID, CustID, ProdID, Quantity, OrderDate | PK: OrderID; FK: CustID → Customer; FK: ProdID → Product |

```sql
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
```

### 2.3 Insert data

```sql
INSERT INTO Customer  VALUES ( ... 8 rows ... );
INSERT INTO Product   VALUES ( ... 10 rows ... );
INSERT INTO OrderItem VALUES ( ... 15 rows ... );
```

Result: 8 customers, 10 products, 15 order lines inserted. The data deliberately contains gaps — one customer with no `City`, and a spread of `OrderDate`s across 2023 and 2024 — so `COUNT`, `DISTINCT`, and date aggregates return meaningful results.

### 2.4 Verification

**Row counts**

```sql
SELECT
  (SELECT COUNT(*) FROM Customer)  AS customers,
  (SELECT COUNT(*) FROM Product)   AS products,
  (SELECT COUNT(*) FROM OrderItem) AS orderItems;
```

| customers | products | orderItems |
|---|---|---|
| 8 | 10 | 15 |

**Deliberate gap check**

```sql
SELECT CustName FROM Customer WHERE City IS NULL;
```

| Customer with no city |
|---|
| Fatima Sheikh |

---

## 3. Task Results

### Task A1

**Requirement:** Total number of customers, products, and orders.

```sql
SELECT
    (SELECT COUNT(*) FROM Customer)  AS TotalCustomers,
    (SELECT COUNT(*) FROM Product)   AS TotalProducts,
    (SELECT COUNT(*) FROM OrderItem) AS TotalOrders;
```

**Result** (1 row)

| TotalCustomers | TotalProducts | TotalOrders |
|---|---|---|
| 8 | 10 | 15 |

### Task A2

**Requirement:** Cheapest and most expensive product.

```sql
SELECT MIN(Price) AS MinPrice,
       MAX(Price) AS MaxPrice
FROM Product;
```

**Result** (1 row)

| MinPrice | MaxPrice |
|---|---|
| 350.00 | 185000.00 |

**Note:** `MinPrice` is Notebook A4, `MaxPrice` is Laptop Pro 15 — `MIN`/`MAX` return the value, not the row, so a separate lookup query is needed to name the product.

### Task A3

**Requirement:** Average price of all products, rounded to 2 decimals.

```sql
SELECT ROUND(AVG(Price), 2) AS AvgPrice
FROM Product;
```

**Result** (1 row)

| AvgPrice |
|---|
| 26265.05 |

**Note:** `AVG` divides by the number of products (10), not by `SUM(StockQty)` or any other count — a common mix-up.

### Task A4

**Requirement:** Total stock quantity across all products.

```sql
SELECT SUM(StockQty) AS TotalStock
FROM Product;
```

**Result** (1 row)

| TotalStock |
|---|
| 618 |

### Task A5

**Requirement:** Distinct cities customers live in, ignoring NULL.

```sql
SELECT COUNT(DISTINCT City) AS DistinctCities
FROM Customer;
```

**Result** (1 row)

| DistinctCities |
|---|
| 3 |

**Note:** `COUNT(DISTINCT col)` silently drops NULLs on its own — Fatima Sheikh's missing city is excluded without any extra `WHERE` clause.

### Task A6

**Requirement:** Distinct product categories.

```sql
SELECT COUNT(DISTINCT Category) AS DistinctCategories
FROM Product;
```

**Result** (1 row)

| DistinctCategories |
|---|
| 4 |

### Task A7

**Requirement:** Customers with a recorded city / without a recorded city (two queries).

```sql
SELECT COUNT(City) AS WithCity
FROM Customer;

SELECT COUNT(*) - COUNT(City) AS WithoutCity
FROM Customer;
```

**Result**

| WithCity |
|---|
| 7 |

| WithoutCity |
|---|
| 1 |

**Note:** `COUNT(col)` counts non-NULL values only, while `COUNT(*)` counts rows regardless of NULLs — the gap between the two (`8 − 7 = 1`) is exactly the customers missing a city.

### Task A8

**Requirement:** Earliest and latest order date.

```sql
SELECT MIN(OrderDate) AS EarliestOrder,
       MAX(OrderDate) AS LatestOrder
FROM OrderItem;
```

**Result** (1 row)

| EarliestOrder | LatestOrder |
|---|---|
| 2023-03-10 | 2024-10-11 |

**Note:** `MIN`/`MAX` work on `DATE` columns the same way they work on numbers — chronologically earliest/latest, not alphabetically.

### Task A9

**Requirement:** Total revenue from all orders (`Quantity * Price`).

```sql
SELECT SUM(o.Quantity * p.Price) AS TotalRevenue
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID;
```

**Result** (1 row)

| TotalRevenue |
|---|
| 476800.45 |

**Note:** Revenue isn't a stored column — it only exists after joining `OrderItem` to `Product` to pair each line's `Quantity` with that product's `Price`, then aggregating the product of the two.

### Task A10

**Requirement:** Average quantity per order, rounded to 2 decimals.

```sql
SELECT ROUND(AVG(Quantity), 2) AS AvgQuantityPerOrder
FROM OrderItem;
```

**Result** (1 row)

| AvgQuantityPerOrder |
|---|
| 2.53 |

---

## 4. Summary

| Task | Concept | Result |
|---|---|---|
| A1 | COUNT(*) via scalar subqueries | 8 / 10 / 15 |
| A2 | MIN, MAX | 350.00 / 185000.00 |
| A3 | AVG + ROUND | 26265.05 |
| A4 | SUM | 618 |
| A5 | COUNT(DISTINCT) | 3 |
| A6 | COUNT(DISTINCT) | 4 |
| A7 | COUNT(col) vs COUNT(*) | 7 / 1 |
| A8 | MIN, MAX on DATE | 2023-03-10 / 2024-10-11 |
| A9 | SUM over a JOIN expression | 476800.45 |
| A10 | AVG + ROUND | 2.53 |

## 5. Key Takeaways

- `COUNT(*)` counts rows; `COUNT(column)` counts only non-NULL values in that column — the difference is how you find missing data (Task A7).
- `COUNT(DISTINCT column)` already excludes NULLs, so no extra filtering is needed to get a clean distinct count (Tasks A5, A6).
- `MIN`/`MAX`/`AVG`/`SUM` all ignore NULLs automatically; they never error out on a NULL-containing column.
- An aggregate function can reach across a `JOIN`: `SUM(o.Quantity * p.Price)` aggregates a value that doesn't exist as a column in either table alone (Task A9).
- `ROUND(x, 2)` is applied around the aggregate, not around each row's raw value.

## 6. Files

- `RollNo_Lab12_PartA.sql` — database setup and all 10 Part A tasks
