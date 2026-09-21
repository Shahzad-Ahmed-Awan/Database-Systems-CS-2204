-- =====================================================================
--  DATABASE SYSTEMS | LAB 07 : ASSESSMENT (GRADED)
--  Scenario: Online Bookstore
--  Database: bookstore_lab      Table: Book
--  Tool    : MySQL 8.x (Workbench or Command Line Client)
--  Name    : Shahzad Ahmed Awan     Roll No: 2024-SE-15
-- =====================================================================
--  HOW TO RUN
--  Run top to bottom. Steps 1-4 build and verify the Book table.
--  Step 5 contains Q1 to Q10 (100 marks total).
--  Each answer is labelled with a comment and shows the expected result.
-- =====================================================================


-- =====================================================================
-- STEP 1 : CREATE AND SELECT THE DATABASE
-- =====================================================================
CREATE DATABASE IF NOT EXISTS bookstore_lab;
USE bookstore_lab;

SELECT DATABASE() AS current_database;


-- =====================================================================
-- STEP 2 : CREATE THE BOOK TABLE
-- =====================================================================
DROP TABLE IF EXISTS Book;

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

DESCRIBE Book;


-- =====================================================================
-- STEP 3 : INSERT THE DATA (inside a transaction)
-- =====================================================================
START TRANSACTION;

INSERT INTO Book VALUES
(1,  'Pride and Prejudice',            'Jane Austen',     'Fiction',   850, 12, 1813, 'Penguin',      'English'),
(2,  'Emma',                           'Jane Austen',     'Fiction',   900,  8, 1815, 'Penguin',      'English'),
(3,  'Things Fall Apart',              'Chinua Achebe',   'Fiction',  1100,  5, 1958, 'Heinemann',    'English'),
(4,  'Norwegian Wood',                 'Haruki Murakami', 'Fiction',  1500,  3, 1987, 'Vintage',      'English'),
(5,  'Kafka on the Shore',             'Haruki Murakami', 'Fiction',  1700,  0, 2002, 'Vintage',      'English'),
(6,  'Ice-Candy-Man',                  'Bapsi Sidhwa',    'Fiction',  1200, 15, 1988, 'Penguin',      'English'),
(7,  'The Reluctant Fundamentalist',   'Mohsin Hamid',    'Fiction',  1300,  9, 2007, 'Penguin',      'English'),
(8,  'Exit West',                      'Mohsin Hamid',    'Fiction',  1450,  6, 2017, 'Riverhead',    'English'),
(9,  'Atomic Habits',                  'James Clear',     'Self-help',1800, 20, 2018, 'Avery',        'English'),
(10, 'The Power of Habit',             'Charles Duhigg',  'Self-help',1600, 11, 2012, 'Random House', 'English'),
(11, 'Sapiens',                        'Yuval Harari',    'History',  2200,  7, 2011, 'Harper',       'English'),
(12, 'Rich Dad Poor Dad',              'Robert Kiyosaki', 'Finance',  1100, 25, 1997, 'Plata',        'English'),
(13, 'Aab-e-Hayat',                    'Ibn-e-Safi',      'Mystery',   650, 18, 1955, 'Asrar',        'Urdu'),
(14, 'Raja Gidh',                      'Bano Qudsia',     'Fiction',   900, 14, 1981, 'Sang-e-Meel',  'Urdu'),
(15, 'Mystery Title',                  NULL,              'Mystery',   950,  4, 2020, NULL,           'English');
-- Note: Book 15 has an unknown author and unknown publisher (NULL).

SELECT COUNT(*) AS rows_before_commit FROM Book;        -- expect 15

COMMIT;


-- =====================================================================
-- STEP 4 : VERIFY THE DATA
-- =====================================================================
-- 4.1 Row count                                          (expect 15)
SELECT COUNT(*) AS total_books FROM Book;

-- 4.2 View the whole table
SELECT * FROM Book;

-- 4.3 NULL check: Book 15 should be the only row with NULL author/publisher
SELECT BookID, Title, Author, Publisher
FROM Book
WHERE Author IS NULL OR Publisher IS NULL;              -- expect 1 row

-- 4.4 Autocommit status                                  (expect 1)
SELECT @@autocommit AS autocommit_status;


-- =====================================================================
-- STEP 5 : ASSESSMENT QUESTIONS
-- =====================================================================

-- ---------------------------------------------------------------------
-- Q1  (5 marks)
-- List all books with a price greater than 1500. Show Title and Price.
-- Expected: 4 rows
--   Kafka on the Shore 1700, Atomic Habits 1800,
--   The Power of Habit 1600, Sapiens 2200
--   (Norwegian Wood at exactly 1500 is excluded because of strict >)
-- ---------------------------------------------------------------------
SELECT Title, Price
FROM Book
WHERE Price > 1500;


-- ---------------------------------------------------------------------
-- Q2  (10 marks)
-- Books published between 1900 and 2000. Show Title and PublishedYear,
-- sorted by year.
-- Expected: 6 rows
--   Aab-e-Hayat 1955 -> Things Fall Apart 1958 -> Raja Gidh 1981 ->
--   Norwegian Wood 1987 -> Ice-Candy-Man 1988 -> Rich Dad Poor Dad 1997
-- ---------------------------------------------------------------------
SELECT Title, PublishedYear
FROM Book
WHERE PublishedYear BETWEEN 1900 AND 2000
ORDER BY PublishedYear ASC;


-- ---------------------------------------------------------------------
-- Q3  (10 marks)
-- Books in Fiction OR Mystery genre with stock greater than 5.
-- IN (...) groups the two genres, so the stock test applies to both.
-- If written with OR instead, parentheses are essential:
--   WHERE (Genre = 'Fiction' OR Genre = 'Mystery') AND StockQty > 5
-- Without them AND binds tighter than OR, so the stock test would apply
-- only to Mystery and every Fiction book would be returned regardless of stock.
-- Expected: 7 rows
--   Pride and Prejudice, Emma, Ice-Candy-Man,
--   The Reluctant Fundamentalist, Exit West, Aab-e-Hayat, Raja Gidh
-- ---------------------------------------------------------------------
SELECT BookID, Title, Genre, StockQty
FROM Book
WHERE Genre IN ('Fiction', 'Mystery')
  AND StockQty > 5;


-- ---------------------------------------------------------------------
-- Q4  (10 marks)
-- Books whose title contains 'the' anywhere (case-insensitive).
-- Show Title and Author.
-- MySQL's default collation ignores case, so '%the%' also matches 'The'.
-- Expected: 3 rows
--   Kafka on the Shore, The Reluctant Fundamentalist, The Power of Habit
-- ---------------------------------------------------------------------
SELECT Title, Author
FROM Book
WHERE Title LIKE '%the%';


-- ---------------------------------------------------------------------
-- Q5  (10 marks)
-- Books whose title starts with 'A' OR ends with 't'.
-- Expected: 6 rows
--   Starts with A : Atomic Habits, Aab-e-Hayat
--   Ends with t   : Things Fall Apart, The Reluctant Fundamentalist,
--                   Exit West, The Power of Habit
-- ---------------------------------------------------------------------
SELECT BookID, Title
FROM Book
WHERE Title LIKE 'A%'
   OR Title LIKE '%t';


-- ---------------------------------------------------------------------
-- Q6  (5 marks)
-- Books with no recorded author. Show Title.
-- NULL requires IS NULL; Author = NULL would return 0 rows.
-- Expected: 1 row  (Mystery Title)
-- ---------------------------------------------------------------------
SELECT Title
FROM Book
WHERE Author IS NULL;


-- ---------------------------------------------------------------------
-- Q7  (10 marks)
-- Books that are out of stock (StockQty = 0) OR have an unknown publisher.
-- Expected: 2 rows
--   Kafka on the Shore (stock 0), Mystery Title (publisher NULL)
-- ---------------------------------------------------------------------
SELECT BookID, Title, StockQty, Publisher
FROM Book
WHERE StockQty = 0
   OR Publisher IS NULL;


-- ---------------------------------------------------------------------
-- Q8  (15 marks)
-- The 3 most expensive books that are in stock (StockQty > 0).
-- Filter first with WHERE, then sort by price descending, then LIMIT 3.
-- Kafka on the Shore (1700) is excluded because its stock is 0.
-- Expected: Sapiens 2200, Atomic Habits 1800, The Power of Habit 1600
-- ---------------------------------------------------------------------
SELECT Title, Price, StockQty
FROM Book
WHERE StockQty > 0
ORDER BY Price DESC
LIMIT 3;


-- ---------------------------------------------------------------------
-- Q9  (10 marks)
-- All books written in Urdu, sorted by published year ascending.
-- Expected: 2 rows  (Aab-e-Hayat 1955, Raja Gidh 1981)
-- ---------------------------------------------------------------------
SELECT Title, Author, PublishedYear, Language
FROM Book
WHERE Language = 'Urdu'
ORDER BY PublishedYear ASC;


-- ---------------------------------------------------------------------
-- Q10  (15 marks)
-- Books published before 2000 with a price under 1200,
-- sorted by genre and then by title.
-- Expected: 6 rows
--   Fiction : Emma, Pride and Prejudice, Raja Gidh, Things Fall Apart
--   Finance : Rich Dad Poor Dad
--   Mystery : Aab-e-Hayat
--   (Norwegian Wood 1500 and Ice-Candy-Man 1200 fail the price test)
-- ---------------------------------------------------------------------
SELECT Title, Genre, Price, PublishedYear
FROM Book
WHERE PublishedYear < 2000
  AND Price < 1200
ORDER BY Genre ASC, Title ASC;


-- =====================================================================
--  END OF ASSESSMENT
-- =====================================================================
