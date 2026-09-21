# Lab 12: Aggregate Functions (Part B)

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1?logo=mysql&logoColor=white)
![Topic](https://img.shields.io/badge/Topic-GROUP%20BY%20%7C%20HAVING%20%7C%20JOINS-0aa)
![Tasks](https://img.shields.io/badge/Tasks-17-success)
![Database](https://img.shields.io/badge/Database-agg__lab-lightgrey)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | `GROUP BY`, `HAVING`, aggregates over joins, `LIMIT` |
| **Database** | `agg_lab` |
| **Tables** | `Customer`, `Product`, `OrderItem` |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Group rows into buckets and summarise each bucket with `GROUP BY`, filter groups with `HAVING`, and combine both with joins, `LEFT JOIN`, and `LIMIT` (17 tasks). Uses the same `agg_lab` database built in Part A.

## 2. Database Setup

```sql
USE agg_lab;
```

Part B reuses `Customer`, `Product`, and `OrderItem` exactly as created and populated in `RollNo_Lab12_PartA.sql` — run that script first if starting fresh.

**Row counts** (carried over from Part A)

| Table | Rows |
|---|---|
| Customer | 8 |
| Product | 10 |
| OrderItem | 15 |

---

## 3. Task Results

### Task B1

**Requirement:** Number of customers in each city, sorted by count descending.

```sql
SELECT City, COUNT(*) AS NumCustomers
FROM Customer
GROUP BY City
ORDER BY NumCustomers DESC;
```

**Result** (4 rows)

| City | NumCustomers |
|---|---|
| Lahore | 3 |
| Karachi | 2 |
| Islamabad | 2 |
| NULL | 1 |

**Note:** MySQL groups NULL `City` into its own bucket rather than dropping it — Fatima Sheikh still gets counted, just under a NULL group.

### Task B2

**Requirement:** Number of products in each category, sorted by count descending.

```sql
SELECT Category, COUNT(*) AS NumProducts
FROM Product
GROUP BY Category
ORDER BY NumProducts DESC;
```

**Result** (4 rows)

| Category | NumProducts |
|---|---|
| Electronics | 4 |
| Furniture | 2 |
| Stationery | 2 |
| Grocery | 2 |

### Task B3

**Requirement:** Average, minimum, and maximum price per category, sorted by average price descending.

```sql
SELECT Category,
       ROUND(AVG(Price), 2) AS AvgPrice,
       MIN(Price) AS MinPrice,
       MAX(Price) AS MaxPrice
FROM Product
GROUP BY Category
ORDER BY AvgPrice DESC;
```

**Result** (4 rows)

| Category | AvgPrice | MinPrice | MaxPrice |
|---|---|---|---|
| Electronics | 48950.00 | 800.00 | 185000.00 |
| Furniture | 31750.25 | 18500.00 | 45000.50 |
| Grocery | 1275.00 | 650.00 | 1899.99 |
| Stationery | 400.00 | 350.00 | 450.00 |

**Note:** Three aggregates in one `GROUP BY` — each is computed independently per group from the same rows.

### Task B4

**Requirement:** Total stock quantity per category, sorted by total descending.

```sql
SELECT Category, SUM(StockQty) AS TotalStock
FROM Product
GROUP BY Category
ORDER BY TotalStock DESC;
```

**Result** (4 rows)

| Category | TotalStock |
|---|---|
| Stationery | 350 |
| Electronics | 180 |
| Grocery | 75 |
| Furniture | 13 |

**Note:** Ranking flips versus Task B3 — Stationery has the lowest average price but the highest stock, because it's cheap, bulky-stocked office supplies rather than a few expensive items.

### Task B5

**Requirement:** Number of orders placed each year, sorted by year.

```sql
SELECT YEAR(OrderDate) AS OrderYear, COUNT(*) AS NumOrders
FROM OrderItem
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;
```

**Result** (2 rows)

| OrderYear | NumOrders |
|---|---|
| 2023 | 7 |
| 2024 | 8 |

**Note:** `GROUP BY` accepts an expression (`YEAR(OrderDate)`), not just a raw column — MySQL groups rows by the computed value.

### Task B6

**Requirement:** Number of orders placed each month of 2024, sorted by month.

```sql
SELECT MONTH(OrderDate) AS OrderMonth, COUNT(*) AS NumOrders
FROM OrderItem
WHERE YEAR(OrderDate) = 2024
GROUP BY MONTH(OrderDate)
ORDER BY OrderMonth;
```

**Result** (6 rows)

| OrderMonth | NumOrders |
|---|---|
| 1 | 2 |
| 2 | 1 |
| 4 | 2 |
| 7 | 1 |
| 9 | 1 |
| 10 | 1 |

**Note:** `WHERE` filters rows to 2024 *before* grouping, so months with zero 2024 orders (e.g. March, May) simply don't appear as groups — `WHERE` runs before `GROUP BY` in execution order.

### Task B7

**Requirement:** Product categories where the average price is greater than 5,000.

```sql
SELECT Category, ROUND(AVG(Price), 2) AS AvgPrice
FROM Product
GROUP BY Category
HAVING AVG(Price) > 5000;
```

**Result** (2 rows)

| Category | AvgPrice |
|---|---|
| Electronics | 48950.00 |
| Furniture | 31750.25 |

**Note:** `HAVING` filters *groups* after aggregation; `WHERE AVG(Price) > 5000` would be a syntax error since `WHERE` runs before `AVG` exists.

### Task B8

**Requirement:** Cities with more than 1 customer, excluding NULL city.

```sql
SELECT City, COUNT(*) AS NumCustomers
FROM Customer
WHERE City IS NOT NULL
GROUP BY City
HAVING COUNT(*) > 1
ORDER BY NumCustomers DESC;
```

**Result** (3 rows)

| City | NumCustomers |
|---|---|
| Lahore | 3 |
| Karachi | 2 |
| Islamabad | 2 |

**Note:** `WHERE` and `HAVING` do two different jobs here — `WHERE City IS NOT NULL` removes Fatima Sheikh's row before grouping even starts; `HAVING COUNT(*) > 1` then removes any city group left with just one customer (there happen to be none left after the NULL is gone).

### Task B9

**Requirement:** Number of orders per customer, including customers with zero orders.

```sql
SELECT c.CustID,
       c.CustName,
       COUNT(o.OrderID) AS NumOrders
FROM Customer c
LEFT JOIN OrderItem o ON c.CustID = o.CustID
GROUP BY c.CustID, c.CustName;
```

**Result** (8 rows)

| CustID | CustName | NumOrders |
|---|---|---|
| 1 | Ali Khan | 2 |
| 2 | Sara Iqbal | 3 |
| 3 | Hamza Raza | 3 |
| 4 | Ayesha Noor | 1 |
| 5 | Bilal Ahmed | 2 |
| 6 | Fatima Sheikh | 1 |
| 7 | Usman Tariq | 3 |
| 8 | Maira Javed | 0 |

**Note:** `COUNT(o.OrderID)` — the joined table's column — correctly returns `0` for Maira Javed; `COUNT(*)` would have wrongly counted her one unmatched LEFT JOIN row as `1`.

### Task B10

**Requirement:** Total quantity sold per product, including products never sold, sorted by total descending.

```sql
SELECT p.ProdName,
       SUM(o.Quantity) AS TotalQty
FROM Product p
LEFT JOIN OrderItem o ON p.ProdID = o.ProdID
GROUP BY p.ProdID, p.ProdName
ORDER BY TotalQty DESC;
```

**Result** (10 rows)

| ProdName | TotalQty |
|---|---|
| Notebook A4 | 15 |
| Coffee Beans 1kg | 5 |
| USB-C Cable | 4 |
| Wireless Mouse | 3 |
| Green Tea Box | 3 |
| Laptop Pro 15 | 2 |
| Ballpoint Pen 10pk | 2 |
| Bluetooth Speaker | 2 |
| Office Chair | 1 |
| Standing Desk | 1 |

**Note:** Every product in this dataset was ordered at least once, so `LEFT JOIN` behaves like `INNER JOIN` here — it would only matter if a product had zero matching `OrderItem` rows, in which case `SUM` returns NULL rather than 0.

### Task B11

**Requirement:** Total revenue per product category, sorted by revenue descending.

```sql
SELECT p.Category,
       SUM(o.Quantity * p.Price) AS Revenue
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID
GROUP BY p.Category
ORDER BY Revenue DESC;
```

**Result** (4 rows)

| Category | Revenue |
|---|---|
| Electronics | 395700.00 |
| Furniture | 63500.50 |
| Grocery | 11449.95 |
| Stationery | 6150.00 |

**Note:** The four values sum to `476800.45` — the same `TotalRevenue` from Task A9, just broken down by category instead of collapsed into one number.

### Task B12

**Requirement:** Total spend per customer, including customers with no orders, sorted by spend descending.

```sql
SELECT c.CustName,
       SUM(o.Quantity * p.Price) AS TotalSpend
FROM Customer c
LEFT JOIN OrderItem o ON c.CustID = o.CustID
LEFT JOIN Product p ON o.ProdID = p.ProdID
GROUP BY c.CustID, c.CustName
ORDER BY TotalSpend DESC;
```

**Result** (8 rows)

| CustName | TotalSpend |
|---|---|
| Hamza Raza | 196299.98 |
| Ali Khan | 190000.00 |
| Fatima Sheikh | 45000.50 |
| Sara Iqbal | 27750.00 |
| Usman Tariq | 6350.00 |
| Bilal Ahmed | 5700.00 |
| Ayesha Noor | 5699.97 |
| Maira Javed | NULL |

**Note:** Both joins must be `LEFT JOIN` — if `Product` were joined with `INNER JOIN`, Maira Javed (who has no `OrderItem` row to reach `Product` through) would vanish instead of showing `NULL`. `ORDER BY ... DESC` puts NULL last, since MySQL treats NULL as the lowest possible value.

### Task B13

**Requirement:** Customers whose total spend exceeds 50,000.

```sql
SELECT c.CustName,
       SUM(o.Quantity * p.Price) AS TotalSpend
FROM Customer c
JOIN OrderItem o ON c.CustID = o.CustID
JOIN Product p   ON o.ProdID = p.ProdID
GROUP BY c.CustID, c.CustName
HAVING SUM(o.Quantity * p.Price) > 50000;
```

**Result** (2 rows)

| CustName | TotalSpend |
|---|---|
| Ali Khan | 190000.00 |
| Hamza Raza | 196299.98 |

**Note:** Plain `JOIN` (inner) is intentional here — a customer with zero orders can never clear a `> 50000` bar anyway, so there's no need to preserve them with a `LEFT JOIN`. Fatima Sheikh (45000.50) falls just short of the threshold and is correctly excluded.

### Task B14

**Requirement:** Per city, count of customers and total revenue; only cities with more than 1 customer.

```sql
SELECT c.City,
       COUNT(DISTINCT c.CustID) AS NumCustomers,
       SUM(o.Quantity * p.Price) AS CityRevenue
FROM Customer c
JOIN OrderItem o ON c.CustID = o.CustID
JOIN Product p   ON o.ProdID = p.ProdID
GROUP BY c.City
HAVING COUNT(DISTINCT c.CustID) > 1;
```

**Result** (2 rows)

| City | NumCustomers | CityRevenue |
|---|---|---|
| Lahore | 3 | 392649.98 |
| Karachi | 2 | 33450.00 |

**Note:** Because the joins are `INNER JOIN`, only customers with at least one order are counted per city. Islamabad drops out of contention even though it has 2 customers on paper — Maira Javed has no orders to join through, leaving Islamabad with only 1 *counted* customer (Ayesha Noor), which fails the `HAVING > 1` bar. `COUNT(DISTINCT c.CustID)` (not plain `COUNT(*)`) avoids overcounting a customer who placed several orders.

### Task B15

**Requirement:** Top 3 best-selling products by total quantity sold.

```sql
SELECT p.ProdName,
       SUM(o.Quantity) AS TotalQty
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID
GROUP BY p.ProdID, p.ProdName
ORDER BY TotalQty DESC
LIMIT 3;
```

**Result** (3 rows)

| ProdName | TotalQty |
|---|---|
| Notebook A4 | 15 |
| Coffee Beans 1kg | 5 |
| USB-C Cable | 4 |

**Note:** `LIMIT` is applied *after* `GROUP BY` and `ORDER BY` finish — it simply truncates the already-sorted result of Task B10 to the top 3 rows.

### Task B16

**Requirement:** Total revenue per year, sorted by year.

```sql
SELECT YEAR(o.OrderDate) AS OrderYear,
       SUM(o.Quantity * p.Price) AS Revenue
FROM OrderItem o
JOIN Product p ON o.ProdID = p.ProdID
GROUP BY YEAR(o.OrderDate)
ORDER BY OrderYear;
```

**Result** (2 rows)

| OrderYear | Revenue |
|---|---|
| 2023 | 408449.97 |
| 2024 | 68350.48 |

**Note:** 2023 dwarfs 2024 in revenue despite having fewer orders (7 vs 8, Task B5) — both high-ticket Laptop Pro 15 sales (`185000.00` each) fall in 2023.

### Task B17

**Requirement:** Average order value (revenue per order).

```sql
SELECT ROUND(AVG(OrderValue), 2) AS AvgOrderValue
FROM (
    SELECT o.OrderID,
           SUM(o.Quantity * p.Price) AS OrderValue
    FROM OrderItem o
    JOIN Product p ON o.ProdID = p.ProdID
    GROUP BY o.OrderID
) AS OrderValues;
```

**Result** (1 row)

| AvgOrderValue |
|---|
| 31786.70 |

**Note:** A single-line item order and an order's total value happen to coincide here (`OrderID` is already the finest grain), but the subquery pattern — aggregate per order first, then `AVG` the per-order totals — is what generalises correctly to a schema where one order can span several line items.

---

## 4. Summary

| Task | Concept | Result |
|---|---|---|
| B1 | GROUP BY + ORDER BY | Lahore 3, Karachi 2, Islamabad 2, NULL 1 |
| B2 | GROUP BY + ORDER BY | Electronics 4, others 2 |
| B3 | Multiple aggregates per group | Electronics avg 48950.00 |
| B4 | SUM per group | Stationery 350 |
| B5 | GROUP BY expression (YEAR) | 2023: 7, 2024: 8 |
| B6 | WHERE + GROUP BY expression | 6 months represented |
| B7 | HAVING on AVG | Electronics, Furniture |
| B8 | WHERE + GROUP BY + HAVING | Lahore, Karachi, Islamabad |
| B9 | LEFT JOIN + COUNT(fk col) | Maira Javed = 0 |
| B10 | LEFT JOIN + SUM | Notebook A4 = 15 |
| B11 | JOIN + SUM(expr) | Electronics 395700.00 |
| B12 | Double LEFT JOIN + SUM | Maira Javed = NULL |
| B13 | JOIN + HAVING on SUM | 2 customers > 50,000 |
| B14 | JOIN + COUNT(DISTINCT) + HAVING | Lahore, Karachi only |
| B15 | GROUP BY + ORDER BY + LIMIT | Top 3 products |
| B16 | JOIN + GROUP BY expression | 2023 > 2024 |
| B17 | Aggregate over a grouped subquery | 31786.70 |

## 5. Key Takeaways

- `WHERE` filters rows *before* grouping; `HAVING` filters groups *after* aggregation — `HAVING AVG(...)` works, `WHERE AVG(...)` does not.
- `GROUP BY` can group by an expression (`YEAR(OrderDate)`), not just a stored column.
- `COUNT(joined_table.col)` correctly returns 0 for an unmatched `LEFT JOIN` row; `COUNT(*)` would wrongly count it as 1.
- Using `INNER JOIN` instead of `LEFT JOIN` silently drops zero-order customers from a group — sometimes that's the point (Task B13), sometimes it changes the answer in a way worth double-checking (Task B14).
- To aggregate a value that depends on more than one order line (e.g. one true order total per `OrderID`), aggregate in a subquery first, then aggregate again over that result (Task B17).

## 6. Files

- `RollNo_Lab12_PartB.sql` — Tasks B1 to B17 (reuses the database built by `RollNo_Lab12_PartA.sql`)
