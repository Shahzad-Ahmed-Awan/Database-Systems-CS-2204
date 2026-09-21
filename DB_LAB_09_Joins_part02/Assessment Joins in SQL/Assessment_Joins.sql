-- ============================================================
-- DATABASE SYSTEMS | ASSESSMENT PROBLEM (Graded)
-- Scenario: Library Database
-- Compatible with MySQL 8.x
-- Name: Shahzad Ahmed Awan    Roll No: 2024-SE-15
-- Submitted to: Sir Awais Rathore
-- ============================================================

-- ------------------------------------------------------------
-- 0. SETUP SCRIPT (run once before attempting the questions)
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS library_lab;
USE library_lab;

DROP TABLE IF EXISTS Loan, Book, Member, Author;

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
    AuthorID      INT,
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
    ReturnDate DATE, -- NULL = not yet returned
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (BookID) REFERENCES Book(BookID)
);

INSERT INTO Author VALUES
(1,'Jane Austen',      'UK'),
(2,'Chinua Achebe',    'Nigeria'),
(3,'Haruki Murakami',  'Japan'),
(4,'Bapsi Sidhwa',     'Pakistan'),
(5,'Mohsin Hamid',     'Pakistan'),
(6,'Anonymous Writer', NULL); -- no books

INSERT INTO Book VALUES
(101,'Pride and Prejudice',        'Fiction', 850.00, 1, 1813),
(102,'Emma',                       'Fiction', 900.00, 1, 1815),
(103,'Things Fall Apart',          'Fiction', 1100.00, 2, 1958),
(104,'Norwegian Wood',             'Fiction', 1500.00, 3, 1987),
(105,'Kafka on the Shore',         'Fiction', 1700.00, 3, 2002),
(106,'Ice-Candy-Man',              'Fiction', 1200.00, 4, 1988),
(107,'The Reluctant Fundamentalist','Fiction',1300.00, 5, 2007),
(108,'Exit West',                  'Fiction', 1450.00, 5, 2017),
(109,'Mystery Title',              'Mystery', 950.00, NULL, 2020); -- no author

INSERT INTO Member VALUES
(201,'Ahmad Raza', 'Lahore',    '2023-01-15'),
(202,'Sara Imran', 'Karachi',   '2023-03-20'),
(203,'Bilal Khan', 'Lahore',    '2024-02-10'),
(204,'Fatima Ali', 'Islamabad', '2022-09-05'),
(205,'Hira Yousaf', NULL,       '2024-05-01'); -- no loans yet

INSERT INTO Loan VALUES
(1, 201, 101, '2024-03-01', '2024-03-15'),
(2, 201, 104, '2024-04-10', NULL),
(3, 202, 103, '2024-02-20', '2024-03-05'),
(4, 202, 107, '2024-05-01', NULL),
(5, 203, 105, '2024-04-25', '2024-05-15'),
(6, 204, 102, '2024-01-10', '2024-01-30'),
(7, 204, 108, '2024-06-01', NULL);


-- ============================================================
-- ASSESSMENT QUESTIONS
-- ============================================================

-- Q1 (10 marks): Show every book with its author's name and country. (INNER JOIN)
SELECT b.Title, a.AuthorName, a.Country
FROM Book b
INNER JOIN Author a ON b.AuthorID = a.AuthorID;

-- Q2 (10 marks): Show every author with their books.
-- Authors with no books must still appear once with NULL Title. (LEFT JOIN)
SELECT a.AuthorName, b.Title
FROM Author a
LEFT JOIN Book b ON a.AuthorID = b.AuthorID
ORDER BY a.AuthorName;

-- Q3 (10 marks): List members who have never borrowed any book. (LEFT JOIN + IS NULL)
SELECT m.MemberID, m.MemberName
FROM Member m
LEFT JOIN Loan l ON m.MemberID = l.MemberID
WHERE l.MemberID IS NULL;

-- Q4 (15 marks): List every loan with the member's name, book title, and
-- author's name. (3-table join, plus Author)
SELECT l.LoanID, m.MemberName, b.Title, a.AuthorName
FROM Loan l
INNER JOIN Member m ON l.MemberID = m.MemberID
INNER JOIN Book b   ON l.BookID = b.BookID
LEFT JOIN Author a  ON b.AuthorID = a.AuthorID;

-- Q5 (10 marks): List currently borrowed books (ReturnDate IS NULL) along
-- with the borrower's name and city.
SELECT b.Title, m.MemberName, m.City
FROM Loan l
INNER JOIN Book b   ON l.BookID = b.BookID
INNER JOIN Member m ON l.MemberID = m.MemberID
WHERE l.ReturnDate IS NULL;

-- Q6 (15 marks): List Pakistani authors and the titles of their books.
-- Include Pakistani authors with no books. (LEFT JOIN + WHERE on author country)
-- The filter is on Author (the LEFT/preserved table), so it is safe in WHERE.
SELECT a.AuthorName, b.Title
FROM Author a
LEFT JOIN Book b ON a.AuthorID = b.AuthorID
WHERE a.Country = 'Pakistan';

-- Q7 (10 marks): List every book together with the names of all members who
-- have borrowed it. Include books that have never been borrowed. (LEFT JOIN chain)
SELECT b.Title, m.MemberName
FROM Book b
LEFT JOIN Loan l   ON b.BookID = l.BookID
LEFT JOIN Member m ON l.MemberID = m.MemberID
ORDER BY b.Title;

-- Q8 (10 marks): Find authors whose books have never been borrowed.
-- (Multi-step: Author -> Book -> Loan)
SELECT DISTINCT a.AuthorName
FROM Author a
INNER JOIN Book b ON a.AuthorID = b.AuthorID
LEFT JOIN Loan l  ON b.BookID = l.BookID
WHERE l.LoanID IS NULL;

-- Q9 (5 marks): Produce a FULL OUTER JOIN of Author and Book using UNION —
-- every author and every book, matched where possible.
SELECT a.AuthorName, b.Title
FROM Author a
LEFT JOIN Book b ON a.AuthorID = b.AuthorID
UNION
SELECT a.AuthorName, b.Title
FROM Author a
RIGHT JOIN Book b ON a.AuthorID = b.AuthorID;

-- Q10 (5 marks): List members who have borrowed books written by Pakistani
-- authors. Show member name, book title, and author name. (4-way join with filter)
SELECT m.MemberName, b.Title, a.AuthorName
FROM Loan l
INNER JOIN Member m ON l.MemberID = m.MemberID
INNER JOIN Book b   ON l.BookID = b.BookID
INNER JOIN Author a ON b.AuthorID = a.AuthorID
WHERE a.Country = 'Pakistan';

-- End of Assessment Problem
