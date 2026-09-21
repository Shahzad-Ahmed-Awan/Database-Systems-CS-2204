# Lab 09: SQL Joins (Part B)

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1)
![Topic](https://img.shields.io/badge/Topic-SELF%20%7C%20MULTI--TABLE%20JOINS-0aa)
![Tasks](https://img.shields.io/badge/Tasks-10-success)
![Database](https://img.shields.io/badge/Database-joins__lab-lightgrey)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | SELF JOIN, 3- and 4-table joins, LEFT JOIN traps, aggregation over joins |
| **Database** | `joins_lab` |
| **Tables** | `Department`, `Employee`, `Project`, `Assignment` |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Join a table to itself, chain three and four tables together, and combine joins with filters and aggregates (10 tasks). The script repeats the Lab 08 setup, so it runs standalone.

## 2. Database Setup

### 2.1 Create and select database

```sql
CREATE DATABASE IF NOT EXISTS joins_lab;
USE joins_lab;

DROP TABLE IF EXISTS Assignment, Project, Employee, Department;
```

Result: database `joins_lab` created and selected; tables rebuilt from scratch.

### 2.2 Tables

The same four tables as Lab 08 are created (`Department`, `Employee`, `Project`, `Assignment`).

| Table | Key columns | Links to |
|---|---|---|
| Department | `DeptID` (PK) | — |
| Employee | `EmpID` (PK) | `DeptID` → Department, `ManagerID` → Employee |
| Project | `ProjectID` (PK) | `DeptID` → Department |
| Assignment | `EmpID` + `ProjectID` (composite PK) | Employee, Project |

The column used in this lab most often is `Employee.ManagerID`, a **self-referencing foreign key** pointing back at `Employee.EmpID`.

### 2.3 Insert data

```sql
INSERT INTO Department VALUES ( ... 5 rows ... );
INSERT INTO Employee   VALUES ( ... 10 rows ... );
INSERT INTO Project    VALUES ( ... 6 rows ... );
INSERT INTO Assignment VALUES ( ... 9 rows ... );
```

Result: 5 + 10 + 6 + 9 rows inserted.

### 2.4 Verification

**Row counts**

| Table | Rows |
|---|---|
| Department | 5 |
| Employee | 10 |
| Project | 6 |
| Assignment | 9 |

**Reporting hierarchy** (`ManagerID`)

```sql
SELECT EmpID, EmpName, ManagerID, DeptID FROM Employee ORDER BY DeptID, ManagerID;
```

| Department | Manager (ManagerID NULL) | Reports to them |
|---|---|---|
| Engineering (10) | 101 Ali Khan | 102 Sara Iqbal, 103 Hamza Raza |
| Marketing (20) | 104 Ayesha Noor | 105 Bilal Ahmed |
| Finance (30) | 106 Fatima Sheikh | 107 Usman Tariq |
| Research (40) | 108 Maira Javed | 109 Zain Abbas, 110 Nida Yousaf |

**Note:** Every manager and their reports sit in the same department, and every manager earns more than their reports. Tasks B2, B3 and B8 use this fact deliberately — they return empty sets.

---

## 3. Task Results

### Task B1

**Requirement:** For each employee, show their name and their manager's name. Top-level managers should still appear with NULL Manager. (SELF JOIN)

```sql
SELECT e.EmpName AS Employee,
       m.EmpName AS Manager
FROM Employee e
LEFT JOIN Employee m ON e.ManagerID = m.EmpID;
```

**Result** (10 rows)

| Employee | Manager |
|---|---|
| Ali Khan | NULL |
| Sara Iqbal | Ali Khan |
| Hamza Raza | Ali Khan |
| Ayesha Noor | NULL |
| Bilal Ahmed | Ayesha Noor |
| Fatima Sheikh | NULL |
| Usman Tariq | Fatima Sheikh |
| Maira Javed | NULL |
| Zain Abbas | Maira Javed |
| Nida Yousaf | Maira Javed |

**Note:** One physical table, two aliases — `e` is the employee role and `m` is the manager role. A LEFT JOIN is required, otherwise the four top-level managers (NULL `ManagerID`) would disappear.

### Task B2

**Requirement:** List employees who earn more than their direct manager. Show employee name, employee salary, manager name, manager salary.

```sql
SELECT e.EmpName AS Employee, e.Salary AS EmpSalary,
       m.EmpName AS Manager,  m.Salary AS MgrSalary
FROM Employee e
INNER JOIN Employee m ON e.ManagerID = m.EmpID
WHERE e.Salary > m.Salary;
```

**Result** (0 rows)

_Empty set (0 rows)._

**Verification** — the six employee/manager salary pairs:

| Employee | EmpSalary | Manager | MgrSalary | Earns more? |
|---|---|---|---|---|
| Sara Iqbal | 95000.00 | Ali Khan | 120000.00 | No |
| Hamza Raza | 85000.00 | Ali Khan | 120000.00 | No |
| Bilal Ahmed | 70000.00 | Ayesha Noor | 110000.00 | No |
| Usman Tariq | 78000.00 | Fatima Sheikh | 90000.00 | No |
| Zain Abbas | 60000.00 | Maira Javed | 115000.00 | No |
| Nida Yousaf | 72000.00 | Maira Javed | 115000.00 | No |

**Note:** The empty set is the correct answer, not a mistake. An INNER JOIN is right here — a top-level manager has no manager to compare against.

### Task B3

**Requirement:** List employees whose manager works in a different department. Show EmpName, ManagerName, and both department names.

```sql
SELECT e.EmpName  AS EmpName,
       m.EmpName  AS ManagerName,
       de.DeptName AS EmpDept,
       dm.DeptName AS ManagerDept
FROM Employee e
INNER JOIN Employee m    ON e.ManagerID = m.EmpID
INNER JOIN Department de ON e.DeptID    = de.DeptID
INNER JOIN Department dm ON m.DeptID    = dm.DeptID
WHERE e.DeptID <> m.DeptID;
```

**Result** (0 rows)

_Empty set (0 rows)._

**Note:** `Department` is joined twice with two different aliases (`de` for the employee's department, `dm` for the manager's). Every employee in this dataset reports within their own department, so nothing satisfies `e.DeptID <> m.DeptID`. Dropping the WHERE clause returns all 6 employee/manager pairs, confirming the joins themselves work.

### Task B4

**Requirement:** Show every employee with the project name they work on and weekly hours. (3-table join, employees with no assignment must still appear.)

```sql
SELECT e.EmpName, p.ProjectName, a.HoursPerWeek
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID     = a.EmpID
LEFT JOIN Project p    ON a.ProjectID = p.ProjectID
ORDER BY e.EmpName;
```

**Result** (11 rows)

| EmpName | ProjectName | HoursPerWeek |
|---|---|---|
| Ali Khan | Website Revamp | 10 |
| Ayesha Noor | Brand Campaign | 25 |
| Bilal Ahmed | Brand Campaign | 40 |
| Fatima Sheikh | Audit System | 35 |
| Hamza Raza | Mobile App | 30 |
| Maira Javed | AI Research | 20 |
| Nida Yousaf | NULL | NULL |
| Sara Iqbal | Website Revamp | 20 |
| Sara Iqbal | Mobile App | 15 |
| Usman Tariq | NULL | NULL |
| Zain Abbas | AI Research | 30 |

**Note:** 10 employees produce 11 rows: Sara Iqbal appears twice (two projects), while Usman Tariq and Nida Yousaf appear once with NULLs. The second LEFT JOIN must also be LEFT — one INNER JOIN anywhere in the chain would drop the unassigned employees again.

### Task B5

**Requirement:** List every assignment with employee name, project name, and the project's department name. (4-table join)

```sql
SELECT e.EmpName, p.ProjectName, d.DeptName, a.HoursPerWeek
FROM Assignment a
INNER JOIN Employee e   ON a.EmpID     = e.EmpID
INNER JOIN Project p    ON a.ProjectID = p.ProjectID
INNER JOIN Department d ON p.DeptID    = d.DeptID;
```

**Result** (9 rows)

| EmpName | ProjectName | DeptName | HoursPerWeek |
|---|---|---|---|
| Ali Khan | Website Revamp | Engineering | 10 |
| Sara Iqbal | Website Revamp | Engineering | 20 |
| Sara Iqbal | Mobile App | Engineering | 15 |
| Hamza Raza | Mobile App | Engineering | 30 |
| Ayesha Noor | Brand Campaign | Marketing | 25 |
| Bilal Ahmed | Brand Campaign | Marketing | 40 |
| Fatima Sheikh | Audit System | Finance | 35 |
| Maira Javed | AI Research | Research | 20 |
| Zain Abbas | AI Research | Research | 30 |

**Note:** The query starts from `Assignment` (the bridge table of the many-to-many relationship) and walks outward. All 9 assignments survive because every assigned project has a department; `Internal Tool` (DeptID NULL) has no assignments anyway.

### Task B6

**Requirement:** List the names and weekly hours of employees working on the Mobile App project.

```sql
SELECT e.EmpName, a.HoursPerWeek
FROM Employee e
INNER JOIN Assignment a ON e.EmpID     = a.EmpID
INNER JOIN Project p    ON a.ProjectID = p.ProjectID
WHERE p.ProjectName = 'Mobile App';
```

**Result** (2 rows)

| EmpName | HoursPerWeek |
|---|---|
| Sara Iqbal | 15 |
| Hamza Raza | 30 |

### Task B7

**Requirement:** List every employee in Lahore together with the projects they are assigned to. Include Lahore employees with no assignments.

```sql
SELECT e.EmpName, p.ProjectName, a.HoursPerWeek
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID     = a.EmpID
LEFT JOIN Project p    ON a.ProjectID = p.ProjectID
WHERE e.City = 'Lahore';
```

**Result** (5 rows)

| EmpName | ProjectName | HoursPerWeek |
|---|---|---|
| Ali Khan | Website Revamp | 10 |
| Sara Iqbal | Website Revamp | 20 |
| Sara Iqbal | Mobile App | 15 |
| Maira Javed | AI Research | 20 |
| Zain Abbas | AI Research | 30 |

**Note:** The WHERE filter is on `Employee`, the preserved (left) table, so it is safe here. Nida Yousaf is absent because her city is NULL, and `NULL = 'Lahore'` is never true — not because of the join.

### Task B8

**Requirement:** List the names of employees who work on a project run by a department different from their own.

```sql
SELECT DISTINCT e.EmpName
FROM Employee e
INNER JOIN Assignment a ON e.EmpID     = a.EmpID
INNER JOIN Project p    ON a.ProjectID = p.ProjectID
WHERE p.DeptID IS NOT NULL
  AND e.DeptID <> p.DeptID;
```

**Result** (0 rows)

_Empty set (0 rows)._

**Note:** Every employee in this dataset is assigned only to projects owned by their own department. `p.DeptID IS NOT NULL` is still needed: a NULL department would make `e.DeptID <> p.DeptID` evaluate to UNKNOWN rather than TRUE, which is easy to misread. `DISTINCT` prevents an employee on two cross-department projects from being listed twice.

### Task B9

**Requirement:** For each department, list the names of projects that started in 2024. Include departments that have no such projects.

```sql
SELECT d.DeptName, p.ProjectName
FROM Department d
LEFT JOIN Project p
    ON d.DeptID = p.DeptID
   AND YEAR(p.StartDate) = 2024
ORDER BY d.DeptName;
```

**Result** (6 rows)

| DeptName | ProjectName |
|---|---|
| Engineering | Website Revamp |
| Engineering | Mobile App |
| Finance | Audit System |
| Marketing | Brand Campaign |
| Research | AI Research |
| Sales | NULL |

**Note — the LEFT JOIN + WHERE trap:** the date condition is placed in the `ON` clause, not in `WHERE`. In `ON` it filters which rows *match*; in `WHERE` it would be applied after the join and would delete the Sales row (its `ProjectName` is NULL, so `YEAR(NULL) = 2024` is not true), turning the LEFT JOIN back into an INNER JOIN and returning only 5 rows.

### Task B10

**Requirement:** List every employee with the total hours they work per week across all their projects. Include employees with zero hours.

```sql
SELECT e.EmpName, COALESCE(SUM(a.HoursPerWeek), 0) AS TotalHoursPerWeek
FROM Employee e
LEFT JOIN Assignment a ON e.EmpID = a.EmpID
GROUP BY e.EmpID, e.EmpName
ORDER BY e.EmpName;
```

**Result** (10 rows)

| EmpName | TotalHoursPerWeek |
|---|---|
| Ali Khan | 10 |
| Ayesha Noor | 25 |
| Bilal Ahmed | 40 |
| Fatima Sheikh | 35 |
| Hamza Raza | 30 |
| Maira Javed | 20 |
| Nida Yousaf | 0 |
| Sara Iqbal | 35 |
| Usman Tariq | 0 |
| Zain Abbas | 30 |

**Note:** Sara Iqbal's 35 is 20 + 15 from two projects. `SUM` over no rows returns NULL, so `COALESCE(..., 0)` displays a clean 0 for the two unassigned employees. Grouping by `e.EmpID` as well as `e.EmpName` keeps the result correct even if two employees shared a name.

---

## 4. Summary

| Task | Concept | Rows returned |
|---|---|---|
| B1 | SELF JOIN (LEFT) | 10 |
| B2 | SELF JOIN + comparison | 0 |
| B3 | SELF JOIN + Department twice | 0 |
| B4 | 3-table LEFT JOIN chain | 11 |
| B5 | 4-table INNER JOIN | 9 |
| B6 | 3-table JOIN + WHERE | 2 |
| B7 | LEFT JOIN + WHERE on left table | 5 |
| B8 | JOIN + column-to-column comparison | 0 |
| B9 | LEFT JOIN with filter in ON clause | 6 |
| B10 | LEFT JOIN + SUM + GROUP BY + COALESCE | 10 |

## 5. Key Takeaways

- A **self join** needs two aliases of the same table; use LEFT JOIN so rows with a NULL self-reference survive.
- In a **chain of joins**, a single INNER JOIN anywhere cancels the row-preserving effect of the LEFT JOINs before it.
- Filter conditions on the **right table** belong in `ON`; conditions on the **left (preserved)** table are safe in `WHERE`.
- An **empty result set is a valid answer** — verify it by relaxing the condition rather than rewriting the join.
- `COALESCE(SUM(x), 0)` turns the NULL produced by an outer join into a readable zero.

## 6. Files

- `Lab09_Joins.sql` — setup script and Tasks B1 to B10
