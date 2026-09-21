-- =====================================================================
--  DATABASE SYSTEMS | LAB 06 : SQL FILTERS (Part 1)
--  Topic   : WHERE clause, comparison operators, AND / OR / NOT
--  Database: filters_lab      Table: Employee
--  Tool    : MySQL 8.x (Workbench or Command Line Client)
--  Name    : Shahzad Ahmed Awan     Roll No: 2024-SE-15
-- =====================================================================
--  HOW TO RUN
--  Run the file top to bottom (Ctrl+Shift+Enter in Workbench).
--  Steps 1-5 build the database. Step 6 contains the 8 lab tasks.
--  Every task shows the expected row count so you can verify quickly.
-- =====================================================================


-- =====================================================================
-- STEP 1 : CREATE AND SELECT THE DATABASE
-- =====================================================================
CREATE DATABASE IF NOT EXISTS filters_lab;
USE filters_lab;

-- Confirm which database is active
SELECT DATABASE() AS current_database;


-- =====================================================================
-- STEP 2 : CREATE THE EMPLOYEE TABLE
-- =====================================================================
-- DROP first so the script can be re-run safely from scratch.
DROP TABLE IF EXISTS Employee;

CREATE TABLE Employee (
    EmpID     INT           PRIMARY KEY,   -- unique employee identifier
    EmpName   VARCHAR(50)   NOT NULL,      -- full name
    Gender    CHAR(1),                     -- 'M' or 'F'
    Salary    DECIMAL(10,2),               -- monthly salary in PKR
    HireDate  DATE,                        -- date the employee joined
    City      VARCHAR(30),                 -- home city (may be NULL)
    JobTitle  VARCHAR(40),                 -- designation
    DeptName  VARCHAR(40)                  -- department (denormalized)
);

-- Check the structure of the table we just created
DESCRIBE Employee;


-- =====================================================================
-- STEP 3 : INSERT THE DATA (inside a transaction)
-- =====================================================================
-- DDL statements (CREATE / DROP) commit automatically in MySQL, but
-- INSERTs do not when a transaction is open. We group all 15 inserts
-- into one transaction so that they are saved together with COMMIT.
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

-- Look at the data BEFORE committing (visible only in this session)
SELECT COUNT(*) AS rows_before_commit FROM Employee;   -- expect 15

-- Make the inserts permanent
COMMIT;


-- =====================================================================
-- STEP 4 : VERIFY THE DATA LOADED CORRECTLY
-- =====================================================================
-- 4.1 Row count                                   (expect 15)
SELECT COUNT(*) AS total_employees FROM Employee;

-- 4.2 View the whole table
SELECT * FROM Employee;

-- 4.3 Quick data profile: salary range and hire-date range
--     (expect 60000 / 125000  and  2015-04-30 / 2023-07-18)
SELECT MIN(Salary)   AS min_salary,
       MAX(Salary)   AS max_salary,
       MIN(HireDate) AS earliest_hire,
       MAX(HireDate) AS latest_hire
FROM Employee;

-- 4.4 Confirm the two NULL cities used later for IS NULL practice
--     (expect Nida Yousaf and Imran Shafi)
SELECT EmpID, EmpName, City FROM Employee WHERE City IS NULL;


-- =====================================================================
-- STEP 5 : SESSION CHECK
-- =====================================================================
-- Confirm autocommit is ON (1) so that later statements save normally.
SELECT @@autocommit AS autocommit_status;


-- =====================================================================
-- STEP 6 : LAB TASKS
-- =====================================================================

-- ---------------------------------------------------------------------
-- Task 1
-- List EmpID, EmpName and Salary of all employees earning more than 90,000.
-- Operator: > (strictly greater, so Fatima at exactly 90,000 is excluded)
-- Expected: 6 rows  (Ali, Sara, Ayesha, Maira, Sana, Imran)
-- ---------------------------------------------------------------------
SELECT EmpID, EmpName, Salary
FROM Employee
WHERE Salary > 90000;


-- ---------------------------------------------------------------------
-- Task 2
-- All employees with salary <= 75,000. Show EmpName and Salary.
-- Operator: <= (75,000 itself would be included, none exactly at 75,000)
-- Expected: 4 rows  (Bilal, Zain, Nida, Talha)
-- ---------------------------------------------------------------------
SELECT EmpName, Salary
FROM Employee
WHERE Salary <= 75000;


-- ---------------------------------------------------------------------
-- Task 3
-- Every employee who works in Lahore AND earns more than 90,000.
-- Operator: AND (both conditions must be true)
-- Expected: 3 rows  (Ali, Sara, Maira)
-- ---------------------------------------------------------------------
SELECT *
FROM Employee
WHERE City = 'Lahore'
  AND Salary > 90000;


-- ---------------------------------------------------------------------
-- Task 4
-- Employees in Karachi OR Islamabad. Show EmpName and City.
-- Operator: OR (either city qualifies)
-- Expected: 7 rows
--   Karachi   : Hamza, Ayesha, Bilal, Sana        (4)
--   Islamabad : Fatima, Usman, Talha              (3)
-- ---------------------------------------------------------------------
SELECT EmpName, City
FROM Employee
WHERE City = 'Karachi'
   OR City = 'Islamabad';


-- ---------------------------------------------------------------------
-- Task 5
-- Female employees who are NOT in the Engineering department.
-- Operators: AND with != (DeptName has no NULLs, so != is safe here)
-- Expected: 6 rows  (Ayesha, Fatima, Maira, Nida, Sana, Mehwish)
-- ---------------------------------------------------------------------
SELECT EmpName, Gender, DeptName
FROM Employee
WHERE Gender = 'F'
  AND DeptName != 'Engineering';


-- ---------------------------------------------------------------------
-- Task 6
-- Male employees earning between 70,000 and 90,000.
-- Restriction: AND with comparison operators only (no BETWEEN yet).
-- Both ends inclusive, so use >= and <=.
-- Expected: 4 rows  (Hamza, Bilal, Usman, Adeel)
-- ---------------------------------------------------------------------
SELECT EmpName, Gender, Salary
FROM Employee
WHERE Gender = 'M'
  AND Salary >= 70000
  AND Salary <= 90000;


-- ---------------------------------------------------------------------
-- Task 7
-- Employees who are either Software Engineers OR earn more than 100,000.
-- Operator: OR (a row qualifies if it satisfies at least one condition)
-- Expected: 7 rows  (Ali, Sara, Hamza, Ayesha, Maira, Sana, Imran)
--   Sara and Hamza qualify by job title; the rest by salary.
-- ---------------------------------------------------------------------
SELECT EmpName, JobTitle, Salary
FROM Employee
WHERE JobTitle = 'Software Engineer'
   OR Salary > 100000;


-- ---------------------------------------------------------------------
-- Task 8
-- Employees who are NOT in Marketing AND NOT in Sales.
-- Note: with NOT, the connector must be AND. Using OR here would
-- return every employee, because nobody is in both departments.
-- Expected: 11 rows (all except Ayesha, Bilal, Sana, Talha)
-- ---------------------------------------------------------------------
SELECT EmpName, DeptName
FROM Employee
WHERE DeptName != 'Marketing'
  AND DeptName != 'Sales';

-- Equivalent form using NOT with parentheses (same 11 rows):
SELECT EmpName, DeptName
FROM Employee
WHERE NOT (DeptName = 'Marketing' OR DeptName = 'Sales');


-- =====================================================================
--  END OF LAB 06
-- =====================================================================
