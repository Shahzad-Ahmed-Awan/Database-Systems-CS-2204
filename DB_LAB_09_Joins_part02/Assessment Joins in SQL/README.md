# Joins Assessment: Library Database

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1)
![Topic](https://img.shields.io/badge/Topic-JOINS-0aa)
![Questions](https://img.shields.io/badge/Questions-Q1%20to%20Q10-success)
![Marks](https://img.shields.io/badge/Total%20Marks-100-orange)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | INNER JOIN, LEFT JOIN, RIGHT JOIN, multi-table joins, FULL OUTER via UNION |
| **Database** | `library_lab` |
| **Tables** | `Author`, `Book`, `Member`, `Loan` |
| **Total marks** | 100 |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Answer ten graded join queries (Q1 to Q10) on a small library database of authors, books, members and loans.

## 2. Database Setup

### 2.1 Create and select database

```sql
CREATE DATABASE IF NOT EXISTS library_lab;
USE library_lab;

DROP TABLE IF EXISTS Loan, Book, Member, Author;
```

Result: database `library_lab` created and selected.

### 2.2 Create the four tables

```sql
CREATE TABLE Author (
    AuthorID   INT PRIMARY KEY,
    AuthorName VARCHAR(60) NOT NULL,
    Country    VARCHAR(30)
);

CREATE TABLE Book (
    BookID        INT PRIMARY KEY,
    Title         VARCHAR(80) NOT NULL,
    Genre         VARCHAR(30),
    Price         DECIMAL(8,2),
    AuthorID      INT,                       -- NULL = unknown author
    PublishedYear INT,
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
);

CREATE TABLE Member (
    MemberID   INT PRIMARY KEY,
    MemberName VARCHAR(60) NOT NULL,
    City       VARCHAR(30),
    JoinDate   DATE
);

CREATE TABLE Loan (
    LoanID     INT PRIMARY KEY,
    MemberID   INT,
    BookID     INT,
    LoanDate   DATE,
    ReturnDate DATE,                         -- NULL = not yet returned
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (BookID)   REFERENCES Book(BookID)
);
```

**Schema summary**

| Table | Key columns | Links to |
|---|---|---|
| Author | `AuthorID` (PK) | — |
| Book | `BookID` (PK) | `AuthorID` → Author |
| Member | `MemberID` (PK) | — |
| Loan | `LoanID` (PK) | `MemberID` → Member, `BookID` → Book |

```
Author 1 ── * Book 1 ── * Loan * ── 1 Member
```

### 2.3 Insert data

```sql
INSERT INTO Author VALUES ( ... 6 rows ... );
INSERT INTO Book   VALUES ( ... 9 rows ... );
INSERT INTO Member VALUES ( ... 5 rows ... );
INSERT INTO Loan   VALUES ( ... 7 rows ... );
```

Result: 6 + 9 + 5 + 7 rows inserted.

### 2.4 Verification

**Row counts**

| Table | Rows |
|---|---|
| Author | 6 |
| Book | 9 |
| Member | 5 |
| Loan | 7 |

**Deliberate gaps in the data**

```sql
SELECT BookID, Title FROM Book WHERE AuthorID IS NULL;
SELECT MemberID, MemberName FROM Member WHERE City IS NULL;
SELECT LoanID FROM Loan WHERE ReturnDate IS NULL;
```

| Gap | Row(s) |
|---|---|
| Author with no books | 6 — Anonymous Writer (Country also NULL) |
| Book with no author | 109 — Mystery Title (`AuthorID` NULL) |
| Book never borrowed | 106 — Ice-Candy-Man, 109 — Mystery Title |
| Member with no loans | 205 — Hira Yousaf (City also NULL) |
| Loans not yet returned | 2, 4, 7 (`ReturnDate` NULL) |

---

## 3. Task Results

### Q1 (10 marks)

**Requirement:** Show every book with its author's name and country. (INNER JOIN)

```sql
SELECT b.Title, a.AuthorName, a.Country
FROM Book b
INNER JOIN Author a ON b.AuthorID = a.AuthorID;
```

**Result** (8 rows)

| Title | AuthorName | Country |
|---|---|---|
| Pride and Prejudice | Jane Austen | UK |
| Emma | Jane Austen | UK |
| Things Fall Apart | Chinua Achebe | Nigeria |
| Norwegian Wood | Haruki Murakami | Japan |
| Kafka on the Shore | Haruki Murakami | Japan |
| Ice-Candy-Man | Bapsi Sidhwa | Pakistan |
| The Reluctant Fundamentalist | Mohsin Hamid | Pakistan |
| Exit West | Mohsin Hamid | Pakistan |

**Note:** 9 books in, 8 rows out. `Mystery Title` has a NULL `AuthorID`, and NULL never matches in an INNER JOIN.

### Q2 (10 marks)

**Requirement:** Show every author with their books. Authors with no books must still appear once with NULL Title. (LEFT JOIN)

```sql
SELECT a.AuthorName, b.Title
FROM Author a
LEFT JOIN Book b ON a.AuthorID = b.AuthorID
ORDER BY a.AuthorName;
```

**Result** (9 rows)

| AuthorName | Title |
|---|---|
| Anonymous Writer | NULL |
| Bapsi Sidhwa | Ice-Candy-Man |
| Chinua Achebe | Things Fall Apart |
| Haruki Murakami | Norwegian Wood |
| Haruki Murakami | Kafka on the Shore |
| Jane Austen | Pride and Prejudice |
| Jane Austen | Emma |
| Mohsin Hamid | The Reluctant Fundamentalist |
| Mohsin Hamid | Exit West |

**Note:** Authors with several books repeat once per book. `Mystery Title` is still missing — `Author` is the preserved side here, not `Book`.

### Q3 (10 marks)

**Requirement:** List members who have never borrowed any book. (LEFT JOIN + IS NULL)

```sql
SELECT m.MemberID, m.MemberName
FROM Member m
LEFT JOIN Loan l ON m.MemberID = l.MemberID
WHERE l.MemberID IS NULL;
```

**Result** (1 row)

| MemberID | MemberName |
|---|---|
| 205 | Hira Yousaf |

**Note:** The anti-join pattern. `WHERE l.MemberID IS NULL` keeps only the rows the LEFT JOIN could not match.

### Q4 (15 marks)

**Requirement:** List every loan with the member's name, book title, and author's name.

```sql
SELECT l.LoanID, m.MemberName, b.Title, a.AuthorName
FROM Loan l
INNER JOIN Member m ON l.MemberID = m.MemberID
INNER JOIN Book b   ON l.BookID   = b.BookID
LEFT JOIN Author a  ON b.AuthorID = a.AuthorID;
```

**Result** (7 rows)

| LoanID | MemberName | Title | AuthorName |
|---|---|---|---|
| 1 | Ahmad Raza | Pride and Prejudice | Jane Austen |
| 2 | Ahmad Raza | Norwegian Wood | Haruki Murakami |
| 3 | Sara Imran | Things Fall Apart | Chinua Achebe |
| 4 | Sara Imran | The Reluctant Fundamentalist | Mohsin Hamid |
| 5 | Bilal Khan | Kafka on the Shore | Haruki Murakami |
| 6 | Fatima Ali | Emma | Jane Austen |
| 7 | Fatima Ali | Exit West | Mohsin Hamid |

**Note:** `Author` is joined with LEFT JOIN on purpose. Every loan must survive even if the borrowed book had an unknown author; an INNER JOIN there would quietly hide such a loan.

### Q5 (10 marks)

**Requirement:** List currently borrowed books (`ReturnDate IS NULL`) along with the borrower's name and city.

```sql
SELECT b.Title, m.MemberName, m.City
FROM Loan l
INNER JOIN Book b   ON l.BookID   = b.BookID
INNER JOIN Member m ON l.MemberID = m.MemberID
WHERE l.ReturnDate IS NULL;
```

**Result** (3 rows)

| Title | MemberName | City |
|---|---|---|
| Norwegian Wood | Ahmad Raza | Lahore |
| The Reluctant Fundamentalist | Sara Imran | Karachi |
| Exit West | Fatima Ali | Islamabad |

**Note:** NULL means "still out on loan" and must be tested with `IS NULL`; `ReturnDate = NULL` returns nothing.

### Q6 (15 marks)

**Requirement:** List Pakistani authors and the titles of their books. Include Pakistani authors with no books.

```sql
SELECT a.AuthorName, b.Title
FROM Author a
LEFT JOIN Book b ON a.AuthorID = b.AuthorID
WHERE a.Country = 'Pakistan';
```

**Result** (3 rows)

| AuthorName | Title |
|---|---|
| Bapsi Sidhwa | Ice-Candy-Man |
| Mohsin Hamid | The Reluctant Fundamentalist |
| Mohsin Hamid | Exit West |

**Note:** The filter is on `Author`, the preserved (left) table, so `WHERE` is safe. Had the filter been on a `Book` column, it would have to move into the `ON` clause to avoid cancelling the LEFT JOIN. Both Pakistani authors happen to have books; `Anonymous Writer` has none but is excluded by the country filter, since NULL country is not `'Pakistan'`.

### Q7 (10 marks)

**Requirement:** List every book together with the names of all members who have borrowed it. Include books that have never been borrowed.

```sql
SELECT b.Title, m.MemberName
FROM Book b
LEFT JOIN Loan l   ON b.BookID   = l.BookID
LEFT JOIN Member m ON l.MemberID = m.MemberID
ORDER BY b.Title;
```

**Result** (9 rows)

| Title | MemberName |
|---|---|
| Emma | Fatima Ali |
| Exit West | Fatima Ali |
| Ice-Candy-Man | NULL |
| Kafka on the Shore | Bilal Khan |
| Mystery Title | NULL |
| Norwegian Wood | Ahmad Raza |
| Pride and Prejudice | Ahmad Raza |
| The Reluctant Fundamentalist | Sara Imran |
| Things Fall Apart | Sara Imran |

**Note:** 7 loans + 2 never-borrowed books = 9 rows. Both joins in the chain are LEFT joins so the unborrowed books keep their place.

### Q8 (10 marks)

**Requirement:** Find authors whose books have never been borrowed. (Author → Book → Loan)

```sql
SELECT DISTINCT a.AuthorName
FROM Author a
INNER JOIN Book b ON a.AuthorID = b.AuthorID
LEFT JOIN Loan l  ON b.BookID   = l.BookID
WHERE l.LoanID IS NULL;
```

**Result** (1 row)

| AuthorName |
|---|
| Bapsi Sidhwa |

**Note:** The INNER JOIN to `Book` keeps only authors who actually have books, so `Anonymous Writer` is excluded. Strictly, this query returns authors who have *at least one* unborrowed book; here Bapsi Sidhwa has only one book, so the two readings agree. `DISTINCT` prevents duplicates when an author has several unborrowed titles.

### Q9 (5 marks)

**Requirement:** Produce a FULL OUTER JOIN of Author and Book using UNION — every author and every book, matched where possible.

```sql
SELECT a.AuthorName, b.Title
FROM Author a
LEFT JOIN Book b ON a.AuthorID = b.AuthorID
UNION
SELECT a.AuthorName, b.Title
FROM Author a
RIGHT JOIN Book b ON a.AuthorID = b.AuthorID;
```

**Result** (10 rows)

| AuthorName | Title |
|---|---|
| Jane Austen | Pride and Prejudice |
| Jane Austen | Emma |
| Chinua Achebe | Things Fall Apart |
| Haruki Murakami | Norwegian Wood |
| Haruki Murakami | Kafka on the Shore |
| Bapsi Sidhwa | Ice-Candy-Man |
| Mohsin Hamid | The Reluctant Fundamentalist |
| Mohsin Hamid | Exit West |
| Anonymous Writer | NULL |
| NULL | Mystery Title |

**Note:** 8 matched pairs + the author with no book + the book with no author = 10 rows. MySQL has no `FULL OUTER JOIN`, and plain `UNION` removes the 8 duplicates the two halves share. Row order is not guaranteed without `ORDER BY`.

### Q10 (5 marks)

**Requirement:** List members who have borrowed books written by Pakistani authors. Show member name, book title, and author name.

```sql
SELECT m.MemberName, b.Title, a.AuthorName
FROM Loan l
INNER JOIN Member m ON l.MemberID = m.MemberID
INNER JOIN Book b   ON l.BookID   = b.BookID
INNER JOIN Author a ON b.AuthorID = a.AuthorID
WHERE a.Country = 'Pakistan';
```

**Result** (2 rows)

| MemberName | Title | AuthorName |
|---|---|---|
| Sara Imran | The Reluctant Fundamentalist | Mohsin Hamid |
| Fatima Ali | Exit West | Mohsin Hamid |

**Note:** `Ice-Candy-Man` by Bapsi Sidhwa is also by a Pakistani author but has never been borrowed, so no loan row exists to join. All four tables are chained with INNER JOINs, which is correct here — only actual loans of matching books should appear.

---

## 4. Summary

| Question | Concept | Rows | Marks |
|---|---|---|---|
| Q1 | INNER JOIN | 8 | 10 |
| Q2 | LEFT JOIN | 9 | 10 |
| Q3 | LEFT JOIN + IS NULL | 1 | 10 |
| Q4 | 3-table join + LEFT JOIN to Author | 7 | 15 |
| Q5 | Multi-table join + IS NULL filter | 3 | 10 |
| Q6 | LEFT JOIN + WHERE on left table | 3 | 15 |
| Q7 | LEFT JOIN chain | 9 | 10 |
| Q8 | INNER + LEFT JOIN + IS NULL | 1 | 10 |
| Q9 | FULL OUTER JOIN via UNION | 10 | 5 |
| Q10 | 4-table join + filter | 2 | 5 |
| **Total** | | | **100** |

## 5. Key Takeaways

- A NULL foreign key (`Book.AuthorID`) never matches in an INNER JOIN — the row disappears.
- Which table you preserve decides the answer: Q1 loses the authorless book, Q2 loses it too, and only Q9 shows every row from both sides.
- Filters on the preserved table are safe in `WHERE`; filters on the optional table belong in `ON`.
- `LEFT JOIN ... WHERE key IS NULL` answers every "which rows have no match?" question (Q3, Q8).
- Use `DISTINCT` when a join can return the same entity more than once.

## 6. Files

- `Assessment_Joins.sql` — setup script and Q1 to Q10
