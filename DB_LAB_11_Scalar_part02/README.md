# Lab 11: Scalar SQL Functions (Part B)

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1?logo=mysql&logoColor=white)
![Topic](https://img.shields.io/badge/Topic-NUMERIC%20%7C%20DATE%2FTIME%20FUNCTIONS-e67e22)
![Tasks](https://img.shields.io/badge/Tasks-15%2F15-brightgreen)
![Database](https://img.shields.io/badge/Database-scalar__lab-lightgrey)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | Numeric functions (ROUND, CEIL, FLOOR, MOD) and date/time functions (DATEDIFF, TIMESTAMPDIFF, DATE_ADD/SUB, DATE_FORMAT) |
| **Database** | `scalar_lab` |
| **Tables** | `Customer`, `Product` |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Apply MySQL's **numeric** and **date/time** scalar functions for rounding, arithmetic, and date reporting on the `Customer` / `Product` dataset (Part B, 15 tasks). The script repeats the Lab 10 setup, so it runs standalone.

## 2. Database Setup

### 2.1 Create and select database

```sql
CREATE DATABASE IF NOT EXISTS scalar_lab;
USE scalar_lab;

DROP TABLE IF EXISTS Product, Customer;
```

Result: database `scalar_lab` created and selected; tables rebuilt from scratch.

### 2.2 Tables

The same two tables as Lab 10 are created (`Customer`, `Product`) — see Lab 10's README for the full `CREATE TABLE` statements.

### 2.3 Insert data

```sql
INSERT INTO Customer VALUES ( ... 8 rows ... );
INSERT INTO Product  VALUES ( ... 10 rows ... );
```

Result: 8 customers and 10 products inserted.

### 2.4 Verification

**Row counts**

| Table | Rows |
|---|---|
| Customer | 8 |
| Product | 10 |

**Note on date-dependent results:** Several tasks below use `CURDATE()` (ages, tenure, "days since"). All computed values in this document reflect the date the report was generated — **2026-09-19** — and will shift slightly if the queries are re-run on a different day.

---

## 3. Task Results

### Task B1

**Requirement:** Apply a 15% discount to every product.

```sql
SELECT ProdName,
       Price,
       ROUND(Price * 0.85, 2) AS DiscountedPrice
FROM Product;
```

**Result** (10 rows)

| ProdName | Price | DiscountedPrice |
|---|---|---|
| Laptop Pro 15 | 185000.00 | 157250.00 |
| Wireless Mouse | 2500.00 | 2125.00 |
| USB-C Cable | 800.00 | 680.00 |
| Office Chair | 18500.00 | 15725.00 |
| Standing Desk | 45000.50 | 38250.43 |
| Notebook A4 | 350.00 | 297.50 |
| Ballpoint Pen 10pk | 450.00 | 382.50 |
| Coffee Beans 1kg | 1899.99 | 1614.99 |
| Green Tea Box | 650.00 | 552.50 |
| Bluetooth Speaker | 7500.00 | 6375.00 |

### Task B2

**Requirement:** Compute 17% sales tax and the final price for each product.

```sql
SELECT ProdName,
       Price,
       ROUND(Price * 0.17, 2) AS Tax,
       ROUND(Price * 1.17, 2) AS PriceWithTax
FROM Product;
```

**Result** (10 rows)

| ProdName | Price | Tax | PriceWithTax |
|---|---|---|---|
| Laptop Pro 15 | 185000.00 | 31450.00 | 216450.00 |
| Wireless Mouse | 2500.00 | 425.00 | 2925.00 |
| USB-C Cable | 800.00 | 136.00 | 936.00 |
| Office Chair | 18500.00 | 3145.00 | 21645.00 |
| Standing Desk | 45000.50 | 7650.09 | 52650.59 |
| Notebook A4 | 350.00 | 59.50 | 409.50 |
| Ballpoint Pen 10pk | 450.00 | 76.50 | 526.50 |
| Coffee Beans 1kg | 1899.99 | 323.00 | 2222.99 |
| Green Tea Box | 650.00 | 110.50 | 760.50 |
| Bluetooth Speaker | 7500.00 | 1275.00 | 8775.00 |

### Task B3

**Requirement:** Compute the floor and ceiling of each product's price divided by 1000.

```sql
SELECT ProdName,
       Price,
       FLOOR(Price / 1000) AS FloorVal,
       CEIL(Price / 1000) AS CeilVal
FROM Product;
```

**Result** (10 rows)

| ProdName | Price | FloorVal | CeilVal |
|---|---|---|---|
| Laptop Pro 15 | 185000.00 | 185 | 185 |
| Wireless Mouse | 2500.00 | 2 | 3 |
| USB-C Cable | 800.00 | 0 | 1 |
| Office Chair | 18500.00 | 18 | 19 |
| Standing Desk | 45000.50 | 45 | 46 |
| Notebook A4 | 350.00 | 0 | 1 |
| Ballpoint Pen 10pk | 450.00 | 0 | 1 |
| Coffee Beans 1kg | 1899.99 | 1 | 2 |
| Green Tea Box | 650.00 | 0 | 1 |
| Bluetooth Speaker | 7500.00 | 7 | 8 |

**Note:** `FloorVal` equals `CeilVal` only when the division is exact (Laptop Pro 15: 185000 / 1000 = 185.0).

### Task B4

**Requirement:** Round each product's price to the nearest hundred.

```sql
SELECT ProdName,
       Price,
       ROUND(Price, -2) AS RoundedToHundred
FROM Product;
```

**Result** (10 rows)

| ProdName | Price | RoundedToHundred |
|---|---|---|
| Laptop Pro 15 | 185000.00 | 185000 |
| Wireless Mouse | 2500.00 | 2500 |
| USB-C Cable | 800.00 | 800 |
| Office Chair | 18500.00 | 18500 |
| Standing Desk | 45000.50 | 45000 |
| Notebook A4 | 350.00 | 400 |
| Ballpoint Pen 10pk | 450.00 | 500 |
| Coffee Beans 1kg | 1899.99 | 1900 |
| Green Tea Box | 650.00 | 700 |
| Bluetooth Speaker | 7500.00 | 7500 |

**Note:** A negative second argument (`-2`) rounds to the hundreds place instead of decimal places. Exact halfway values (350, 450, 650) round away from zero.

### Task B5

**Requirement:** List products with an odd ProdID.

```sql
SELECT ProdID, ProdName
FROM Product
WHERE MOD(ProdID, 2) = 1;
```

**Result** (5 rows)

| ProdID | ProdName |
|---|---|
| 101 | Laptop Pro 15 |
| 103 | USB-C Cable |
| 105 | Standing Desk |
| 107 | Ballpoint Pen 10pk |
| 109 | Green Tea Box |

### Task B6

**Requirement:** Show the year, month name, and day of week each customer joined.

```sql
SELECT CustName,
       JoinDate,
       YEAR(JoinDate) AS JoinYear,
       MONTHNAME(JoinDate) AS JoinMonth,
       DAYNAME(JoinDate) AS JoinDay
FROM Customer;
```

**Result** (8 rows)

| CustName | JoinDate | JoinYear | JoinMonth | JoinDay |
|---|---|---|---|---|
| Ali Khan | 2022-01-15 | 2022 | January | Saturday |
| Sara Iqbal | 2022-04-22 | 2022 | April | Friday |
| Hamza Raza | 2023-02-10 | 2023 | February | Friday |
| Ayesha Noor | 2023-05-18 | 2023 | May | Thursday |
| Bilal Ahmed | 2023-09-01 | 2023 | September | Friday |
| Fatima Sheikh | 2024-01-12 | 2024 | January | Friday |
| Usman Tariq | 2024-06-30 | 2024 | June | Sunday |
| Maira Javed | 2024-08-25 | 2024 | August | Sunday |

### Task B7

**Requirement:** Format each customer's DOB as `'DD-Month-YYYY'`.

```sql
SELECT CustName,
       DOB,
       DATE_FORMAT(DOB, '%d-%M-%Y') AS FormattedDOB
FROM Customer;
```

**Result** (8 rows)

| CustName | DOB | FormattedDOB |
|---|---|---|
| Ali Khan | 1995-04-12 | 12-April-1995 |
| Sara Iqbal | 1998-11-20 | 20-November-1998 |
| Hamza Raza | 1997-08-05 | 05-August-1997 |
| Ayesha Noor | 1999-02-14 | 14-February-1999 |
| Bilal Ahmed | 2000-06-30 | 30-June-2000 |
| Fatima Sheikh | 1996-10-25 | 25-October-1996 |
| Usman Tariq | 2001-03-18 | 18-March-2001 |
| Maira Javed | 1994-12-09 | 09-December-1994 |

### Task B8

**Requirement:** Compute each customer's current age using `TIMESTAMPDIFF`.

```sql
SELECT CustName,
       DOB,
       TIMESTAMPDIFF(YEAR, DOB, CURDATE()) AS Age
FROM Customer;
```

**Result as of 2026-09-19** (8 rows)

| CustName | DOB | Age |
|---|---|---|
| Ali Khan | 1995-04-12 | 31 |
| Sara Iqbal | 1998-11-20 | 27 |
| Hamza Raza | 1997-08-05 | 29 |
| Ayesha Noor | 1999-02-14 | 27 |
| Bilal Ahmed | 2000-06-30 | 26 |
| Fatima Sheikh | 1996-10-25 | 29 |
| Usman Tariq | 2001-03-18 | 25 |
| Maira Javed | 1994-12-09 | 31 |

**Note:** `TIMESTAMPDIFF(YEAR, ...)` correctly accounts for whether the birthday has already passed this year (e.g. Sara Iqbal's Nov 20 birthday hasn't occurred yet, so she's still 27, not 28).

### Task B9

**Requirement:** Compute how many days ago each customer joined.

```sql
SELECT CustName,
       JoinDate,
       DATEDIFF(CURDATE(), JoinDate) AS DaysSinceJoin
FROM Customer;
```

**Result as of 2026-09-19** (8 rows)

| CustName | JoinDate | DaysSinceJoin |
|---|---|---|
| Ali Khan | 2022-01-15 | 1708 |
| Sara Iqbal | 2022-04-22 | 1611 |
| Hamza Raza | 2023-02-10 | 1317 |
| Ayesha Noor | 2023-05-18 | 1220 |
| Bilal Ahmed | 2023-09-01 | 1114 |
| Fatima Sheikh | 2024-01-12 | 981 |
| Usman Tariq | 2024-06-30 | 811 |
| Maira Javed | 2024-08-25 | 755 |

### Task B10

**Requirement:** List customers who joined in the year 2023, using a date function (not `BETWEEN`).

```sql
SELECT CustName, JoinDate
FROM Customer
WHERE YEAR(JoinDate) = 2023;
```

**Result** (3 rows)

| CustName | JoinDate |
|---|---|
| Hamza Raza | 2023-02-10 |
| Ayesha Noor | 2023-05-18 |
| Bilal Ahmed | 2023-09-01 |

### Task B11

**Requirement:** List products launched in any year's Q4 (October, November, December).

```sql
SELECT ProdName, LaunchDate
FROM Product
WHERE MONTH(LaunchDate) IN (10, 11, 12);
```

**Result** (2 rows)

| ProdName | LaunchDate |
|---|---|
| USB-C Cable | 2021-11-05 |
| Green Tea Box | 2022-12-12 |

### Task B12

**Requirement:** List customers who joined within the last 6 months from today.

```sql
SELECT CustName, JoinDate
FROM Customer
WHERE JoinDate >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
```

**Result as of 2026-09-19** (0 rows)

_Empty set._

**Note:** 6 months before 2026-09-19 is 2026-03-19. Every customer's `JoinDate` in this dataset is earlier than that (the most recent is Maira Javed, 2024-08-25), so no rows qualify — the empty set is the correct answer here, not a mistake.

### Task B13

**Requirement:** Calculate each product's age in days (days since launch).

```sql
SELECT ProdName,
       LaunchDate,
       DATEDIFF(CURDATE(), LaunchDate) AS AgeInDays
FROM Product;
```

**Result as of 2026-09-19** (10 rows)

| ProdName | LaunchDate | AgeInDays |
|---|---|---|
| Laptop Pro 15 | 2023-03-10 | 1289 |
| Wireless Mouse | 2022-07-22 | 1520 |
| USB-C Cable | 2021-11-05 | 1779 |
| Office Chair | 2023-01-15 | 1343 |
| Standing Desk | 2024-02-28 | 934 |
| Notebook A4 | 2020-04-01 | 2362 |
| Ballpoint Pen 10pk | 2020-04-01 | 2362 |
| Coffee Beans 1kg | 2023-09-20 | 1095 |
| Green Tea Box | 2022-12-12 | 1377 |
| Bluetooth Speaker | 2024-05-18 | 854 |

### Task B14

**Requirement:** Compute the date exactly 90 days after each product's LaunchDate.

```sql
SELECT ProdName,
       LaunchDate,
       DATE_ADD(LaunchDate, INTERVAL 90 DAY) AS NinetyDaysLater
FROM Product;
```

**Result** (10 rows)

| ProdName | LaunchDate | NinetyDaysLater |
|---|---|---|
| Laptop Pro 15 | 2023-03-10 | 2023-06-08 |
| Wireless Mouse | 2022-07-22 | 2022-10-20 |
| USB-C Cable | 2021-11-05 | 2022-02-03 |
| Office Chair | 2023-01-15 | 2023-04-15 |
| Standing Desk | 2024-02-28 | 2024-05-28 |
| Notebook A4 | 2020-04-01 | 2020-06-30 |
| Ballpoint Pen 10pk | 2020-04-01 | 2020-06-30 |
| Coffee Beans 1kg | 2023-09-20 | 2023-12-19 |
| Green Tea Box | 2022-12-12 | 2023-03-12 |
| Bluetooth Speaker | 2024-05-18 | 2024-08-16 |

**Note:** `DATE_ADD` needs the `INTERVAL` keyword — `DATE_ADD(d, 90 DAY)` without it is a syntax error.

### Task B15

**Requirement:** Combined challenge — a single `Summary` column: `'Hello ALI KHAN, age 31, joined Jan 2022'`.

```sql
SELECT CONCAT(
           'Hello ', UPPER(TRIM(CustName)),
           ', age ', TIMESTAMPDIFF(YEAR, DOB, CURDATE()),
           ', joined ', DATE_FORMAT(JoinDate, '%b %Y')
       ) AS Summary
FROM Customer;
```

**Result as of 2026-09-19** (8 rows)

| Summary |
|---|
| Hello ALI KHAN, age 31, joined Jan 2022 |
| Hello SARA IQBAL, age 27, joined Apr 2022 |
| Hello HAMZA RAZA, age 29, joined Feb 2023 |
| Hello AYESHA NOOR, age 27, joined May 2023 |
| Hello BILAL AHMED, age 26, joined Sep 2023 |
| Hello FATIMA SHEIKH, age 29, joined Jan 2024 |
| Hello USMAN TARIQ, age 25, joined Jun 2024 |
| Hello MAIRA JAVED, age 31, joined Aug 2024 |

**Note:** Four functions nest here — `UPPER(TRIM(...))` for the name and `DATE_FORMAT` for the month — all wrapped inside one `CONCAT`. Building it up piece by piece (name first, then age, then date) avoids a hard-to-locate syntax error.

---

## 4. Summary

| Task | Concept | Rows returned |
|---|---|---|
| B1 | ROUND | 10 |
| B2 | ROUND (tax + total) | 10 |
| B3 | FLOOR / CEIL | 10 |
| B4 | ROUND with negative decimals | 10 |
| B5 | MOD | 5 |
| B6 | YEAR / MONTHNAME / DAYNAME | 8 |
| B7 | DATE_FORMAT | 8 |
| B8 | TIMESTAMPDIFF (age) | 8 |
| B9 | DATEDIFF | 8 |
| B10 | YEAR + WHERE | 3 |
| B11 | MONTH + IN | 2 |
| B12 | DATE_SUB + INTERVAL | 0 |
| B13 | DATEDIFF (tenure) | 10 |
| B14 | DATE_ADD + INTERVAL | 10 |
| B15 | Combined nesting (CONCAT + 3 functions) | 8 |

## 5. Key Takeaways

- `DATEDIFF` always returns **days**; `TIMESTAMPDIFF` lets you pick the unit and correctly handles leap years and month length — the right choice for ages and tenure.
- `ROUND(n, -2)` rounds to the **hundreds** place; a negative second argument moves left of the decimal point instead of right.
- `DATE_ADD` / `DATE_SUB` require the `INTERVAL` keyword — a common syntax mistake to avoid.
- An **empty result set** (Task B12) can be the correct answer; it's worth verifying by checking the underlying data rather than assuming the query is wrong.
- `%m` (numeric month) and `%M` (full month name) are easy to confuse in `DATE_FORMAT` — case matters.

## 6. Files

- `RollNo_Lab11_NumericDateFunctions.sql` — database setup and all 15 Part B tasks
