# Lab 06: SQL Filters (Part 1)

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1?logo=mysql&logoColor=white)
![Topic](https://img.shields.io/badge/Topic-WHERE%20%7C%20Comparison%20%7C%20Logical%20Operators-2E8B57)
![Tasks](https://img.shields.io/badge/Tasks-8%2F8-brightgreen)
![Status](https://img.shields.io/badge/Status-Completed-success)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | WHERE clause, comparison operators, AND / OR / NOT |
| **Database / Table** | `filters_lab` / `Employee` |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Apply the WHERE clause with comparison and logical operators to retrieve specific rows from the Employee table (8 tasks).

## 2. Database Setup

### 2.1 Create and select database

```sql
CREATE DATABASE IF NOT EXISTS filters_lab;
USE filters_lab;
```

Result: database `filters_lab` created and selected.

### 2.2 Create table `Employee`

```sql
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
```

Table structure (`DESCRIBE Employee`):

| Column | Data type | Constraint |
|---|---|---|
| EmpID | int | PRIMARY KEY |
| EmpName | varchar(50) | NOT NULL |
| Gender | char(1) | — |
| Salary | decimal(10,2) | — |
| HireDate | date | — |
| City | varchar(30) | — |
| JobTitle | varchar(40) | — |
| DeptName | varchar(40) | — |

### 2.3 Insert data (transaction)

```sql
START TRANSACTION;
INSERT INTO Employee VALUES ( ... 15 rows ... );
COMMIT;
```

Result: 15 rows inserted and committed.

### 2.4 Verification

**Row count**

```sql
SELECT COUNT(*) AS total_employees FROM Employee;
```

| total_employees |
|---|
| 15 |

**Salary and hire-date range**

```sql
SELECT MIN(Salary) AS min_salary, MAX(Salary) AS max_salary, MIN(HireDate) AS earliest_hire, MAX(HireDate) AS latest_hire FROM Employee;
```

| min_salary | max_salary | earliest_hire | latest_hire |
|---|---|---|---|
| 60000.00 | 125000.00 | 2015-04-30 | 2023-07-18 |

**NULL city check**

```sql
SELECT EmpID, EmpName, City FROM Employee WHERE City IS NULL;
```

| EmpID | EmpName | City |
|---|---|---|
| 110 | Nida Yousaf | NULL |
| 115 | Imran Shafi | NULL |

---

## 3. Task Results

### Task 1

**Requirement:** List EmpID, EmpName and Salary of all employees earning more than 90,000.

```sql
SELECT EmpID, EmpName, Salary
FROM Employee
WHERE Salary > 90000;
```

**Result** (6 rows)

| EmpID | EmpName | Salary |
|---|---|---|
| 101 | Ali Khan | 120000.00 |
| 102 | Sara Iqbal | 95000.00 |
| 104 | Ayesha Noor | 110000.00 |
| 108 | Maira Javed | 115000.00 |
| 112 | Sana Malik | 102000.00 |
| 115 | Imran Shafi | 125000.00 |

**Note:** Fatima Sheikh (exactly 90,000) is excluded because the operator is strictly greater than.

### Task 2

**Requirement:** All employees with salary <= 75,000. Show EmpName and Salary.

```sql
SELECT EmpName, Salary
FROM Employee
WHERE Salary <= 75000;
```

**Result** (4 rows)

| EmpName | Salary |
|---|---|
| Bilal Ahmed | 70000.00 |
| Zain Abbas | 60000.00 |
| Nida Yousaf | 72000.00 |
| Talha Hussain | 65000.00 |

### Task 3

**Requirement:** Employees who work in Lahore AND earn more than 90,000.

```sql
SELECT *
FROM Employee
WHERE City = 'Lahore'
  AND Salary > 90000;
```

**Result** (3 rows)

| EmpID | EmpName | Gender | Salary | HireDate | City | JobTitle | DeptName |
|---|---|---|---|---|---|---|---|
| 101 | Ali Khan | M | 120000.00 | 2018-03-15 | Lahore | Senior Engineer | Engineering |
| 102 | Sara Iqbal | F | 95000.00 | 2019-06-01 | Lahore | Software Engineer | Engineering |
| 108 | Maira Javed | F | 115000.00 | 2016-07-22 | Lahore | Research Lead | Research |

### Task 4

**Requirement:** Employees in Karachi OR Islamabad. Show EmpName and City.

```sql
SELECT EmpName, City
FROM Employee
WHERE City = 'Karachi'
   OR City = 'Islamabad';
```

**Result** (7 rows)

| EmpName | City |
|---|---|
| Hamza Raza | Karachi |
| Ayesha Noor | Karachi |
| Bilal Ahmed | Karachi |
| Fatima Sheikh | Islamabad |
| Usman Tariq | Islamabad |
| Sana Malik | Karachi |
| Talha Hussain | Islamabad |

### Task 5

**Requirement:** Female employees who are NOT in the Engineering department.

```sql
SELECT EmpName, Gender, DeptName
FROM Employee
WHERE Gender = 'F'
  AND DeptName != 'Engineering';
```

**Result** (6 rows)

| EmpName | Gender | DeptName |
|---|---|---|
| Ayesha Noor | F | Marketing |
| Fatima Sheikh | F | Finance |
| Maira Javed | F | Research |
| Nida Yousaf | F | Research |
| Sana Malik | F | Sales |
| Mehwish Anwar | F | HR |

### Task 6

**Requirement:** Male employees earning between 70,000 and 90,000.

```sql
SELECT EmpName, Gender, Salary
FROM Employee
WHERE Gender = 'M'
  AND Salary >= 70000
  AND Salary <= 90000;
```

**Result** (4 rows)

| EmpName | Gender | Salary |
|---|---|---|
| Hamza Raza | M | 85000.00 |
| Bilal Ahmed | M | 70000.00 |
| Usman Tariq | M | 78000.00 |
| Adeel Akhtar | M | 88000.00 |

### Task 7

**Requirement:** Employees who are either Software Engineers OR earn more than 100,000.

```sql
SELECT EmpName, JobTitle, Salary
FROM Employee
WHERE JobTitle = 'Software Engineer'
   OR Salary > 100000;
```

**Result** (7 rows)

| EmpName | JobTitle | Salary |
|---|---|---|
| Ali Khan | Senior Engineer | 120000.00 |
| Sara Iqbal | Software Engineer | 95000.00 |
| Hamza Raza | Software Engineer | 85000.00 |
| Ayesha Noor | Marketing Lead | 110000.00 |
| Maira Javed | Research Lead | 115000.00 |
| Sana Malik | Sales Manager | 102000.00 |
| Imran Shafi | Director | 125000.00 |

### Task 8

**Requirement:** Employees who are NOT in Marketing AND NOT in Sales.

```sql
SELECT EmpName, DeptName
FROM Employee
WHERE DeptName != 'Marketing'
  AND DeptName != 'Sales';

-- Equivalent form using NOT with parentheses (same 11 rows):
SELECT EmpName, DeptName
FROM Employee
WHERE NOT (DeptName = 'Marketing' OR DeptName = 'Sales');
```

**Result 1** (11 rows)

| EmpName | DeptName |
|---|---|
| Ali Khan | Engineering |
| Sara Iqbal | Engineering |
| Hamza Raza | Engineering |
| Fatima Sheikh | Finance |
| Usman Tariq | Finance |
| Maira Javed | Research |
| Zain Abbas | Research |
| Nida Yousaf | Research |
| Adeel Akhtar | Engineering |
| Mehwish Anwar | HR |
| Imran Shafi | Engineering |

**Result 2** (11 rows)

| EmpName | DeptName |
|---|---|
| Ali Khan | Engineering |
| Sara Iqbal | Engineering |
| Hamza Raza | Engineering |
| Fatima Sheikh | Finance |
| Usman Tariq | Finance |
| Maira Javed | Research |
| Zain Abbas | Research |
| Nida Yousaf | Research |
| Adeel Akhtar | Engineering |
| Mehwish Anwar | HR |
| Imran Shafi | Engineering |

**Note:** The AND form and the NOT (... OR ...) form return the same 11 rows.

---

## 4. Summary

| Task | Concept | Rows returned |
|---|---|---|
| Task 1 | Comparison (>) | 6 |
| Task 2 | Comparison (<=) | 4 |
| Task 3 | AND | 3 |
| Task 4 | OR | 7 |
| Task 5 | AND with != | 6 |
| Task 6 | AND with >= / <= | 4 |
| Task 7 | OR | 7 |
| Task 8 | NOT / AND | 11 / 11 |

## 5. Files

- `Lab06_Filters.sql` — database setup and all 8 tasks
