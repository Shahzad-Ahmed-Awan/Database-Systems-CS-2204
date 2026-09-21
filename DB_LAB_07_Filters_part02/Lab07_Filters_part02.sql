-- =====================================================================
--  DATABASE SYSTEMS | LAB 07 : SQL FILTERS (Part 2)
--  Topic   : BETWEEN, IN, LIKE, IS NULL, ORDER BY, LIMIT
--  Database: filters_lab      Table: Employee
--  Tool    : MySQL 8.x (Workbench or Command Line Client)
--  Name    : Shahzad Ahmed Awan     Roll No: 2024-SE-15
-- =====================================================================
--  HOW TO RUN
--  This file is standalone: it rebuilds the Employee table from scratch
--  (Steps 1-4), so it can be run even in a fresh MySQL session.
--  Step 5 contains the 15 lab tasks with expected row counts.
--  NOTE: Running this file resets Employee to its original 15 rows.
-- =====================================================================


-- =====================================================================
-- STEP 1 : CREATE AND SELECT THE DATABASE
-- =====================================================================
CREATE DATABASE IF NOT EXISTS filters_lab;
USE filters_lab;

SELECT DATABASE() AS current_database;


-- =====================================================================
-- STEP 2 : CREATE THE EMPLOYEE TABLE
-- =====================================================================
DROP TABLE IF EXISTS Employee;

CREATE TABLE Employee (
    EmpID     INT           PRIMARY KEY,
    EmpName   VARCHAR(50)   NOT NULL,
    Gender    CHAR(1),
    Salary    DECIMAL(10,2),
    HireDate  DATE,
    City      VARCHAR(30),
    JobTitle  VARCHAR(40),
    DeptName  VARCHAR(40)
);

DESCRIBE Employee;


-- =====================================================================
-- STEP 3 : INSERT THE DATA (inside a transaction)
-- =====================================================================
START TRANSACTION;

INSERT INTO Employee VALUES
(101, 'Ali Khan',       'M', 120000, '2018-03-15', 'Lahore',    'Senior Engineer',   'Engineering'),
(102, 'Sara Iqbal',     'F',  95000, '2019-06-01', 'Lahore',    'Software Engineer', 'Engineering'),
(103, 'Hamza Raza',     'M',  85000, '2020-01-20', 'Karachi',   'Software Engineer', 'Engineering'),
(104, 'Ayesha Noor',    'F', 110000, '2017-11-10', 'Karachi',   'Marketing Lead',    'Marketing'),
(105, 'Bilal Ahmed',    'M',  70000, '2021-04-05', 'Karachi',   'Marketing Exec',    'Marketing'),
(106, 'Fatima Sheikh',  'F',  90000, '2019-09-12', 'Islamabad', 'Accountant',        'Finance'),
(107, 'Usman Tariq',    'M',  78000, '2022-02-18', 'Islamabad', 'Accountant',        'Finance'),
(108, 'Maira Javed',    'F', 115000, '2016-07-22', 'Lahore',    'Research Lead',     'Research'),
(109, 'Zain Abbas',     'M',  60000, '2023-01-09', 'Lahore',    'Research Analyst',  'Research'),
(110, 'Nida Yousaf',    'F',  72000, '2022-08-30', NULL,        'Research Analyst',  'Research'),
(111, 'Adeel Akhtar',   'M',  88000, '2020-05-14', 'Lahore',    'QA Engineer',       'Engineering'),
(112, 'Sana Malik',     'F', 102000, '2018-12-01', 'Karachi',   'Sales Manager',     'Sales'),
(113, 'Talha Hussain',  'M',  65000, '2023-07-18', 'Islamabad', 'Sales Exec',        'Sales'),
(114, 'Mehwish Anwar',  'F',  80000, '2021-10-25', 'Lahore',    'HR Officer',        'HR'),
(115, 'Imran Shafi',    'M', 125000, '2015-04-30', NULL,        'Director',          'Engineering');

SELECT COUNT(*) AS rows_before_commit FROM Employee;   -- expect 15

COMMIT;


-- =====================================================================
-- STEP 4 : VERIFY THE DATA
-- =====================================================================
SELECT COUNT(*) AS total_employees FROM Employee;       -- expect 15
SELECT * FROM Employee;
SELECT @@autocommit AS autocommit_status;               -- expect 1


-- =====================================================================
-- STEP 5 : LAB TASKS
-- =====================================================================

-- ---------------------------------------------------------------------
-- Task 1
-- Salary between 75,000 and 100,000 (inclusive), sorted by salary ascending.
-- BETWEEN includes both end values.
-- Expected: 6 rows
--   Usman 78000, Mehwish 80000, Hamza 85000, Adeel 88000,
--   Fatima 90000, Sara 95000
-- ---------------------------------------------------------------------
SELECT EmpName, Salary
FROM Employee
WHERE Salary BETWEEN 75000 AND 100000
ORDER BY Salary ASC;


-- ---------------------------------------------------------------------
-- Task 2
-- Employees hired between January 2020 and December 2022.
-- Dates are written as 'YYYY-MM-DD'. BETWEEN is inclusive on both ends.
-- Expected: 6 rows  (Hamza, Bilal, Usman, Nida, Adeel, Mehwish)
-- ---------------------------------------------------------------------
SELECT EmpName, HireDate
FROM Employee
WHERE HireDate BETWEEN '2020-01-01' AND '2022-12-31'
ORDER BY HireDate;


-- ---------------------------------------------------------------------
-- Task 3
-- Salary NOT between 80,000 and 100,000.
-- Employees at exactly 80,000 or 100,000 are inside the range, so they
-- are excluded here (Mehwish at 80,000 is excluded).
-- Expected: 10 rows
-- ---------------------------------------------------------------------
SELECT EmpName, Salary
FROM Employee
WHERE Salary NOT BETWEEN 80000 AND 100000;


-- ---------------------------------------------------------------------
-- Task 4
-- Employees whose city is Lahore or Islamabad.
-- Sort by city, then by salary highest first within each city.
-- Expected: 9 rows  (3 Islamabad first, then 6 Lahore)
-- ---------------------------------------------------------------------
SELECT EmpName, City, Salary
FROM Employee
WHERE City IN ('Lahore', 'Islamabad')
ORDER BY City ASC, Salary DESC;


-- ---------------------------------------------------------------------
-- Task 5
-- Employees in any department EXCEPT Engineering, Sales and HR.
-- NOT IN excludes every value in the list.
-- Expected: 7 rows  (Marketing 2, Finance 2, Research 3)
-- ---------------------------------------------------------------------
SELECT EmpName, DeptName
FROM Employee
WHERE DeptName NOT IN ('Engineering', 'Sales', 'HR');


-- ---------------------------------------------------------------------
-- Task 6
-- Names starting with the letter 'M'.
-- Pattern 'M%' = 'M' followed by any characters.
-- Expected: 2 rows  (Maira Javed, Mehwish Anwar)
-- ---------------------------------------------------------------------
SELECT EmpName
FROM Employee
WHERE EmpName LIKE 'M%';


-- ---------------------------------------------------------------------
-- Task 7
-- Names containing the letter 'a' anywhere (case-insensitive).
-- MySQL's default collation is case-insensitive, so '%a%' matches both
-- 'a' and 'A' (e.g. the 'A' in "Ali Khan").
-- Expected: 15 rows (every name in this data contains an 'a')
-- ---------------------------------------------------------------------
SELECT EmpName
FROM Employee
WHERE EmpName LIKE '%a%';


-- ---------------------------------------------------------------------
-- Task 8
-- Names ending with 'an'.
-- Pattern '%an' = anything followed by 'an'.
-- Expected: 1 row  (Ali Khan)
-- ---------------------------------------------------------------------
SELECT EmpName
FROM Employee
WHERE EmpName LIKE '%an';


-- ---------------------------------------------------------------------
-- Task 9
-- Job title contains 'Engineer' but the employee is NOT in Engineering.
-- Expected: 0 rows with this data. Every job title containing 'Engineer'
-- (Senior Engineer, Software Engineer, QA Engineer) belongs to the
-- Engineering department. The query is still correct; an empty result
-- is a valid answer.
-- ---------------------------------------------------------------------
SELECT EmpName, JobTitle, DeptName
FROM Employee
WHERE JobTitle LIKE '%Engineer%'
  AND DeptName != 'Engineering';

-- Sanity check (optional): shows the 4 Engineering-titled rows so you can
-- see WHY the query above returns nothing. Expect 4 rows, all 'Engineering'.
SELECT EmpName, JobTitle, DeptName
FROM Employee
WHERE JobTitle LIKE '%Engineer%';


-- ---------------------------------------------------------------------
-- Task 10
-- Names of employees who do not have a recorded city.
-- NULL must be tested with IS NULL (City = NULL never matches).
-- Expected: 2 rows  (Nida Yousaf, Imran Shafi)
-- ---------------------------------------------------------------------
SELECT EmpName
FROM Employee
WHERE City IS NULL;


-- ---------------------------------------------------------------------
-- Task 11
-- Employees with a recorded city, sorted alphabetically by city.
-- Expected: 13 rows  (Islamabad 3, Karachi 4, Lahore 6)
-- ---------------------------------------------------------------------
SELECT EmpName, City
FROM Employee
WHERE City IS NOT NULL
ORDER BY City ASC;


-- ---------------------------------------------------------------------
-- Task 12
-- The 3 highest paid employees.
-- ORDER BY ... DESC puts the highest first; LIMIT 3 keeps the top three.
-- Expected: Imran 125000, Ali 120000, Maira 115000
-- ---------------------------------------------------------------------
SELECT EmpName, Salary
FROM Employee
ORDER BY Salary DESC
LIMIT 3;


-- ---------------------------------------------------------------------
-- Task 13
-- The 5 most recently hired employees.
-- Expected: Talha (2023-07-18), Zain (2023-01-09), Nida (2022-08-30),
--           Usman (2022-02-18), Mehwish (2021-10-25)
-- ---------------------------------------------------------------------
SELECT EmpName, HireDate
FROM Employee
ORDER BY HireDate DESC
LIMIT 5;


-- ---------------------------------------------------------------------
-- Task 14
-- Bottom 3 salaries in the company, lowest first.
-- Expected: Zain 60000, Talha 65000, Bilal 70000
-- ---------------------------------------------------------------------
SELECT EmpName, Salary
FROM Employee
ORDER BY Salary ASC
LIMIT 3;


-- ---------------------------------------------------------------------
-- Task 15
-- All employees sorted by department ascending, then hire date ascending
-- within each department.
-- Expected: 15 rows, grouped Engineering, Finance, HR, Marketing,
--           Research, Sales.
-- ---------------------------------------------------------------------
SELECT EmpName, DeptName, HireDate
FROM Employee
ORDER BY DeptName ASC, HireDate ASC;


-- =====================================================================
--  END OF LAB 07
-- =====================================================================
