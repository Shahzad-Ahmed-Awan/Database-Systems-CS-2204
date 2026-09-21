# Lab 10: Scalar SQL Functions (Part A)

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1?logo=mysql&logoColor=white)
![Topic](https://img.shields.io/badge/Topic-STRING%20FUNCTIONS-9b59b6)
![Tasks](https://img.shields.io/badge/Tasks-12%2F12-brightgreen)
![Status](https://img.shields.io/badge/Status-Completed-success)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | String scalar functions: TRIM, UPPER/LOWER, CONCAT, SUBSTRING, LEFT/RIGHT, LPAD, LOCATE, REPLACE |
| **Database / Tables** | `scalar_lab` / `Customer`, `Product` |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Apply MySQL's built-in **string functions** to clean, format, and extract text from a deliberately messy `Customer` / `Product` dataset (Part A, 12 tasks).

## 2. Database Setup

### 2.1 Create and select database

```sql
CREATE DATABASE IF NOT EXISTS scalar_lab;
USE scalar_lab;
```

Result: database `scalar_lab` created and selected.

### 2.2 Create tables

| Table | Columns | Keys |
|---|---|---|
| `Customer` | CustID, CustName, Email, City, Phone, JoinDate, DOB | PK: CustID |
| `Product` | ProdID, ProdName, Category, Price, StockQty, LaunchDate | PK: ProdID |

```sql
CREATE TABLE Customer (
    CustID   INT PRIMARY KEY,
    CustName VARCHAR(60) NOT NULL,
    Email    VARCHAR(80),
    City     VARCHAR(30),
    Phone    VARCHAR(20),
    JoinDate DATE,
    DOB      DATE
);

CREATE TABLE Product (
    ProdID     INT PRIMARY KEY,
    ProdName   VARCHAR(60) NOT NULL,
    Category   VARCHAR(30),
    Price      DECIMAL(10,2),
    StockQty   INT,
    LaunchDate DATE
);
```

### 2.3 Insert data

```sql
INSERT INTO Customer VALUES ( ... 8 rows ... );
INSERT INTO Product  VALUES ( ... 10 rows ... );
```

Result: 8 customers and 10 products inserted. The data is deliberately messy — extra whitespace, mixed case, and NULLs — so the string functions have something real to clean up.

### 2.4 Verification

**Row counts**

| Table | Rows |
|---|---|
| Customer | 8 |
| Product | 10 |

**Deliberate messiness**

| Issue | Row(s) |
|---|---|
| Extra leading/trailing spaces in name | 1 — `' Ali Khan '` |
| ALL CAPS name | 3 — `HAMZA RAZA` |
| lowercase name | 5 — `bilal ahmed` |
| NULL email | 4 — Ayesha Noor |
| NULL city | 6 — Fatima Sheikh |
| NULL phone | 7 — Usman Tariq |

---

## 3. Task Results

### Task A1

**Requirement:** Remove leading/trailing spaces from each customer's name; show alongside the original.

```sql
SELECT CustID,
       CustName AS OriginalName,
       TRIM(CustName) AS CleanedName
FROM Customer;
```

**Result** (8 rows)

| CustID | OriginalName | CleanedName |
|---|---|---|
| 1 | `' Ali Khan '` | Ali Khan |
| 2 | Sara Iqbal | Sara Iqbal |
| 3 | HAMZA RAZA | HAMZA RAZA |
| 4 | Ayesha Noor | Ayesha Noor |
| 5 | bilal ahmed | bilal ahmed |
| 6 | Fatima Sheikh | Fatima Sheikh |
| 7 | Usman Tariq | Usman Tariq |
| 8 | Maira Javed | Maira Javed |

**Note:** Only row 1 has visible spaces to trim in this dataset; `TRIM` runs harmlessly on the rest.

### Task A2

**Requirement:** Show every name in UPPERCASE and lowercase.

```sql
SELECT CustID,
       UPPER(CustName) AS UpperName,
       LOWER(CustName) AS LowerName
FROM Customer;
```

**Result** (8 rows)

| CustID | UpperName | LowerName |
|---|---|---|
| 1 | `' ALI KHAN '` | `' ali khan '` |
| 2 | SARA IQBAL | sara iqbal |
| 3 | HAMZA RAZA | hamza raza |
| 4 | AYESHA NOOR | ayesha noor |
| 5 | BILAL AHMED | bilal ahmed |
| 6 | FATIMA SHEIKH | fatima sheikh |
| 7 | USMAN TARIQ | usman tariq |
| 8 | MAIRA JAVED | maira javed |

**Note:** `UPPER`/`LOWER` only change case — they do not trim. Row 1 keeps its surrounding spaces.

### Task A3

**Requirement:** Show the trimmed name and its character count.

```sql
SELECT CustID,
       TRIM(CustName) AS CleanedName,
       CHAR_LENGTH(TRIM(CustName)) AS NameLength
FROM Customer;
```

**Result** (8 rows)

| CustID | CleanedName | NameLength |
|---|---|---|
| 1 | Ali Khan | 8 |
| 2 | Sara Iqbal | 10 |
| 3 | HAMZA RAZA | 10 |
| 4 | Ayesha Noor | 11 |
| 5 | bilal ahmed | 11 |
| 6 | Fatima Sheikh | 13 |
| 7 | Usman Tariq | 11 |
| 8 | Maira Javed | 11 |

**Note:** `TRIM` is nested inside `CHAR_LENGTH` so the count reflects the cleaned name, not the padded original.

### Task A4

**Requirement:** Build a greeting column `'Dear <trimmed name>, welcome!'`.

```sql
SELECT CustID,
       CONCAT('Dear ', TRIM(CustName), ', welcome!') AS Greeting
FROM Customer;
```

**Result** (8 rows)

| CustID | Greeting |
|---|---|
| 1 | Dear Ali Khan, welcome! |
| 2 | Dear Sara Iqbal, welcome! |
| 3 | Dear HAMZA RAZA, welcome! |
| 4 | Dear Ayesha Noor, welcome! |
| 5 | Dear bilal ahmed, welcome! |
| 6 | Dear Fatima Sheikh, welcome! |
| 7 | Dear Usman Tariq, welcome! |
| 8 | Dear Maira Javed, welcome! |

### Task A5

**Requirement:** For customers with an email, extract the username (part before `@`).

```sql
SELECT CustName,
       SUBSTRING(Email, 1, LOCATE('@', Email) - 1) AS Username
FROM Customer
WHERE Email IS NOT NULL;
```

**Result** (7 rows)

| CustName | Username |
|---|---|
| ` Ali Khan ` | ali.khan |
| Sara Iqbal | sara |
| HAMZA RAZA | hamza |
| bilal ahmed | bilal |
| Fatima Sheikh | fatima |
| Usman Tariq | usman |
| Maira Javed | maira |

**Note:** 8 customers in, 7 rows out — Ayesha Noor (CustID 4) has a NULL email and is excluded by the `WHERE` clause.

### Task A6

**Requirement:** For customers with an email, extract the domain (part after `@`).

```sql
SELECT CustName,
       SUBSTRING(Email, LOCATE('@', Email) + 1) AS Domain
FROM Customer
WHERE Email IS NOT NULL;
```

**Result** (7 rows)

| CustName | Domain |
|---|---|
| ` Ali Khan ` | MAIL.com |
| Sara Iqbal | example.com |
| HAMZA RAZA | example.com |
| bilal ahmed | MAIL.COM |
| Fatima Sheikh | example.com |
| Usman Tariq | example.com |
| Maira Javed | example.com |

**Note:** Domains keep their original casing (`MAIL.com`, `MAIL.COM`) since no case function is applied here.

### Task A7

**Requirement:** Show each customer's name using only the first 3 characters.

```sql
SELECT CustID,
       LEFT(CustName, 3) AS ShortName
FROM Customer;
```

**Result** (8 rows)

| CustID | ShortName |
|---|---|
| 1 | ` Al` |
| 2 | Sar |
| 3 | HAM |
| 4 | Aye |
| 5 | bil |
| 6 | Fat |
| 7 | Usm |
| 8 | Mai |

**Note:** `LEFT` reads the raw (untrimmed) column, so row 1's result starts with the leading space.

### Task A8

**Requirement:** Mask each phone number — keep the first 4 characters, replace the rest with `'XXX-XXXX'`. Skip customers with no phone.

```sql
SELECT CustName,
       Phone,
       CONCAT(LEFT(Phone, 4), 'XXX-XXXX') AS MaskedPhone
FROM Customer
WHERE Phone IS NOT NULL;
```

**Result** (7 rows)

| CustName | Phone | MaskedPhone |
|---|---|---|
| ` Ali Khan ` | 0300-1112233 | 0300XXX-XXXX |
| Sara Iqbal | 0301-4445566 | 0301XXX-XXXX |
| HAMZA RAZA | 0302-7778899 | 0302XXX-XXXX |
| Ayesha Noor | 0303-1234567 | 0303XXX-XXXX |
| bilal ahmed | 0304-2345678 | 0304XXX-XXXX |
| Fatima Sheikh | 0305-3456789 | 0305XXX-XXXX |
| Maira Javed | 0307-5678901 | 0307XXX-XXXX |

**Note:** Usman Tariq (CustID 7) has a NULL phone and is correctly skipped.

### Task A9

**Requirement:** Show every product name with spaces replaced by hyphens.

```sql
SELECT ProdID,
       REPLACE(ProdName, ' ', '-') AS SlugName
FROM Product;
```

**Result** (10 rows)

| ProdID | SlugName |
|---|---|
| 101 | Laptop-Pro-15 |
| 102 | Wireless-Mouse |
| 103 | USB-C-Cable |
| 104 | Office-Chair |
| 105 | Standing-Desk |
| 106 | Notebook-A4 |
| 107 | Ballpoint-Pen-10pk |
| 108 | Coffee-Beans-1kg |
| 109 | Green-Tea-Box |
| 110 | Bluetooth-Speaker |

### Task A10

**Requirement:** Show each ProdID padded to 5 digits with leading zeros.

```sql
SELECT ProdID,
       LPAD(ProdID, 5, '0') AS PaddedID
FROM Product;
```

**Result** (10 rows)

| ProdID | PaddedID |
|---|---|
| 101 | 00101 |
| 102 | 00102 |
| 103 | 00103 |
| 104 | 00104 |
| 105 | 00105 |
| 106 | 00106 |
| 107 | 00107 |
| 108 | 00108 |
| 109 | 00109 |
| 110 | 00110 |

### Task A11

**Requirement:** Show product names that contain `'Pro'` anywhere, along with the position of `'Pro'`.

```sql
SELECT ProdID,
       ProdName,
       LOCATE('Pro', ProdName) AS ProPosition
FROM Product
WHERE ProdName LIKE '%Pro%';
```

**Result** (1 row)

| ProdID | ProdName | ProPosition |
|---|---|---|
| 101 | Laptop Pro 15 | 8 |

**Note:** Only "Laptop Pro 15" contains the substring `'Pro'`; every other product name is filtered out by the `LIKE` clause.

### Task A12

**Requirement:** Show each customer's first name only (the part before the first space in the trimmed name).

```sql
SELECT CustID,
       SUBSTRING(TRIM(CustName), 1, LOCATE(' ', TRIM(CustName)) - 1) AS FirstName
FROM Customer;
```

**Result** (8 rows)

| CustID | FirstName |
|---|---|
| 1 | Ali |
| 2 | Sara |
| 3 | HAMZA |
| 4 | Ayesha |
| 5 | bilal |
| 6 | Fatima |
| 7 | Usman |
| 8 | Maira |

**Note:** `TRIM` must run first (innermost), otherwise `LOCATE(' ', CustName)` on row 1 would find the *leading* space at position 1, producing an empty string.

---

## 4. Summary

| Task | Concept | Rows returned |
|---|---|---|
| A1 | TRIM | 8 |
| A2 | UPPER / LOWER | 8 |
| A3 | TRIM + CHAR_LENGTH (nesting) | 8 |
| A4 | CONCAT + TRIM | 8 |
| A5 | SUBSTRING + LOCATE | 7 |
| A6 | SUBSTRING + LOCATE | 7 |
| A7 | LEFT | 8 |
| A8 | CONCAT + LEFT + WHERE IS NOT NULL | 7 |
| A9 | REPLACE | 10 |
| A10 | LPAD | 10 |
| A11 | LOCATE + LIKE | 1 |
| A12 | SUBSTRING + LOCATE + TRIM (nesting) | 8 |

## 5. Key Takeaways

- `TRIM` only removes **spaces** by default — other characters need `TRIM(BOTH 'x' FROM s)`.
- Function nesting is read **inside-out**: the innermost function's output feeds the next one outward.
- `LOCATE(sub, s)` takes the substring **first**, the string **second** — a common mix-up.
- A function applied to a NULL column (`SUBSTRING(NULL, ...)`) returns NULL, so `WHERE col IS NOT NULL` is needed before extracting parts of an optional column.
- `LEFT`/`RIGHT`/`UPPER`/`LOWER` work on the raw column — if the column has stray spaces, trim first if a clean result is wanted.

## 6. Files

- `RollNo_Lab10_StringFunctions.sql` — database setup and all 12 Part A tasks
