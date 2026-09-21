-- ============================================================
-- DATABASE SYSTEMS | LAB 08 - SQL JOINS (Part A)
-- INNER JOIN, LEFT JOIN, RIGHT JOIN on the Company schema
-- Compatible with MySQL 8.x
-- Name: Shahzad Ahmed Awan    Roll No: 2024-SE-15
-- Submitted to: Sir Awais Rathore
-- ============================================================

-- ------------------------------------------------------------
-- 0. SETUP SCRIPT (run once before attempting the tasks)
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS joins_lab;
USE joins_lab;

DROP TABLE IF EXISTS Assignment, Project, Employee, Department;

CREATE TABLE Department (
    DeptID   INT PRIMARY KEY,
    DeptName VARCHAR(40) NOT NULL,
    Location VARCHAR(30),
    Budget   DECIMAL(12,2)
);

CREATE TABLE Employee (
    EmpID     INT PRIMARY KEY,
    EmpName   VARCHAR(50) NOT NULL,
    Gender    CHAR(1),
    Salary    DECIMAL(10,2),
    HireDate  DATE,
    City      VARCHAR(30),
    ManagerID INT,
    DeptID    INT,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID),
    FOREIGN KEY (ManagerID) REFERENCES Employee(EmpID)
);

CREATE TABLE Project (
    ProjectID   INT PRIMARY KEY,
    ProjectName VARCHAR(50) NOT NULL,
    StartDate   DATE,
    EndDate     DATE,
    DeptID      INT,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

CREATE TABLE Assignment (
    EmpID        INT,
    ProjectID    INT,
    HoursPerWeek INT,
    PRIMARY KEY (EmpID, ProjectID),
    FOREIGN KEY (EmpID) REFERENCES Employee(EmpID),
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

-- Departments
INSERT INTO Department VALUES
(10, 'Engineering', 'Lahore', 5000000),
(20, 'Marketing',   'Karachi', 2000000),
(30, 'Finance',     'Islamabad', 3000000),
(40, 'Research',    'Lahore', 4000000),
(50, 'Sales',       'Karachi', NULL); -- new dept, no employees yet

-- Employees (NULL ManagerID = top of the hierarchy)
INSERT INTO Employee VALUES
(101,'Ali Khan',     'M', 120000,'2018-03-15','Lahore',    NULL, 10),
(102,'Sara Iqbal',   'F', 95000, '2019-06-01','Lahore',    101,  10),
(103,'Hamza Raza',   'M', 85000, '2020-01-20','Karachi',   101,  10),
(104,'Ayesha Noor',  'F', 110000,'2017-11-10','Karachi',   NULL, 20),
(105,'Bilal Ahmed',  'M', 70000, '2021-04-05','Karachi',   104,  20),
(106,'Fatima Sheikh','F', 90000, '2019-09-12','Islamabad', NULL, 30),
(107,'Usman Tariq',  'M', 78000, '2022-02-18','Islamabad', 106,  30),
(108,'Maira Javed',  'F', 115000,'2016-07-22','Lahore',    NULL, 40),
(109,'Zain Abbas',   'M', 60000, '2023-01-09','Lahore',    108,  40),
(110,'Nida Yousaf',  'F', 72000, '2022-08-30',NULL,        108,  40);

-- Projects
INSERT INTO Project VALUES
(1001,'Website Revamp', '2024-01-10','2024-06-30', 10),
(1002,'Mobile App',     '2024-03-01','2024-12-31', 10),
(1003,'Brand Campaign', '2024-02-15','2024-05-15', 20),
(1004,'Audit System',   '2024-04-01',NULL,         30),
(1005,'AI Research',    '2024-05-01','2025-04-30', 40),
(1006,'Internal Tool',  '2024-06-01','2024-09-30', NULL); -- no dept yet

-- Assignments (employees 107 and 110 are NOT assigned, project 1006 has no staff)
INSERT INTO Assignment VALUES
(101, 1001, 10),
(102, 1001, 20),
(102, 1002, 15),
(103, 1002, 30),
(104, 1003, 25),
(105, 1003, 40),
(106, 1004, 35),
(108, 1005, 20),
(109, 1005, 30);


-- ============================================================
-- PART A — INNER, LEFT, and RIGHT JOINS
-- ============================================================

-- Task A1: List every employee with their department name and location. (INNER JOIN)
SELECT e.EmpID, e.EmpName, d.DeptName, d.Location
FROM Employee e
INNER JOIN Department d ON e.DeptID = d.DeptID;

-- Task A2: Same as A1, but include employees whose DeptID is NULL, if any. (LEFT JOIN)
SELECT e.EmpID, e.EmpName, d.DeptName, d.Location
FROM Employee e
LEFT JOIN Department d ON e.DeptID = d.DeptID;

-- Task A3: List every department with the names of its employees.
-- Departments with no employees should still appear once with NULL EmpName.
SELECT d.DeptName, e.EmpName
FROM Employee e
RIGHT JOIN Department d ON e.DeptID = d.DeptID
ORDER BY d.DeptName;

-- Task A4: List every project with its department name and location.
-- Include projects that have no department.
SELECT p.ProjectName, d.DeptName, d.Location
FROM Project p
LEFT JOIN Department d ON p.DeptID = d.DeptID;

-- Task A5: Find employees who are not assigned to any project. (LEFT JOIN + IS NULL pattern)
SELECT e.EmpID, e.EmpName
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
WHERE a.EmpID IS NULL;

-- Task A6: List every project that currently has no assignments.
SELECT p.ProjectID, p.ProjectName
FROM Project p
LEFT JOIN Assignment a ON p.ProjectID = a.ProjectID
WHERE a.ProjectID IS NULL;

-- Task A7: Show every employee in the Engineering department along with their
-- salary, sorted by salary descending. (INNER JOIN + WHERE)
SELECT e.EmpName, e.Salary
FROM Employee e
INNER JOIN Department d ON e.DeptID = d.DeptID
WHERE d.DeptName = 'Engineering'
ORDER BY e.Salary DESC;

-- Task A8: List employees in Lahore-based departments. Show EmpName and DeptName.
SELECT e.EmpName, d.DeptName
FROM Employee e
INNER JOIN Department d ON e.DeptID = d.DeptID
WHERE d.Location = 'Lahore';

-- Task A9: List every department and the count of how many employees work there
-- (LEFT JOIN with COUNT and GROUP BY). Include departments with zero employees.
SELECT d.DeptName, COUNT(e.EmpID) AS EmployeeCount
FROM Department d
LEFT JOIN Employee e ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName
ORDER BY d.DeptName;

-- Task A10: Produce a FULL OUTER JOIN result of Employee and Department using UNION.
SELECT e.EmpName, d.DeptName
FROM Employee e
LEFT JOIN Department d ON e.DeptID = d.DeptID
UNION
SELECT e.EmpName, d.DeptName
FROM Employee e
RIGHT JOIN Department d ON e.DeptID = d.DeptID;

-- End of Lab 08 (Part A)
