# Aggregate Functions Assessment: University Database

![DBMS](https://img.shields.io/badge/DBMS-MySQL%208.x-4479A1)
![Topic](https://img.shields.io/badge/Topic-AGGREGATES-0aa)
![Questions](https://img.shields.io/badge/Questions-Q1%20to%20Q12-success)
![Marks](https://img.shields.io/badge/Total%20Marks-100-orange)

| | |
|---|---|
| **Course** | Database Systems |
| **DBMS** | MySQL 8.x |
| **Topic** | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING`, joins with aggregates |
| **Database** | `uni_lab` |
| **Tables** | `Student`, `Course`, `Enrollment` |
| **Total marks** | 100 |
| **Name** | Shahzad Ahmed Awan |
| **Roll No** | 2024-SE-15 |
| **Submitted to** | Sir Awais Rathore |

---

## 1. Objective

Answer twelve graded aggregate queries (Q1 to Q12) on a small university database of students, courses, and enrollments.

## 2. Database Setup

### 2.1 Create and select database

```sql
CREATE DATABASE IF NOT EXISTS uni_lab;
USE uni_lab;

DROP TABLE IF EXISTS Enrollment, Course, Student;
```

Result: database `uni_lab` created and selected.

### 2.2 Create the three tables

```sql
CREATE TABLE Student (
    StudentID  INT PRIMARY KEY,
    FullName   VARCHAR(60) NOT NULL,
    City       VARCHAR(30),
    EnrollDate DATE
);

CREATE TABLE Course (
    CourseID    VARCHAR(10) PRIMARY KEY,
    CourseName  VARCHAR(60) NOT NULL,
    Department  VARCHAR(30),
    Credits     INT,
    Fee         DECIMAL(10,2)
);

CREATE TABLE Enrollment (
    EnrollID       INT PRIMARY KEY,
    StudentID      INT,
    CourseID       VARCHAR(10),
    Marks          INT,
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID)  REFERENCES Course(CourseID)
);
```

**Schema summary**

| Table | Key columns | Links to |
|---|---|---|
| Student | `StudentID` (PK) | — |
| Course | `CourseID` (PK) | — |
| Enrollment | `EnrollID` (PK) | `StudentID` → Student, `CourseID` → Course |

```
Student 1 ── * Enrollment * ── 1 Course
```

### 2.3 Insert data

```sql
INSERT INTO Student    VALUES ( ... 9 rows ... );
INSERT INTO Course     VALUES ( ... 6 rows ... );
INSERT INTO Enrollment VALUES ( ... 16 rows ... );
```

Result: 9 + 6 + 16 rows inserted.

### 2.4 Verification

**Row counts**

| Table | Rows |
|---|---|
| Student | 9 |
| Course | 6 |
| Enrollment | 16 |

**Deliberate gaps in the data**

```sql
SELECT FullName FROM Student WHERE City IS NULL;

SELECT s.FullName
FROM Student s
LEFT JOIN Enrollment e ON s.StudentID = e.StudentID
WHERE e.StudentID IS NULL;

SELECT c.CourseName
FROM Course c
LEFT JOIN Enrollment e ON c.CourseID = e.CourseID
WHERE e.CourseID IS NULL;
```

| Gap | Row(s) |
|---|---|
| Student with no city | Hira Yousaf (1005) |
| Student with no enrollments | Areeba Yasin (1009) |
| Course with no enrollments | BB301 — Marketing Basics |

These three gaps are what make `LEFT JOIN` vs `INNER JOIN` matter throughout this assessment — several questions return different row counts depending on which one is used.

---

## 3. Task Results

### Q1 (5 marks)

**Requirement:** How many students and how many courses are there?

```sql
SELECT
    (SELECT COUNT(*) FROM Student) AS TotalStudents,
    (SELECT COUNT(*) FROM Course)  AS TotalCourses;
```

**Result** (1 row)

| TotalStudents | TotalCourses |
|---|---|
| 9 | 6 |

### Q2 (5 marks)

**Requirement:** Distinct cities students come from, ignoring NULL.

```sql
SELECT COUNT(DISTINCT City) AS DistinctCities
FROM Student;
```

**Result** (1 row)

| DistinctCities |
|---|
| 3 |

**Note:** `COUNT(DISTINCT City)` drops Hira Yousaf's NULL city on its own, no extra `WHERE` needed.

### Q3 (10 marks)

**Requirement:** Average, minimum, and maximum Marks across all enrollments.

```sql
SELECT ROUND(AVG(Marks), 2) AS AvgMarks,
       MIN(Marks) AS MinMarks,
       MAX(Marks) AS MaxMarks
FROM Enrollment;
```

**Result** (1 row)

| AvgMarks | MinMarks | MaxMarks |
|---|---|---|
| 77.56 | 55 | 95 |

### Q4 (10 marks)

**Requirement:** Number of students in each city, sorted by count descending, NULL-city group last.

```sql
SELECT City, COUNT(*) AS NumStudents
FROM Student
GROUP BY City
ORDER BY (City IS NULL), NumStudents DESC;
```

**Result** (4 rows)

| City | NumStudents |
|---|---|
| Lahore | 4 |
| Karachi | 2 |
| Islamabad | 2 |
| NULL | 1 |

**Note:** `(City IS NULL)` evaluates to `0` for a real city and `1` for NULL. Sorting by that expression first pushes every NULL group to the bottom regardless of its count, and `NumStudents DESC` only then breaks ties among the real cities.

### Q5 (5 marks)

**Requirement:** Number of courses offered by each department, sorted by count descending.

```sql
SELECT Department, COUNT(*) AS NumCourses
FROM Course
GROUP BY Department
ORDER BY NumCourses DESC;
```

**Result** (4 rows)

| Department | NumCourses |
|---|---|
| Computer Science | 3 |
| Mathematics | 1 |
| Electrical Engg | 1 |
| Business | 1 |

### Q6 (15 marks)

**Requirement:** For each course, number of students enrolled and average marks, sorted by average marks descending.

```sql
SELECT c.CourseName,
       COUNT(e.EnrollID) AS NumStudents,
       ROUND(AVG(e.Marks), 2) AS AvgMarks
FROM Course c
JOIN Enrollment e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName
ORDER BY AvgMarks DESC;
```

**Result** (5 rows)

| CourseName | NumStudents | AvgMarks |
|---|---|---|
| Calculus I | 3 | 84.33 |
| Operating Systems | 2 | 81.00 |
| Digital Logic | 1 | 80.00 |
| Database Systems | 4 | 79.50 |
| Intro to Programming | 6 | 71.33 |

**Note:** Only 5 of the 6 courses appear. `Marketing Basics` (BB301) has zero enrollments, and an `INNER JOIN` to `Enrollment` drops any course with nothing to match — a `LEFT JOIN` would be needed to keep it visible with `NumStudents = 0` and `AvgMarks = NULL`.

### Q7 (5 marks)

**Requirement:** Courses with an average marks above 80.

```sql
SELECT c.CourseName,
       ROUND(AVG(e.Marks), 2) AS AvgMarks
FROM Course c
JOIN Enrollment e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName
HAVING AVG(e.Marks) > 80;
```

**Result** (2 rows)

| CourseName | AvgMarks |
|---|---|
| Calculus I | 84.33 |
| Operating Systems | 81.00 |

**Note:** `Digital Logic` sits exactly at 80.00 in Q6 and is correctly excluded by a strict `> 80`.

### Q8 (10 marks)

**Requirement:** Total fee revenue per department (each enrolled student paid the course fee).

```sql
SELECT c.Department,
       SUM(c.Fee) AS TotalRevenue
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
JOIN Course c     ON e.CourseID = c.CourseID
GROUP BY c.Department
ORDER BY TotalRevenue DESC;
```

**Result** (3 rows)

| Department | TotalRevenue |
|---|---|
| Computer Science | 322000.00 |
| Mathematics | 66000.00 |
| Electrical Engg | 26000.00 |

**Note:** `SUM(c.Fee)` adds one course fee per *enrollment* row, so a course's fee is counted once for every student in it (e.g. `Intro to Programming` at 25,000 × 6 students = 150,000 of the Computer Science total). `Business` doesn't appear — `Marketing Basics` has no enrollments to join through.

### Q9 (10 marks)

**Requirement:** For each student, number of courses enrolled and average marks, including students with no enrollments.

```sql
SELECT s.FullName,
       COUNT(e.EnrollID) AS NumCourses,
       ROUND(AVG(e.Marks), 2) AS AvgMarks
FROM Student s
LEFT JOIN Enrollment e ON s.StudentID = e.StudentID
GROUP BY s.StudentID, s.FullName;
```

**Result** (9 rows)

| FullName | NumCourses | AvgMarks |
|---|---|---|
| Ahmad Raza | 3 | 84.33 |
| Sara Imran | 2 | 68.50 |
| Bilal Khan | 2 | 84.00 |
| Fatima Ali | 2 | 82.50 |
| Hira Yousaf | 1 | 55.00 |
| Zain Abbas | 2 | 79.00 |
| Mehwish Anwar | 2 | 88.50 |
| Talha Hussain | 2 | 64.00 |
| Areeba Yasin | 0 | NULL |

**Note:** `LEFT JOIN` keeps Areeba Yasin, who has never enrolled in anything — `COUNT(e.EnrollID)` correctly reports `0` for her, while `AVG(e.Marks)` correctly reports `NULL` rather than `0`, since there are no marks to average.

### Q10 (10 marks)

**Requirement:** Students who scored above 85 in at least one course, with their highest mark.

```sql
SELECT s.FullName,
       MAX(e.Marks) AS HighestMark
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
GROUP BY s.StudentID, s.FullName
HAVING MAX(e.Marks) > 85;
```

**Result** (4 rows)

| FullName | HighestMark |
|---|---|
| Ahmad Raza | 90 |
| Bilal Khan | 88 |
| Fatima Ali | 95 |
| Mehwish Anwar | 91 |

**Note:** Zain Abbas peaks at 82 and Talha Hussain at 68 — both under the 85 bar, so neither appears. `HAVING MAX(...)` filters on the aggregate per student, not on any single enrollment row.

### Q11 (10 marks)

**Requirement:** Departments where the average marks across all their courses is below 75.

```sql
SELECT c.Department,
       ROUND(AVG(e.Marks), 2) AS OverallAvgMarks
FROM Enrollment e
JOIN Course c ON e.CourseID = c.CourseID
GROUP BY c.Department
HAVING AVG(e.Marks) < 75;
```

**Result** (0 rows)

_Empty set (0 rows)._

**Verification** — the actual overall average per department (from all matching enrollments):

| Department | OverallAvgMarks | Below 75? |
|---|---|---|
| Computer Science | 75.67 | No |
| Mathematics | 84.33 | No |
| Electrical Engg | 80.00 | No |
| Business | — (no enrollments, not in result) | — |

**Note:** The empty set is the correct answer, not a mistake — every department with at least one enrollment clears 75 comfortably. `Business` never enters the calculation at all, since `Marketing Basics` has no `Enrollment` rows for the `JOIN` to match.

### Q12 (5 marks)

**Requirement:** Top 3 students by total fee they have paid.

```sql
SELECT s.FullName,
       SUM(c.Fee) AS TotalFee
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
JOIN Course c     ON e.CourseID = c.CourseID
GROUP BY s.StudentID, s.FullName
ORDER BY TotalFee DESC
LIMIT 3;
```

**Result** (3 rows)

| FullName | TotalFee |
|---|---|
| Ahmad Raza | 75000.00 |
| Mehwish Anwar | 58000.00 |
| Zain Abbas | 55000.00 |

**Note:** "Total fee paid" sums the fee of every course a student is enrolled in — it rewards being enrolled in several courses (Ahmad Raza, 3 courses) or in expensive ones (Mehwish Anwar's two courses total 58,000), not high marks.

---

## 4. Summary

| Question | Concept | Rows | Marks |
|---|---|---|---|
| Q1 | COUNT(*) via scalar subqueries | 1 | 5 |
| Q2 | COUNT(DISTINCT) | 1 | 5 |
| Q3 | AVG, MIN, MAX | 1 | 10 |
| Q4 | GROUP BY + custom ORDER BY expression | 4 | 10 |
| Q5 | GROUP BY + ORDER BY | 4 | 5 |
| Q6 | INNER JOIN + GROUP BY + 2 aggregates | 5 | 15 |
| Q7 | HAVING on AVG | 2 | 5 |
| Q8 | Multi-table JOIN + SUM | 3 | 10 |
| Q9 | LEFT JOIN + COUNT + AVG | 9 | 10 |
| Q10 | JOIN + HAVING on MAX | 4 | 10 |
| Q11 | JOIN + HAVING on AVG | 0 | 10 |
| Q12 | JOIN + ORDER BY + LIMIT | 3 | 5 |
| **Total** | | | **100** |

## 5. Key Takeaways

- `COUNT(DISTINCT column)` and every other aggregate function ignore NULLs by default — no extra filtering required (Q2).
- Sorting NULL groups to a specific position, not just first or last by default, takes a boolean expression like `(City IS NULL)` as the first `ORDER BY` key (Q4).
- `INNER JOIN` silently excludes an entity with zero matching child rows from a `GROUP BY` result — Marketing Basics vanishes from Q6, Q7, and Q8 for exactly this reason; `LEFT JOIN` is the fix when that entity must still be shown (Q9).
- `HAVING` filters on the *aggregate value itself* (`MAX(Marks)`, `AVG(Marks)`), never on an individual row's raw value.
- An empty result set from a `HAVING` query is a legitimate, gradeable answer — Q11 shows the right way to prove it's correct: compute the aggregate for every group and show none satisfies the condition.

## 6. Files

- `RollNo_Assessment_AggregateFunctions.sql` — setup script and Q1 to Q12
