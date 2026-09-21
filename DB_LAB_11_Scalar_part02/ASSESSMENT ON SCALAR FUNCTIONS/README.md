# Scalar Functions Assessment: Employee Database

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1?logo=mysql&logoColor=white)
![Topic](https://img.shields.io/badge/Topic-SCALAR%20FUNCTIONS-c0392b)
![Questions](https://img.shields.io/badge/Questions-Q1%20to%20Q10-success)
![Marks](https://img.shields.io/badge/Total%20Marks-100-orange)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | String, numeric, and date/time scalar functions combined |
| **Database** | `emp_lab` |
| **Table** | `Employee` |
| **Total marks** | 100 |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Answer ten graded questions (Q1 to Q10) that apply string, numeric, and date/time scalar functions to a single, deliberately messy `Employee` table.

## 2. Database Setup

### 2.1 Create and select database

```sql
CREATE DATABASE IF NOT EXISTS emp_lab;
USE emp_lab;

DROP TABLE IF EXISTS Employee;
```

Result: database `emp_lab` created and selected.

### 2.2 Create the table

```sql
CREATE TABLE Employee (
    EmpID    INT PRIMARY KEY,
    FullName VARCHAR(60) NOT NULL,
    Email    VARCHAR(80),
    Phone    VARCHAR(20),
    DOB      DATE,
    HireDate DATE,
    Salary   DECIMAL(10,2),
    City     VARCHAR(30),
    JobTitle VARCHAR(40)
);
```

### 2.3 Insert data

```sql
INSERT INTO Employee VALUES ( ... 10 rows ... );
```

Result: 10 employee rows inserted.

### 2.4 Verification

**Row count**

| Table | Rows |
|---|---|
| Employee | 10 |

**Deliberate gaps in the data**

```sql
SELECT EmpID, FullName FROM Employee WHERE Email IS NULL;
SELECT EmpID, FullName FROM Employee WHERE Phone IS NULL;
SELECT EmpID, FullName FROM Employee WHERE City  IS NULL;
```

| Gap | Row |
|---|---|
| No email | 2004 — Fatima Ali |
| No phone | 2005 — Hira Yousaf |
| No city | 2005 — Hira Yousaf |
| Leading/trailing space in name | 2001 — `' ahmad raza'`, 2006 — `'Zain Abbas '` |
| Mixed case name | 2003 — `BILAL KHAN` (upper), others normal case |

**Note on date-dependent results:** Q7, Q9, and Q10 depend on `CURDATE()`. All computed values below reflect **2026-09-19**, the date this report was generated.

---

## 3. Task Results

### Q1 (8 marks)

**Requirement:** Show each employee's name trimmed and in UPPERCASE, alongside the original.

```sql
SELECT EmpID,
       FullName AS OriginalName,
       UPPER(TRIM(FullName)) AS CleanedName
FROM Employee;
```

**Result** (10 rows)

| EmpID | OriginalName | CleanedName |
|---|---|---|
| 2001 | `' ahmad raza'` | AHMAD RAZA |
| 2002 | Sara Imran | SARA IMRAN |
| 2003 | BILAL KHAN | BILAL KHAN |
| 2004 | Fatima Ali | FATIMA ALI |
| 2005 | Hira Yousaf | HIRA YOUSAF |
| 2006 | `'Zain Abbas '` | ZAIN ABBAS |
| 2007 | Mehwish Anwar | MEHWISH ANWAR |
| 2008 | Talha Hussain | TALHA HUSSAIN |
| 2009 | Areeba Yasin | AREEBA YASIN |
| 2010 | Hassan Ahmed | HASSAN AHMED |

### Q2 (8 marks)

**Requirement:** For employees with a recorded email, extract the username (part before `@`).

```sql
SELECT FullName,
       SUBSTRING(Email, 1, LOCATE('@', Email) - 1) AS Username
FROM Employee
WHERE Email IS NOT NULL;
```

**Result** (9 rows)

| FullName | Username |
|---|---|
| ` ahmad raza` | ahmad |
| Sara Imran | SARA |
| BILAL KHAN | bilal |
| Hira Yousaf | hira |
| Zain Abbas | zain |
| Mehwish Anwar | mehwish |
| Talha Hussain | talha |
| Areeba Yasin | areeba |
| Hassan Ahmed | hassan |

**Note:** Fatima Ali (EmpID 2004) has a NULL email and is excluded.

### Q3 (8 marks)

**Requirement:** Mask each phone number — first 4 characters, then `'XXX-XXXX'`. Skip employees with no phone.

```sql
SELECT FullName,
       Phone,
       CONCAT(LEFT(Phone, 4), 'XXX-XXXX') AS MaskedPhone
FROM Employee
WHERE Phone IS NOT NULL;
```

**Result** (9 rows)

| FullName | Phone | MaskedPhone |
|---|---|---|
| ` ahmad raza` | 0300-1112233 | 0300XXX-XXXX |
| Sara Imran | 0301-4445566 | 0301XXX-XXXX |
| BILAL KHAN | 0302-7778899 | 0302XXX-XXXX |
| Fatima Ali | 0303-1234567 | 0303XXX-XXXX |
| Zain Abbas | 0305-3456789 | 0305XXX-XXXX |
| Mehwish Anwar | 0306-4567890 | 0306XXX-XXXX |
| Talha Hussain | 0307-5678901 | 0307XXX-XXXX |
| Areeba Yasin | 0308-6789012 | 0308XXX-XXXX |
| Hassan Ahmed | 0309-7890123 | 0309XXX-XXXX |

**Note:** Hira Yousaf (EmpID 2005) has a NULL phone and is correctly skipped.

### Q4 (12 marks)

**Requirement:** Generate a corporate email — lowercase the trimmed name, replace spaces with dots, then append `'@company.com'`.

```sql
SELECT FullName,
       CONCAT(LOWER(REPLACE(TRIM(FullName), ' ', '.')), '@company.com') AS GeneratedEmail
FROM Employee;
```

**Result** (10 rows)

| FullName | GeneratedEmail |
|---|---|
| ` ahmad raza` | ahmad.raza@company.com |
| Sara Imran | sara.imran@company.com |
| BILAL KHAN | bilal.khan@company.com |
| Fatima Ali | fatima.ali@company.com |
| Hira Yousaf | hira.yousaf@company.com |
| Zain Abbas | zain.abbas@company.com |
| Mehwish Anwar | mehwish.anwar@company.com |
| Talha Hussain | talha.hussain@company.com |
| Areeba Yasin | areeba.yasin@company.com |
| Hassan Ahmed | hassan.ahmed@company.com |

**Note:** This works for all 10 rows regardless of whether `Email` is NULL, since it's built entirely from `FullName`, not the existing `Email` column.

### Q5 (8 marks)

**Requirement:** Apply a 12.5% pay raise to every employee.

```sql
SELECT FullName,
       Salary,
       ROUND(Salary * 1.125, 2) AS NewSalary
FROM Employee;
```

**Result** (10 rows)

| FullName | Salary | NewSalary |
|---|---|---|
| ahmad raza | 120000.50 | 135000.56 |
| Sara Imran | 95000.00 | 106875.00 |
| BILAL KHAN | 85000.75 | 95625.84 |
| Fatima Ali | 110000.00 | 123750.00 |
| Hira Yousaf | 70000.00 | 78750.00 |
| Zain Abbas | 78000.40 | 87750.45 |
| Mehwish Anwar | 125000.00 | 140625.00 |
| Talha Hussain | 60000.00 | 67500.00 |
| Areeba Yasin | 90000.99 | 101251.11 |
| Hassan Ahmed | 65000.00 | 73125.00 |

### Q6 (8 marks)

**Requirement:** Round every salary down to the nearest thousand.

```sql
SELECT FullName,
       Salary,
       FLOOR(Salary / 1000) * 1000 AS RoundedSalary
FROM Employee;
```

**Result** (10 rows)

| FullName | Salary | RoundedSalary |
|---|---|---|
| ahmad raza | 120000.50 | 120000 |
| Sara Imran | 95000.00 | 95000 |
| BILAL KHAN | 85000.75 | 85000 |
| Fatima Ali | 110000.00 | 110000 |
| Hira Yousaf | 70000.00 | 70000 |
| Zain Abbas | 78000.40 | 78000 |
| Mehwish Anwar | 125000.00 | 125000 |
| Talha Hussain | 60000.00 | 60000 |
| Areeba Yasin | 90000.99 | 90000 |
| Hassan Ahmed | 65000.00 | 65000 |

**Note:** `FLOOR(x/1000)*1000` always rounds **down**, unlike `ROUND(x,-3)` which would round to the *nearest* thousand.

### Q7 (12 marks)

**Requirement:** Compute each employee's current age and years of service.

```sql
SELECT FullName,
       TIMESTAMPDIFF(YEAR, DOB, CURDATE()) AS AgeYears,
       TIMESTAMPDIFF(YEAR, HireDate, CURDATE()) AS YearsOfService
FROM Employee;
```

**Result as of 2026-09-19** (10 rows)

| FullName | AgeYears | YearsOfService |
|---|---|---|
| ahmad raza | 36 | 8 |
| Sara Imran | 33 | 7 |
| BILAL KHAN | 33 | 6 |
| Fatima Ali | 35 | 8 |
| Hira Yousaf | 31 | 5 |
| Zain Abbas | 31 | 4 |
| Mehwish Anwar | 36 | 10 |
| Talha Hussain | 30 | 3 |
| Areeba Yasin | 36 | 7 |
| Hassan Ahmed | 29 | 2 |

**Note:** Fatima Ali was hired on 2017-11-10; since today (Sep 19) falls before her November anniversary, her completed service is 8 years, not 9 — `TIMESTAMPDIFF` handles this automatically.

### Q8 (8 marks)

**Requirement:** Format every HireDate as `'DD-Mon-YYYY'`.

```sql
SELECT FullName,
       DATE_FORMAT(HireDate, '%d-%b-%Y') AS FormattedHireDate
FROM Employee;
```

**Result** (10 rows)

| FullName | FormattedHireDate |
|---|---|
| ahmad raza | 01-Sep-2018 |
| Sara Imran | 15-Mar-2019 |
| BILAL KHAN | 20-Jan-2020 |
| Fatima Ali | 10-Nov-2017 |
| Hira Yousaf | 05-Apr-2021 |
| Zain Abbas | 30-Aug-2022 |
| Mehwish Anwar | 22-Jul-2016 |
| Talha Hussain | 09-Jan-2023 |
| Areeba Yasin | 12-Sep-2019 |
| Hassan Ahmed | 18-Feb-2024 |

### Q9 (8 marks)

**Requirement:** List employees hired in the year 2019 or later, using a date function rather than `BETWEEN`.

```sql
SELECT FullName, HireDate
FROM Employee
WHERE YEAR(HireDate) >= 2019;
```

**Result** (7 rows)

| FullName | HireDate |
|---|---|
| Sara Imran | 2019-03-15 |
| BILAL KHAN | 2020-01-20 |
| Hira Yousaf | 2021-04-05 |
| Zain Abbas | 2022-08-30 |
| Talha Hussain | 2023-01-09 |
| Areeba Yasin | 2019-09-12 |
| Hassan Ahmed | 2024-02-18 |

**Note:** ahmad raza (2018), Fatima Ali (2017), and Mehwish Anwar (2016) are excluded — all hired before 2019.

### Q10 (20 marks)

**Requirement:** Combined challenge — one `Profile` column: `'AHMAD RAZA | Lahore | Senior Engineer | Joined: 01-Sep-2018 | Age: 36'`.

```sql
SELECT CONCAT(
           UPPER(TRIM(FullName)), ' | ',
           City, ' | ',
           JobTitle, ' | Joined: ',
           DATE_FORMAT(HireDate, '%d-%b-%Y'), ' | Age: ',
           TIMESTAMPDIFF(YEAR, DOB, CURDATE())
       ) AS Profile
FROM Employee;
```

**Result as of 2026-09-19** (10 rows)

| Profile |
|---|
| AHMAD RAZA \| Lahore \| Senior Engineer \| Joined: 01-Sep-2018 \| Age: 36 |
| SARA IMRAN \| Karachi \| Software Engineer \| Joined: 15-Mar-2019 \| Age: 33 |
| BILAL KHAN \| Lahore \| QA Engineer \| Joined: 20-Jan-2020 \| Age: 33 |
| FATIMA ALI \| Islamabad \| Manager \| Joined: 10-Nov-2017 \| Age: 35 |
| **NULL** |
| ZAIN ABBAS \| Karachi \| Designer \| Joined: 30-Aug-2022 \| Age: 31 |
| MEHWISH ANWAR \| Lahore \| Director \| Joined: 22-Jul-2016 \| Age: 36 |
| TALHA HUSSAIN \| Islamabad \| HR Officer \| Joined: 09-Jan-2023 \| Age: 30 |
| AREEBA YASIN \| Lahore \| Analyst \| Joined: 12-Sep-2019 \| Age: 36 |
| HASSAN AHMED \| Karachi \| Junior Developer \| Joined: 18-Feb-2024 \| Age: 29 |

**Note — the `CONCAT` + NULL trap:** Hira Yousaf (EmpID 2005) has a NULL `City`. `CONCAT` returns NULL the moment **any** argument is NULL, so her entire `Profile` comes out as NULL rather than a partial string. Wrapping the nullable column in `COALESCE(City, 'Unknown')` would produce a readable row instead — worth mentioning as a follow-up improvement if the instructor asks.

---

## 4. Summary

| Question | Concept | Rows | Marks |
|---|---|---|---|
| Q1 | TRIM + UPPER | 10 | 8 |
| Q2 | SUBSTRING + LOCATE + WHERE IS NOT NULL | 9 | 8 |
| Q3 | CONCAT + LEFT + WHERE IS NOT NULL | 9 | 8 |
| Q4 | LOWER + REPLACE + TRIM + CONCAT (nesting) | 10 | 12 |
| Q5 | ROUND (percentage increase) | 10 | 8 |
| Q6 | FLOOR (round down) | 10 | 8 |
| Q7 | TIMESTAMPDIFF (age + tenure) | 10 | 12 |
| Q8 | DATE_FORMAT | 10 | 8 |
| Q9 | YEAR + WHERE | 7 | 8 |
| Q10 | CONCAT + UPPER + TRIM + DATE_FORMAT + TIMESTAMPDIFF | 10 (1 NULL) | 20 |
| **Total** | | | **100** |

## 5. Key Takeaways

- `CONCAT` returns NULL the instant any one argument is NULL — a nullable column feeding a combined-summary query (Q10) can silently blank out an entire row unless guarded with `COALESCE`.
- `FLOOR(x/n)*n` rounds **down** to a step of `n`; `ROUND(x, -k)` rounds to the **nearest** step instead — the two are easy to conflate.
- Deriving a new value from a column (Q4's generated email) sidesteps NULLs in a *different* column (the existing `Email`), since the derivation never touches it.
- `TIMESTAMPDIFF(YEAR, ...)` is the reliable way to compute both ages and tenure — it accounts for whether the anniversary date has occurred yet this year.
- A date function (`YEAR(d) >= 2019`) is often clearer and less error-prone than `BETWEEN` when the lower bound is open-ended.

## 6. Files

- `RollNo_Assessment_ScalarFunctions.sql` — setup script and Q1 to Q10
