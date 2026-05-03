# Lab 03 — University Database & Keys Practice

## Quick Start
```sql
SOURCE lab03_university_database.sql;
```
Or open in **phpMyAdmin → SQL tab** and paste the file contents, then click **Go**.

---

## Database
```
university_db
```

## Tables Created
| Table | Primary Key | Notable Constraints |
|---|---|---|
| `departments` | `dept_id` | `dept_name` UNIQUE |
| `students` | `student_id` (Surrogate) | `email`, `cnic` UNIQUE · FK→departments |
| `courses` | `course_id` | FK→departments |
| `instructors` | `instructor_id` | `email` UNIQUE · FK→departments |
| `enrollments` | `(student_id, course_id)` — **Composite** | FK→students, courses |

---

## Key Types — Where to Find Them

| Key Type | Column | Table |
|---|---|---|
| **Primary Key** | `student_id` | students |
| **Surrogate Key** | `student_id` AUTO_INCREMENT | students |
| **Natural Key** | `cnic` | students |
| **Foreign Key** | `dept_id` | students → departments |
| **Unique Key** | `email`, `cnic` | students |
| **Composite Key** | `(student_id, course_id)` | enrollments |
| **Candidate Keys** | `student_id`, `email`, `cnic` | students |
| **Alternate Keys** | `email`, `cnic` | students (not chosen as PK) |
| **Super Keys** | `(student_id)`, `(email)`, `(student_id + name)`, … | students |

---

## SQL Commands Covered

| Command | Section in SQL file |
|---|---|
| `CREATE TABLE` | Section 1 |
| `ALTER TABLE` — Add / Modify / Rename / Drop column | Section 2 |
| `ADD CONSTRAINT` — PK / UQ / FK | Sections 1 & 2 |
| `INSERT` | Section 3 |
| `SELECT` + `JOIN` | Section 4 |
| `UPDATE` | Section 5 |
| `DELETE` | Section 6 |
| `TRUNCATE` | Section 7 |
| `DROP TABLE` | Section 8 |

---

## Sample Data
- **4** Departments · **10** Students · **8** Courses · **4** Instructors · **14** Enrollments

---

## Key Difference: TRUNCATE vs DELETE vs DROP
| Command | Removes Rows | Removes Table | Resets AUTO_INCREMENT |
|---|---|---|---|
| `DELETE` | ✅ (selective) | ❌ | ❌ |
| `TRUNCATE` | ✅ (all rows) | ❌ | ✅ |
| `DROP` | ✅ | ✅ | ✅ |

---

## Candidate vs Alternate vs Super Key
- **Candidate Key** → Any column that *could* be the Primary Key (`student_id`, `email`, `cnic`)
- **Primary Key** → The *chosen* Candidate Key (`student_id`)
- **Alternate Key** → Candidate keys *not chosen* as PK (`email`, `cnic`)
- **Super Key** → Any combination that uniquely identifies a row — includes and extends Candidate Keys
