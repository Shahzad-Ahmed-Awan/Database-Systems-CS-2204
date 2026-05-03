-- ============================================================
--  Lab 03 — University Database & Keys Practice
--  Subject  : Database Systems
--  Purpose  : Demonstrate all key types + complete SQL commands
-- ============================================================


-- ============================================================
-- SECTION 0: DATABASE SETUP
-- ============================================================

DROP DATABASE IF EXISTS university_db;
CREATE DATABASE university_db;
USE university_db;


-- ============================================================
-- SECTION 1: CREATE TABLES WITH CONSTRAINTS
-- ============================================================

-- ── 1.1  Departments  (Primary Key + Unique Key) ─────────────
CREATE TABLE departments (
    dept_id   INT          NOT NULL,
    dept_name VARCHAR(100) NOT NULL,
    location  VARCHAR(100),

    -- PRIMARY KEY: uniquely identifies each department
    CONSTRAINT pk_departments PRIMARY KEY (dept_id),

    -- UNIQUE KEY: dept_name must be unique across all rows
    CONSTRAINT uq_dept_name UNIQUE (dept_name)
);

-- ── 1.2  Students  (Surrogate Key + Natural Key + Foreign Key) ─
--
--  Key taxonomy for this table:
--    Surrogate Key  → student_id  (AUTO_INCREMENT, system-generated)
--    Natural Key    → cnic        (real-world unique attribute)
--    Candidate Keys → student_id, email, cnic  (all could be PK)
--    Primary Key    → student_id  (chosen candidate key)
--    Alternate Keys → email, cnic (candidate keys NOT chosen as PK)
--    Super Keys     → (student_id), (email), (cnic),
--                     (student_id + name), (email + dept_id), …
--    Foreign Key    → dept_id  references departments(dept_id)
--
CREATE TABLE students (
    student_id INT          NOT NULL AUTO_INCREMENT,  -- Surrogate Key
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(100) NOT NULL,
    cnic       VARCHAR(15)  NOT NULL,                 -- Natural Key
    age        INT,
    dept_id    INT,

    -- PRIMARY KEY (Surrogate Key chosen)
    CONSTRAINT pk_students PRIMARY KEY (student_id),

    -- UNIQUE / ALTERNATE KEYS (candidate keys not chosen as PK)
    CONSTRAINT uq_student_email UNIQUE (email),
    CONSTRAINT uq_student_cnic  UNIQUE (cnic),

    -- FOREIGN KEY → departments
    CONSTRAINT fk_student_dept
        FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ── 1.3  Courses  (Primary Key + Foreign Key) ────────────────
CREATE TABLE courses (
    course_id   INT          NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    credit_hrs  INT          DEFAULT 3,
    dept_id     INT,

    CONSTRAINT pk_courses PRIMARY KEY (course_id),

    CONSTRAINT fk_course_dept
        FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ── 1.4  Instructors  (Primary Key + Unique Key + Foreign Key) ─
CREATE TABLE instructors (
    instructor_id INT          NOT NULL,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL,
    dept_id       INT,

    CONSTRAINT pk_instructors PRIMARY KEY (instructor_id),
    CONSTRAINT uq_instructor_email UNIQUE (email),

    CONSTRAINT fk_instructor_dept
        FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ── 1.5  Enrollments  (Composite Key) ────────────────────────
--
--  COMPOSITE KEY: (student_id + course_id) together form the PK.
--  Neither column alone uniquely identifies a row — a student
--  can enroll in many courses, and a course can have many students.
--
CREATE TABLE enrollments (
    student_id INT         NOT NULL,
    course_id  INT         NOT NULL,
    semester   VARCHAR(20) NOT NULL,
    grade      CHAR(2)     DEFAULT NULL,

    -- COMPOSITE PRIMARY KEY
    CONSTRAINT pk_enrollments PRIMARY KEY (student_id, course_id),

    CONSTRAINT fk_enroll_student
        FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_enroll_course
        FOREIGN KEY (course_id)  REFERENCES courses(course_id)
        ON DELETE CASCADE
);


-- ============================================================
-- SECTION 2: ALTER TABLE OPERATIONS
-- ============================================================

-- Add a new column
ALTER TABLE students
    ADD COLUMN phone VARCHAR(20) AFTER email;

-- Modify a column (make age NOT NULL)
ALTER TABLE students
    MODIFY COLUMN age INT NOT NULL;

-- Rename a column (dept_name alias for display purposes)
ALTER TABLE departments
    CHANGE location campus VARCHAR(150);

-- Add a new column then drop it (demonstrates DROP COLUMN)
ALTER TABLE students
    ADD COLUMN temp_notes TEXT;

ALTER TABLE students
    DROP COLUMN temp_notes;

-- Add an extra unique constraint via ALTER
ALTER TABLE instructors
    ADD CONSTRAINT uq_instructor_name UNIQUE (name);


-- ============================================================
-- SECTION 3: INSERT DATA
-- ============================================================

-- Departments
INSERT INTO departments (dept_id, dept_name, campus) VALUES
(1, 'Computer Science',       'Main Campus'),
(2, 'Electrical Engineering', 'Main Campus'),
(3, 'Business Administration','City Campus'),
(4, 'Mathematics',            'Main Campus');

-- Students
INSERT INTO students (name, email, phone, cnic, age, dept_id) VALUES
('Ali Hassan',    'ali.hassan@uni.edu',    '0301-1234567', '35202-1234567-1', 20, 1),
('Sara Khan',     'sara.khan@uni.edu',     '0302-2345678', '35202-2345678-2', 21, 1),
('Ahmed Raza',    'ahmed.raza@uni.edu',    '0303-3456789', '35202-3456789-3', 22, 2),
('Fatima Malik',  'fatima.malik@uni.edu',  '0304-4567890', '35202-4567890-4', 20, 2),
('Usman Tariq',   'usman.tariq@uni.edu',   '0305-5678901', '35202-5678901-5', 23, 3),
('Ayesha Noor',   'ayesha.noor@uni.edu',   '0306-6789012', '35202-6789012-6', 21, 1),
('Bilal Saeed',   'bilal.saeed@uni.edu',   '0307-7890123', '35202-7890123-7', 22, 4),
('Zara Ahmed',    'zara.ahmed@uni.edu',    '0308-8901234', '35202-8901234-8', 20, 3),
('Omar Sheikh',   'omar.sheikh@uni.edu',   '0309-9012345', '35202-9012345-9', 24, 2),
('Hina Baig',     'hina.baig@uni.edu',     '0310-0123456', '35202-0123456-0', 21, 4);

-- Courses
INSERT INTO courses (course_id, course_name, credit_hrs, dept_id) VALUES
(101, 'Database Systems',        3, 1),
(102, 'Artificial Intelligence', 3, 1),
(103, 'Data Structures',         3, 1),
(201, 'Circuit Analysis',        3, 2),
(202, 'Digital Logic Design',    3, 2),
(301, 'Principles of Marketing', 3, 3),
(401, 'Linear Algebra',          3, 4),
(402, 'Calculus II',             3, 4);

-- Instructors
INSERT INTO instructors (instructor_id, name, email, dept_id) VALUES
(1, 'Dr. Kamran Ali',    'k.ali@uni.edu',     1),
(2, 'Dr. Sana Mirza',    's.mirza@uni.edu',   2),
(3, 'Prof. Tariq Rehman','t.rehman@uni.edu',  3),
(4, 'Dr. Amna Qureshi',  'a.qureshi@uni.edu', 4);

-- Enrollments (Composite Key in action)
INSERT INTO enrollments (student_id, course_id, semester, grade) VALUES
(1, 101, 'Fall 2025', 'A'),
(1, 102, 'Fall 2025', 'B+'),
(1, 103, 'Fall 2025', 'A-'),
(2, 101, 'Fall 2025', 'B'),
(2, 103, 'Fall 2025', 'A'),
(3, 201, 'Fall 2025', 'B+'),
(3, 202, 'Fall 2025', 'A'),
(4, 201, 'Fall 2025', 'A-'),
(5, 301, 'Fall 2025', 'B'),
(6, 101, 'Fall 2025', 'A'),
(7, 401, 'Fall 2025', 'B+'),
(8, 301, 'Fall 2025', 'A-'),
(9, 202, 'Fall 2025', 'B'),
(10,401, 'Fall 2025', 'A');


-- ============================================================
-- SECTION 4: SELECT QUERIES
-- ============================================================

-- View all tables
SELECT * FROM departments;
SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM instructors;
SELECT * FROM enrollments;

-- Students with their department names (INNER JOIN)
SELECT
    s.student_id,
    s.name        AS student_name,
    s.email,
    s.age,
    d.dept_name
FROM students s
INNER JOIN departments d ON s.dept_id = d.dept_id;

-- Courses a specific student is enrolled in (JOIN chain)
SELECT
    s.name        AS student_name,
    c.course_name,
    e.semester,
    e.grade
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses  c ON e.course_id  = c.course_id
WHERE s.name = 'Ali Hassan';

-- Count of students per department
SELECT
    d.dept_name,
    COUNT(s.student_id) AS total_students
FROM departments d
LEFT JOIN students s ON d.dept_id = s.dept_id
GROUP BY d.dept_name;

-- All enrollments with student and course details
SELECT
    s.name        AS student,
    c.course_name AS course,
    d.dept_name   AS department,
    e.semester,
    e.grade
FROM enrollments e
JOIN students    s ON e.student_id = s.student_id
JOIN courses     c ON e.course_id  = c.course_id
JOIN departments d ON c.dept_id    = d.dept_id
ORDER BY s.name, c.course_name;


-- ============================================================
-- SECTION 5: UPDATE OPERATIONS
-- ============================================================

-- Update a student's name
UPDATE students
SET name = 'Ali Hassan Khan'
WHERE student_id = 1;

-- Update a student's department
UPDATE students
SET dept_id = 4
WHERE student_id = 7;

-- Update a grade in enrollments
UPDATE enrollments
SET grade = 'A+'
WHERE student_id = 1 AND course_id = 101;

-- Verify updates
SELECT student_id, name, dept_id FROM students WHERE student_id IN (1, 7);
SELECT * FROM enrollments WHERE student_id = 1;


-- ============================================================
-- SECTION 6: DELETE OPERATIONS
-- ============================================================

-- Insert a temporary student to safely demonstrate DELETE
INSERT INTO students (name, email, phone, cnic, age, dept_id) VALUES
('Temp Student', 'temp@uni.edu', '0300-0000000', '00000-0000000-0', 18, 1);

-- Delete that temporary student
DELETE FROM students
WHERE email = 'temp@uni.edu';

-- Verify deletion
SELECT * FROM students;


-- ============================================================
-- SECTION 7: TRUNCATE  (clears all rows, keeps structure)
-- ============================================================

-- Create a demo table just for TRUNCATE demonstration
CREATE TABLE demo_truncate (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    info VARCHAR(50)
);

INSERT INTO demo_truncate (info) VALUES ('Row 1'), ('Row 2'), ('Row 3');
SELECT * FROM demo_truncate;   -- shows 3 rows

TRUNCATE TABLE demo_truncate;
SELECT * FROM demo_truncate;   -- shows 0 rows, table still exists

-- Clean up demo table
DROP TABLE demo_truncate;


-- ============================================================
-- SECTION 8: DROP TABLE (removes table entirely)
-- ============================================================

-- Create a temporary table and then drop it
CREATE TABLE temp_table (
    id   INT PRIMARY KEY,
    note VARCHAR(50)
);

DROP TABLE temp_table;         -- table is now completely gone


-- ============================================================
-- SECTION 9: KEY CONCEPTS SUMMARY (as SQL comments)
-- ============================================================
--
--  KEY TYPE        | COLUMN(S)                  | TABLE
--  ─────────────── | ─────────────────────────── | ──────────────
--  Primary Key     | student_id                 | students
--  Surrogate Key   | student_id (AUTO_INCREMENT)| students
--  Natural Key     | cnic                       | students
--  Foreign Key     | dept_id                    | students → departments
--  Unique Key      | email, cnic                | students
--  Composite Key   | (student_id, course_id)    | enrollments
--  Candidate Keys  | student_id, email, cnic    | students (all could be PK)
--  Alternate Keys  | email, cnic                | students (not chosen as PK)
--  Super Keys      | (student_id), (email),     | students
--                  | (student_id + name), …     |
--
-- ============================================================
-- END OF LAB 03
-- ============================================================
