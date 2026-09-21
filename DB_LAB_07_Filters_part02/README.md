# Lab 07: SQL Filters (Part 2)

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1?logo=mysql&logoColor=white)
![Topic](https://img.shields.io/badge/Topic-BETWEEN%20%7C%20IN%20%7C%20LIKE%20%7C%20IS%20NULL%20%7C%20ORDER%20BY%20%7C%20LIMIT-2E8B57)
![Tasks](https://img.shields.io/badge/Tasks-15%2F15-brightgreen)
![Status](https://img.shields.io/badge/Status-Completed-success)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | BETWEEN, IN, LIKE, IS NULL, ORDER BY, LIMIT |
| **Database / Table** | `filters_lab` / `Employee` |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Apply range, list, pattern and NULL filters, together with sorting and row limiting, on the Employee table (15 tasks). The script rebuilds the table, so it runs independently of Lab 06.

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
    EmpID     INT           PRIMARY KEY,
    EmpName   VARCHAR(50)   NOT NULL,
    Gender    CHAR(1),
    Salary    DECIMAL(10,2),
    HireDate  DATE,
    City      VARCHAR(30),
    JobTitle  VARCHAR(40),
    DeptName  VARCHAR(40)
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

**Requirement:** Salary between 75,000 and 100,000 (inclusive), sorted by salary ascending.

```sql
SELECT EmpName, Salary
FROM Employee
WHERE Salary BETWEEN 75000 AND 100000
ORDER BY Salary ASC;
```

**Result** (6 rows)

| EmpName | Salary |
|---|---|
| Usman Tariq | 78000.00 |
| Mehwish Anwar | 80000.00 |
| Hamza Raza | 85000.00 |
| Adeel Akhtar | 88000.00 |
| Fatima Sheikh | 90000.00 |
| Sara Iqbal | 95000.00 |

### Task 2

**Requirement:** Employees hired between January 2020 and December 2022.

```sql
SELECT EmpName, HireDate
FROM Employee
WHERE HireDate BETWEEN '2020-01-01' AND '2022-12-31'
ORDER BY HireDate;
```

**Result** (6 rows)

| EmpName | HireDate |
|---|---|
| Hamza Raza | 2020-01-20 |
| Adeel Akhtar | 2020-05-14 |
| Bilal Ahmed | 2021-04-05 |
| Mehwish Anwar | 2021-10-25 |
| Usman Tariq | 2022-02-18 |
| Nida Yousaf | 2022-08-30 |

### Task 3

**Requirement:** Salary NOT between 80,000 and 100,000.

```sql
SELECT EmpName, Salary
FROM Employee
WHERE Salary NOT BETWEEN 80000 AND 100000;
```

**Result** (10 rows)

| EmpName | Salary |
|---|---|
| Ali Khan | 120000.00 |
| Ayesha Noor | 110000.00 |
| Bilal Ahmed | 70000.00 |
| Usman Tariq | 78000.00 |
| Maira Javed | 115000.00 |
| Zain Abbas | 60000.00 |
| Nida Yousaf | 72000.00 |
| Sana Malik | 102000.00 |
| Talha Hussain | 65000.00 |
| Imran Shafi | 125000.00 |

**Note:** Mehwish Anwar (exactly 80,000) lies on the range boundary and is therefore excluded.

### Task 4

**Requirement:** Employees whose city is Lahore or Islamabad. Sort by city, then by salary highest first within each city.

```sql
SELECT EmpName, City, Salary
FROM Employee
WHERE City IN ('Lahore', 'Islamabad')
ORDER BY City ASC, Salary DESC;
```

**Result** (9 rows)

| EmpName | City | Salary |
|---|---|---|
| Fatima Sheikh | Islamabad | 90000.00 |
| Usman Tariq | Islamabad | 78000.00 |
| Talha Hussain | Islamabad | 65000.00 |
| Ali Khan | Lahore | 120000.00 |
| Maira Javed | Lahore | 115000.00 |
| Sara Iqbal | Lahore | 95000.00 |
| Adeel Akhtar | Lahore | 88000.00 |
| Mehwish Anwar | Lahore | 80000.00 |
| Zain Abbas | Lahore | 60000.00 |

### Task 5

**Requirement:** Employees in any department except Engineering, Sales and HR.

```sql
SELECT EmpName, DeptName
FROM Employee
WHERE DeptName NOT IN ('Engineering', 'Sales', 'HR');
```

**Result** (7 rows)

| EmpName | DeptName |
|---|---|
| Ayesha Noor | Marketing |
| Bilal Ahmed | Marketing |
| Fatima Sheikh | Finance |
| Usman Tariq | Finance |
| Maira Javed | Research |
| Zain Abbas | Research |
| Nida Yousaf | Research |

### Task 6

**Requirement:** Names starting with the letter 'M'.

```sql
SELECT EmpName
FROM Employee
WHERE EmpName LIKE 'M%';
```

**Result** (2 rows)

| EmpName |
|---|
| Maira Javed |
| Mehwish Anwar |

### Task 7

**Requirement:** Names containing the letter 'a' anywhere (case-insensitive).

```sql
SELECT EmpName
FROM Employee
WHERE EmpName LIKE '%a%';
```

**Result** (15 rows)

| EmpName |
|---|
| Ali Khan |
| Sara Iqbal |
| Hamza Raza |
| Ayesha Noor |
| Bilal Ahmed |
| Fatima Sheikh |
| Usman Tariq |
| Maira Javed |
| Zain Abbas |
| Nida Yousaf |
| Adeel Akhtar |
| Sana Malik |
| Talha Hussain |
| Mehwish Anwar |
| Imran Shafi |

**Note:** Every employee name contains the letter "a"; matching is case-insensitive in MySQL.

### Task 8

**Requirement:** Names ending with 'an'.

```sql
SELECT EmpName
FROM Employee
WHERE EmpName LIKE '%an';
```

**Result** (1 row)

| EmpName |
|---|
| Ali Khan |

### Task 9

**Requirement:** Job title contains 'Engineer' but the employee is NOT in Engineering.

```sql
SELECT EmpName, JobTitle, DeptName
FROM Employee
WHERE JobTitle LIKE '%Engineer%'
  AND DeptName != 'Engineering';

-- Verification: all Engineer titles
SELECT EmpName, JobTitle, DeptName
FROM Employee
WHERE JobTitle LIKE '%Engineer%';
```

**Result 1** (0 rows)

_Empty set (0 rows)._

**Result 2** (4 rows)

| EmpName | JobTitle | DeptName |
|---|---|---|
| Ali Khan | Senior Engineer | Engineering |
| Sara Iqbal | Software Engineer | Engineering |
| Hamza Raza | Software Engineer | Engineering |
| Adeel Akhtar | QA Engineer | Engineering |

**Note:** No rows returned: every job title containing "Engineer" belongs to the Engineering department. The second query confirms this.

### Task 10

**Requirement:** Names of employees who do not have a recorded city.

```sql
SELECT EmpName
FROM Employee
WHERE City IS NULL;
```

**Result** (2 rows)

| EmpName |
|---|
| Nida Yousaf |
| Imran Shafi |

**Note:** NULL is tested with IS NULL; City = NULL would return no rows.

### Task 11

**Requirement:** Employees with a recorded city, sorted alphabetically by city.

```sql
SELECT EmpName, City
FROM Employee
WHERE City IS NOT NULL
ORDER BY City ASC;
```

**Result** (13 rows)

| EmpName | City |
|---|---|
| Fatima Sheikh | Islamabad |
| Usman Tariq | Islamabad |
| Talha Hussain | Islamabad |
| Hamza Raza | Karachi |
| Ayesha Noor | Karachi |
| Bilal Ahmed | Karachi |
| Sana Malik | Karachi |
| Ali Khan | Lahore |
| Sara Iqbal | Lahore |
| Maira Javed | Lahore |
| Zain Abbas | Lahore |
| Adeel Akhtar | Lahore |
| Mehwish Anwar | Lahore |

### Task 12

**Requirement:** The 3 highest paid employees.

```sql
SELECT EmpName, Salary
FROM Employee
ORDER BY Salary DESC
LIMIT 3;
```

**Result** (3 rows)

| EmpName | Salary |
|---|---|
| Imran Shafi | 125000.00 |
| Ali Khan | 120000.00 |
| Maira Javed | 115000.00 |

### Task 13

**Requirement:** The 5 most recently hired employees.

```sql
SELECT EmpName, HireDate
FROM Employee
ORDER BY HireDate DESC
LIMIT 5;
```

**Result** (5 rows)

| EmpName | HireDate |
|---|---|
| Talha Hussain | 2023-07-18 |
| Zain Abbas | 2023-01-09 |
| Nida Yousaf | 2022-08-30 |
| Usman Tariq | 2022-02-18 |
| Mehwish Anwar | 2021-10-25 |

### Task 14

**Requirement:** Bottom 3 salaries in the company, lowest first.

```sql
SELECT EmpName, Salary
FROM Employee
ORDER BY Salary ASC
LIMIT 3;
```

**Result** (3 rows)

| EmpName | Salary |
|---|---|
| Zain Abbas | 60000.00 |
| Talha Hussain | 65000.00 |
| Bilal Ahmed | 70000.00 |

### Task 15

**Requirement:** All employees sorted by department ascending, then hire date ascending within each department.

```sql
SELECT EmpName, DeptName, HireDate
FROM Employee
ORDER BY DeptName ASC, HireDate ASC;
```

**Result** (15 rows)

| EmpName | DeptName | HireDate |
|---|---|---|
| Imran Shafi | Engineering | 2015-04-30 |
| Ali Khan | Engineering | 2018-03-15 |
| Sara Iqbal | Engineering | 2019-06-01 |
| Hamza Raza | Engineering | 2020-01-20 |
| Adeel Akhtar | Engineering | 2020-05-14 |
| Fatima Sheikh | Finance | 2019-09-12 |
| Usman Tariq | Finance | 2022-02-18 |
| Mehwish Anwar | HR | 2021-10-25 |
| Ayesha Noor | Marketing | 2017-11-10 |
| Bilal Ahmed | Marketing | 2021-04-05 |
| Maira Javed | Research | 2016-07-22 |
| Nida Yousaf | Research | 2022-08-30 |
| Zain Abbas | Research | 2023-01-09 |
| Sana Malik | Sales | 2018-12-01 |
| Talha Hussain | Sales | 2023-07-18 |

---

## 4. Summary

| Task | Concept | Rows returned |
|---|---|---|
| Task 1 | BETWEEN + ORDER BY | 6 |
| Task 2 | BETWEEN (dates) | 6 |
| Task 3 | NOT BETWEEN | 10 |
| Task 4 | IN + multi-column ORDER BY | 9 |
| Task 5 | NOT IN | 7 |
| Task 6 | LIKE (prefix) | 2 |
| Task 7 | LIKE (contains) | 15 |
| Task 8 | LIKE (suffix) | 1 |
| Task 9 | LIKE + AND | 0 / 4 |
| Task 10 | IS NULL | 2 |
| Task 11 | IS NOT NULL + ORDER BY | 13 |
| Task 12 | ORDER BY DESC + LIMIT | 3 |
| Task 13 | ORDER BY DESC + LIMIT | 5 |
| Task 14 | ORDER BY ASC + LIMIT | 3 |
| Task 15 | Multi-column ORDER BY | 15 |

## 5. Files

- `Lab07_Filters.sql` — database setup and all 15 tasks
