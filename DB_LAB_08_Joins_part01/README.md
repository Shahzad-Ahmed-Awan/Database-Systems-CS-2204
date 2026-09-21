# Lab 08: SQL Joins (Part A)

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1?logo=mysql&logoColor=white)
![Topic](https://img.shields.io/badge/Topic-INNER%20%7C%20LEFT%20%7C%20RIGHT%20JOIN-2E8B57)
![Tasks](https://img.shields.io/badge/Tasks-10%2F10-brightgreen)
![Status](https://img.shields.io/badge/Status-Completed-success)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | INNER JOIN, LEFT JOIN, RIGHT JOIN |
| **Database / Tables** | `joins_lab` / `Department`, `Employee`, `Project`, `Assignment` |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Combine data spread across multiple normalized tables using `INNER JOIN`, `LEFT JOIN`, and `RIGHT JOIN` on a Company database (10 tasks).

## 2. Database Setup

### 2.1 Create and select database

```sql
CREATE DATABASE IF NOT EXISTS joins_lab;
USE joins_lab;
```

Result: database `joins_lab` created and selected.

### 2.2 Create tables

| Table | Columns | Keys |
|---|---|---|
| `Department` | DeptID, DeptName, Location, Budget | PK: DeptID |
| `Employee` | EmpID, EmpName, Gender, Salary, HireDate, City, ManagerID, DeptID | PK: EmpID; FK: DeptID → Department; FK: ManagerID → Employee |
| `Project` | ProjectID, ProjectName, StartDate, EndDate, DeptID | PK: ProjectID; FK: DeptID → Department |
| `Assignment` | EmpID, ProjectID, HoursPerWeek | PK: (EmpID, ProjectID); FK: EmpID → Employee; FK: ProjectID → Project |

```sql
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
```

### 2.3 Insert data

```sql
INSERT INTO Department VALUES ( ... 5 rows ... );
INSERT INTO Employee   VALUES ( ... 10 rows ... );
INSERT INTO Project    VALUES ( ... 6 rows ... );
INSERT INTO Assignment VALUES ( ... 9 rows ... );
```

Result: 5 departments, 10 employees, 6 projects, and 9 assignments inserted. The data deliberately contains gaps — an empty department, an employee-less city field, an unassigned project, and two unassigned employees — so that outer joins produce meaningful results.

### 2.4 Verification

**Row counts**

```sql
SELECT
  (SELECT COUNT(*) FROM Department) AS departments,
  (SELECT COUNT(*) FROM Employee)   AS employees,
  (SELECT COUNT(*) FROM Project)    AS projects,
  (SELECT COUNT(*) FROM Assignment) AS assignments;
```

| departments | employees | projects | assignments |
|---|---|---|---|
| 5 | 10 | 6 | 9 |

**Deliberate gaps check**

```sql
SELECT DeptName FROM Department d
WHERE NOT EXISTS (SELECT 1 FROM Employee e WHERE e.DeptID = d.DeptID);

SELECT ProjectName FROM Project WHERE DeptID IS NULL;

SELECT EmpName FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
WHERE a.EmpID IS NULL;
```

| Empty department | Project with no department | Employees with no assignment |
|---|---|---|
| Sales | Internal Tool | Usman Tariq, Nida Yousaf |

---

## 3. Task Results

### Task A1

**Requirement:** List every employee with their department name and location. (INNER JOIN)

```sql
SELECT e.EmpID, e.EmpName, d.DeptName, d.Location
FROM Employee e
INNER JOIN Department d ON e.DeptID = d.DeptID;
```

**Result** (10 rows)

| EmpID | EmpName | DeptName | Location |
|---|---|---|---|
| 101 | Ali Khan | Engineering | Lahore |
| 102 | Sara Iqbal | Engineering | Lahore |
| 103 | Hamza Raza | Engineering | Lahore |
| 104 | Ayesha Noor | Marketing | Karachi |
| 105 | Bilal Ahmed | Marketing | Karachi |
| 106 | Fatima Sheikh | Finance | Islamabad |
| 107 | Usman Tariq | Finance | Islamabad |
| 108 | Maira Javed | Research | Lahore |
| 109 | Zain Abbas | Research | Lahore |
| 110 | Nida Yousaf | Research | Lahore |

### Task A2

**Requirement:** Same as A1, but include employees whose `DeptID` is NULL, if any. (LEFT JOIN)

```sql
SELECT e.EmpID, e.EmpName, d.DeptName, d.Location
FROM Employee e
LEFT JOIN Department d ON e.DeptID = d.DeptID;
```

**Result** (10 rows — identical to A1)

**Note:** Every employee in this dataset has a valid `DeptID`, so `LEFT JOIN` behaves exactly like `INNER JOIN` here. The row count would only diverge if an employee record had `DeptID IS NULL`.

### Task A3

**Requirement:** List every department with the names of its employees. Departments with no employees should still appear once with NULL EmpName.

```sql
SELECT d.DeptName, e.EmpName
FROM Employee e
RIGHT JOIN Department d ON e.DeptID = d.DeptID
ORDER BY d.DeptName;
```

**Result** (11 rows)

| DeptName | EmpName |
|---|---|
| Engineering | Ali Khan |
| Engineering | Sara Iqbal |
| Engineering | Hamza Raza |
| Finance | Fatima Sheikh |
| Finance | Usman Tariq |
| Marketing | Ayesha Noor |
| Marketing | Bilal Ahmed |
| Research | Maira Javed |
| Research | Zain Abbas |
| Research | Nida Yousaf |
| Sales | NULL |

**Note:** Sales (DeptID 50) appears once with a NULL `EmpName` because no employee is currently assigned to it — the point of the `RIGHT JOIN`.

### Task A4

**Requirement:** List every project with its department name and location. Include projects that have no department.

```sql
SELECT p.ProjectName, d.DeptName, d.Location
FROM Project p
LEFT JOIN Department d ON p.DeptID = d.DeptID;
```

**Result** (6 rows)

| ProjectName | DeptName | Location |
|---|---|---|
| Website Revamp | Engineering | Lahore |
| Mobile App | Engineering | Lahore |
| Brand Campaign | Marketing | Karachi |
| Audit System | Finance | Islamabad |
| AI Research | Research | Lahore |
| Internal Tool | NULL | NULL |

**Note:** Internal Tool has no `DeptID`, so the `LEFT JOIN` still keeps it in the result with NULLs.

### Task A5

**Requirement:** Find employees who are not assigned to any project. (LEFT JOIN + IS NULL pattern)

```sql
SELECT e.EmpID, e.EmpName
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
WHERE a.EmpID IS NULL;
```

**Result** (2 rows)

| EmpID | EmpName |
|---|---|
| 107 | Usman Tariq |
| 110 | Nida Yousaf |

### Task A6

**Requirement:** List every project that currently has no assignments.

```sql
SELECT p.ProjectID, p.ProjectName
FROM Project p
LEFT JOIN Assignment a ON p.ProjectID = a.ProjectID
WHERE a.ProjectID IS NULL;
```

**Result** (1 row)

| ProjectID | ProjectName |
|---|---|
| 1006 | Internal Tool |

### Task A7

**Requirement:** Show every employee in the Engineering department along with their salary, sorted by salary descending. (INNER JOIN + WHERE)

```sql
SELECT e.EmpName, e.Salary
FROM Employee e
INNER JOIN Department d ON e.DeptID = d.DeptID
WHERE d.DeptName = 'Engineering'
ORDER BY e.Salary DESC;
```

**Result** (3 rows)

| EmpName | Salary |
|---|---|
| Ali Khan | 120000.00 |
| Sara Iqbal | 95000.00 |
| Hamza Raza | 85000.00 |

### Task A8

**Requirement:** List employees in Lahore-based departments. Show EmpName and DeptName.

```sql
SELECT e.EmpName, d.DeptName
FROM Employee e
INNER JOIN Department d ON e.DeptID = d.DeptID
WHERE d.Location = 'Lahore';
```

**Result** (6 rows)

| EmpName | DeptName |
|---|---|
| Ali Khan | Engineering |
| Sara Iqbal | Engineering |
| Hamza Raza | Engineering |
| Maira Javed | Research |
| Zain Abbas | Research |
| Nida Yousaf | Research |

**Note:** Filters on `d.Location` (Engineering and Research are both based in Lahore), not on the employee's personal `City` column.

### Task A9

**Requirement:** List every department and the count of how many employees work there (LEFT JOIN with COUNT and GROUP BY). Include departments with zero employees.

```sql
SELECT d.DeptName, COUNT(e.EmpID) AS EmployeeCount
FROM Department d
LEFT JOIN Employee e ON d.DeptID = e.DeptID
GROUP BY d.DeptID, d.DeptName
ORDER BY d.DeptName;
```

**Result** (5 rows)

| DeptName | EmployeeCount |
|---|---|
| Engineering | 3 |
| Finance | 2 |
| Marketing | 2 |
| Research | 3 |
| Sales | 0 |

**Note:** `COUNT(e.EmpID)` (not `COUNT(*)`) is used so that Sales correctly counts as 0 instead of 1.

### Task A10

**Requirement:** Produce a FULL OUTER JOIN result of Employee and Department using UNION.

```sql
SELECT e.EmpName, d.DeptName
FROM Employee e
LEFT JOIN Department d ON e.DeptID = d.DeptID
UNION
SELECT e.EmpName, d.DeptName
FROM Employee e
RIGHT JOIN Department d ON e.DeptID = d.DeptID;
```

**Result** (11 rows)

| EmpName | DeptName |
|---|---|
| Ali Khan | Engineering |
| Sara Iqbal | Engineering |
| Hamza Raza | Engineering |
| Ayesha Noor | Marketing |
| Bilal Ahmed | Marketing |
| Fatima Sheikh | Finance |
| Usman Tariq | Finance |
| Maira Javed | Research |
| Zain Abbas | Research |
| Nida Yousaf | Research |
| NULL | Sales |

**Note:** MySQL has no native `FULL OUTER JOIN`; combining a `LEFT JOIN` and a `RIGHT JOIN` with `UNION` (which drops duplicate rows) reproduces it — every employee and every department appear, matched where possible.

---

## 4. Summary

| Task | Concept | Rows returned |
|---|---|---|
| A1 | INNER JOIN | 10 |
| A2 | LEFT JOIN | 10 |
| A3 | RIGHT JOIN | 11 |
| A4 | LEFT JOIN (nullable FK) | 6 |
| A5 | Anti-join (LEFT JOIN + IS NULL) | 2 |
| A6 | Anti-join (LEFT JOIN + IS NULL) | 1 |
| A7 | INNER JOIN + WHERE + ORDER BY | 3 |
| A8 | INNER JOIN + WHERE | 6 |
| A9 | LEFT JOIN + COUNT + GROUP BY | 5 |
| A10 | FULL OUTER JOIN (via UNION) | 11 |

## 5. Files

- `Lab08_Joins.sql` — database setup and all 10 Part A tasks
