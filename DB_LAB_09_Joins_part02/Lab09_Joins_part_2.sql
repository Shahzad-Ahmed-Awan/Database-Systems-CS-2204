-- ============================================================
-- DATABASE SYSTEMS | LAB 09 - SQL JOINS (Part B)
-- SELF JOIN, multi-table joins, and combined challenges
-- Compatible with MySQL 8.x
-- Uses the same Company schema (joins_lab) set up in Lab 08.
-- Name: Shahzad Ahmed Awan    Roll No: 2024-SE-15
-- Submitted to: Sir Awais Rathore
-- ============================================================

-- ------------------------------------------------------------
-- 0. SETUP SCRIPT (run once before attempting the tasks -
--    identical to Lab 08 so this file can run standalone too)
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
-- PART B — SELF JOINS, MULTI-TABLE JOINS, COMBINED CHALLENGES
-- ============================================================

-- Task B1: For each employee, show their name and their manager's name.
-- Top-level managers should still appear with NULL Manager. (SELF JOIN)
SELECT e.EmpName AS Employee,
       m.EmpName AS Manager
FROM Employee e
LEFT JOIN Employee m ON e.ManagerID = m.EmpID;

-- Task B2: List employees who earn more than their direct manager.
-- Show employee name, employee salary, manager name, manager salary.
SELECT e.EmpName AS Employee, e.Salary AS EmpSalary,
       m.EmpName AS Manager,  m.Salary AS MgrSalary
FROM Employee e
INNER JOIN Employee m ON e.ManagerID = m.EmpID
WHERE e.Salary > m.Salary;

-- Task B3: List employees whose manager works in a different department.
-- Show EmpName, ManagerName, and both department names.
-- (self-join Employee, then join Department twice with different aliases)
SELECT e.EmpName            AS EmpName,
       m.EmpName            AS ManagerName,
       de.DeptName          AS EmpDept,
       dm.DeptName          AS ManagerDept
FROM Employee e
INNER JOIN Employee m   ON e.ManagerID = m.EmpID
INNER JOIN Department de ON e.DeptID = de.DeptID
INNER JOIN Department dm ON m.DeptID = dm.DeptID
WHERE e.DeptID <> m.DeptID;

-- Task B4: Show every employee with the project name they work on and weekly hours.
-- (3-table join: Employee -> Assignment -> Project)
-- LEFT JOINs are used so that employees with no assignment (107, 110) still appear.
SELECT e.EmpName, p.ProjectName, a.HoursPerWeek
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
LEFT JOIN Project p    ON a.ProjectID = p.ProjectID
ORDER BY e.EmpName;

-- Task B5: List every assignment with employee name, project name, and the
-- project's department name. (4-table join)
SELECT e.EmpName, p.ProjectName, d.DeptName, a.HoursPerWeek
FROM Assignment a
INNER JOIN Employee e   ON a.EmpID = e.EmpID
INNER JOIN Project p    ON a.ProjectID = p.ProjectID
INNER JOIN Department d ON p.DeptID = d.DeptID;

-- Task B6: List the names and weekly hours of employees working on the
-- Mobile App project.
SELECT e.EmpName, a.HoursPerWeek
FROM Employee e
INNER JOIN Assignment a ON e.EmpID = a.EmpID
INNER JOIN Project p    ON a.ProjectID = p.ProjectID
WHERE p.ProjectName = 'Mobile App';

-- Task B7: List every employee in Lahore together with the projects they are
-- assigned to (project name and hours). Include Lahore employees with no
-- assignments.
SELECT e.EmpName, p.ProjectName, a.HoursPerWeek
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
LEFT JOIN Project p    ON a.ProjectID = p.ProjectID
WHERE e.City = 'Lahore';

-- Task B8: List the names of employees who work on a project run by a
-- department different from their own. (Compare e.DeptID and p.DeptID.)
SELECT DISTINCT e.EmpName
FROM Employee e
INNER JOIN Assignment a ON e.EmpID = a.EmpID
INNER JOIN Project p    ON a.ProjectID = p.ProjectID
WHERE p.DeptID IS NOT NULL
  AND e.DeptID <> p.DeptID;

-- Task B9: For each department, list the names of projects that started in 2024.
-- Include departments that have no such projects. (LEFT JOIN + WHERE on date)
-- NOTE: the date filter is placed in the ON clause, not WHERE, so departments
-- with no matching 2024 project are NOT silently dropped (see the LEFT JOIN +
-- WHERE trap explained in the lab manual).
SELECT d.DeptName, p.ProjectName
FROM Department d
LEFT JOIN Project p
    ON d.DeptID = p.DeptID
   AND YEAR(p.StartDate) = 2024
ORDER BY d.DeptName;

-- Task B10: List every employee with the total hours they work per week across
-- all their projects. Include employees with zero hours. (LEFT JOIN + SUM + GROUP BY)
SELECT e.EmpName, COALESCE(SUM(a.HoursPerWeek), 0) AS TotalHoursPerWeek
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
GROUP BY e.EmpID, e.EmpName
ORDER BY e.EmpName;

-- End of Lab 09 (Part B)
