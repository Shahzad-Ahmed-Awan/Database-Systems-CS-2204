# Lab 07 Assessment: Online Bookstore

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1?logo=mysql&logoColor=white)
![Topic](https://img.shields.io/badge/Topic-Filters%20Assessment-c0392b)
![Questions](https://img.shields.io/badge/Questions-Q1%20to%20Q10-success)
![Marks](https://img.shields.io/badge/Total%20Marks-100-orange)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | Filtering with WHERE, BETWEEN, IN, LIKE, IS NULL, ORDER BY, LIMIT |
| **Database / Table** | `bookstore_lab` / `Book` |
| **Total marks** | 100 |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Answer ten graded filtering queries (Q1 to Q10) on the Book table of an online bookstore.

## 2. Database Setup

### 2.1 Create and select database

```sql
CREATE DATABASE IF NOT EXISTS bookstore_lab;
USE bookstore_lab;
```

Result: database `bookstore_lab` created and selected.

### 2.2 Create table `Book`

```sql
CREATE TABLE Book (
    BookID         INT           PRIMARY KEY,
    Title          VARCHAR(80)   NOT NULL,
    Author         VARCHAR(60),               -- NULL = unknown author
    Genre          VARCHAR(30),
    Price          DECIMAL(8,2),
    StockQty       INT,
    PublishedYear  INT,
    Publisher      VARCHAR(40),               -- NULL = unknown publisher
    Language       VARCHAR(20)
);
```

Table structure (`DESCRIBE Book`):

| Column | Data type | Constraint |
|---|---|---|
| BookID | int | PRIMARY KEY |
| Title | varchar(80) | NOT NULL |
| Author | varchar(60) | — |
| Genre | varchar(30) | — |
| Price | decimal(8,2) | — |
| StockQty | int | — |
| PublishedYear | int | — |
| Publisher | varchar(40) | — |
| Language | varchar(20) | — |

### 2.3 Insert data (transaction)

```sql
START TRANSACTION;
INSERT INTO Book VALUES ( ... 15 rows ... );
COMMIT;
```

Result: 15 rows inserted and committed.

### 2.4 Verification

**Row count**

```sql
SELECT COUNT(*) AS total_books FROM Book;
```

| total_books |
|---|
| 15 |

**NULL author / publisher check**

```sql
SELECT BookID, Title, Author, Publisher FROM Book WHERE Author IS NULL OR Publisher IS NULL;
```

| BookID | Title | Author | Publisher |
|---|---|---|---|
| 15 | Mystery Title | NULL | NULL |

---

## 3. Task Results

### Q1 (5 marks)

**Requirement:** List all books with a price greater than 1500. Show Title and Price.

```sql
SELECT Title, Price
FROM Book
WHERE Price > 1500;
```

**Result** (4 rows)

| Title | Price |
|---|---|
| Kafka on the Shore | 1700.00 |
| Atomic Habits | 1800.00 |
| The Power of Habit | 1600.00 |
| Sapiens | 2200.00 |

**Note:** Norwegian Wood (exactly 1,500) is excluded because of the strict > operator.

### Q2 (10 marks)

**Requirement:** Books published between 1900 and 2000. Show Title and PublishedYear, sorted by year.

```sql
SELECT Title, PublishedYear
FROM Book
WHERE PublishedYear BETWEEN 1900 AND 2000
ORDER BY PublishedYear ASC;
```

**Result** (6 rows)

| Title | PublishedYear |
|---|---|
| Aab-e-Hayat | 1955 |
| Things Fall Apart | 1958 |
| Raja Gidh | 1981 |
| Norwegian Wood | 1987 |
| Ice-Candy-Man | 1988 |
| Rich Dad Poor Dad | 1997 |

### Q3 (10 marks)

**Requirement:** Books in Fiction OR Mystery genre with stock greater than 5.

```sql
SELECT BookID, Title, Genre, StockQty
FROM Book
WHERE Genre IN ('Fiction', 'Mystery')
  AND StockQty > 5;
```

**Result** (7 rows)

| BookID | Title | Genre | StockQty |
|---|---|---|---|
| 1 | Pride and Prejudice | Fiction | 12 |
| 2 | Emma | Fiction | 8 |
| 6 | Ice-Candy-Man | Fiction | 15 |
| 7 | The Reluctant Fundamentalist | Fiction | 9 |
| 8 | Exit West | Fiction | 6 |
| 13 | Aab-e-Hayat | Mystery | 18 |
| 14 | Raja Gidh | Fiction | 14 |

**Note:** IN groups both genres so the stock condition applies to each.

### Q4 (10 marks)

**Requirement:** Books whose title contains 'the' anywhere (case-insensitive). Show Title and Author.

```sql
SELECT Title, Author
FROM Book
WHERE Title LIKE '%the%';
```

**Result** (3 rows)

| Title | Author |
|---|---|
| Kafka on the Shore | Haruki Murakami |
| The Reluctant Fundamentalist | Mohsin Hamid |
| The Power of Habit | Charles Duhigg |

### Q5 (10 marks)

**Requirement:** Books whose title starts with 'A' OR ends with 't'.

```sql
SELECT BookID, Title
FROM Book
WHERE Title LIKE 'A%'
   OR Title LIKE '%t';
```

**Result** (6 rows)

| BookID | Title |
|---|---|
| 3 | Things Fall Apart |
| 7 | The Reluctant Fundamentalist |
| 8 | Exit West |
| 9 | Atomic Habits |
| 10 | The Power of Habit |
| 13 | Aab-e-Hayat |

### Q6 (5 marks)

**Requirement:** Books with no recorded author. Show Title.

```sql
SELECT Title
FROM Book
WHERE Author IS NULL;
```

**Result** (1 row)

| Title |
|---|
| Mystery Title |

**Note:** NULL is tested with IS NULL.

### Q7 (10 marks)

**Requirement:** Books that are out of stock (StockQty = 0) OR have an unknown publisher.

```sql
SELECT BookID, Title, StockQty, Publisher
FROM Book
WHERE StockQty = 0
   OR Publisher IS NULL;
```

**Result** (2 rows)

| BookID | Title | StockQty | Publisher |
|---|---|---|---|
| 5 | Kafka on the Shore | 0 | Vintage |
| 15 | Mystery Title | 4 | NULL |

### Q8 (15 marks)

**Requirement:** The 3 most expensive books that are in stock (StockQty > 0).

```sql
SELECT Title, Price, StockQty
FROM Book
WHERE StockQty > 0
ORDER BY Price DESC
LIMIT 3;
```

**Result** (3 rows)

| Title | Price | StockQty |
|---|---|---|
| Sapiens | 2200.00 | 7 |
| Atomic Habits | 1800.00 | 20 |
| The Power of Habit | 1600.00 | 11 |

**Note:** Kafka on the Shore (1,700) is excluded because its stock is 0.

### Q9 (10 marks)

**Requirement:** All books written in Urdu, sorted by published year ascending.

```sql
SELECT Title, Author, PublishedYear, Language
FROM Book
WHERE Language = 'Urdu'
ORDER BY PublishedYear ASC;
```

**Result** (2 rows)

| Title | Author | PublishedYear | Language |
|---|---|---|---|
| Aab-e-Hayat | Ibn-e-Safi | 1955 | Urdu |
| Raja Gidh | Bano Qudsia | 1981 | Urdu |

### Q10 (15 marks)

**Requirement:** Books published before 2000 with a price under 1200, sorted by genre and then by title.

```sql
SELECT Title, Genre, Price, PublishedYear
FROM Book
WHERE PublishedYear < 2000
  AND Price < 1200
ORDER BY Genre ASC, Title ASC;
```

**Result** (6 rows)

| Title | Genre | Price | PublishedYear |
|---|---|---|---|
| Emma | Fiction | 900.00 | 1815 |
| Pride and Prejudice | Fiction | 850.00 | 1813 |
| Raja Gidh | Fiction | 900.00 | 1981 |
| Things Fall Apart | Fiction | 1100.00 | 1958 |
| Rich Dad Poor Dad | Finance | 1100.00 | 1997 |
| Aab-e-Hayat | Mystery | 650.00 | 1955 |

---

## 4. Summary

| Question | Concept | Rows | Marks |
|---|---|---|---|
| Q1 | Comparison (>) | 4 | 5 |
| Q2 | BETWEEN + ORDER BY | 6 | 10 |
| Q3 | IN + AND | 7 | 10 |
| Q4 | LIKE (contains) | 3 | 10 |
| Q5 | LIKE + OR | 6 | 10 |
| Q6 | IS NULL | 1 | 5 |
| Q7 | OR + IS NULL | 2 | 10 |
| Q8 | WHERE + ORDER BY + LIMIT | 3 | 15 |
| Q9 | Equality + ORDER BY | 2 | 10 |
| Q10 | AND + multi-column ORDER BY | 6 | 15 |
| **Total** | | | **100** |

## 5. Files

- `Lab07_Assessment_Bookstore.sql` — database setup and Q1 to Q10
