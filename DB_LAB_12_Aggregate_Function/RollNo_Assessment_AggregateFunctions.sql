-- ============================================================
-- Assessment Problem: Aggregate Functions - University Database
-- Name: Shahzad Ahmed Awan    Roll No: 2024-SE-15
-- Submitted to: Sir Awais Rathore
-- ============================================================

-- Setup script
CREATE DATABASE IF NOT EXISTS uni_lab;
USE uni_lab;

DROP TABLE IF EXISTS Enrollment, Course, Student;

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

INSERT INTO Student VALUES
(1001, 'Ahmad Raza', 'Lahore', '2022-09-01'),
(1002, 'Sara Imran', 'Karachi', '2022-09-01'),
(1003, 'Bilal Khan', 'Lahore', '2023-09-01'),
(1004, 'Fatima Ali', 'Islamabad', '2022-09-01'),
(1005, 'Hira Yousaf', NULL, '2024-09-01'),
(1006, 'Zain Abbas', 'Karachi', '2023-09-01'),
(1007, 'Mehwish Anwar', 'Lahore', '2022-09-01'),
(1008, 'Talha Hussain', 'Islamabad', '2024-09-01'),
(1009, 'Areeba Yasin', 'Lahore', '2023-09-01');

INSERT INTO Course VALUES
('CS101','Intro to Programming', 'Computer Science', 3, 25000),
('CS201','Database Systems', 'Computer Science', 3, 28000),
('CS301','Operating Systems', 'Computer Science', 4, 30000),
('MT101','Calculus I', 'Mathematics', 3, 22000),
('EE201','Digital Logic', 'Electrical Engg', 3, 26000),
('BB301','Marketing Basics', 'Business', 3, 24000);

INSERT INTO Enrollment VALUES
(1, 1001,'CS101', 78, '2022-09-15'),
(2, 1001,'CS201', 85, '2023-09-15'),
(3, 1001,'MT101', 90, '2022-09-15'),
(4, 1002,'CS101', 65, '2022-09-15'),
(5, 1002,'CS201', 72, '2023-09-15'),
(6, 1003,'CS101', 88, '2023-09-15'),
(7, 1003,'EE201', 80, '2023-09-15'),
(8, 1004,'MT101', 95, '2022-09-15'),
(9, 1004,'CS201', 70, '2023-09-15'),
(10,1005,'CS101', 55, '2024-09-15'),
(11,1006,'CS101', 82, '2023-09-15'),
(12,1006,'CS301', 76, '2024-09-15'),
(13,1007,'CS201', 91, '2023-09-15'),
(14,1007,'CS301', 86, '2024-09-15'),
(15,1008,'CS101', 60, '2024-09-15'),
(16,1008,'MT101', 68, '2024-09-15');


-- Q1: How many students and how many courses are there?
SELECT
    (SELECT COUNT(*) FROM Student) AS TotalStudents,
    (SELECT COUNT(*) FROM Course)  AS TotalCourses;

-- Q2: Distinct cities students come from (ignoring NULL)
SELECT COUNT(DISTINCT City) AS DistinctCities
FROM Student;

-- Q3: Average, minimum, and maximum Marks across all enrollments
SELECT ROUND(AVG(Marks), 2) AS AvgMarks,
       MIN(Marks) AS MinMarks,
       MAX(Marks) AS MaxMarks
FROM Enrollment;

-- Q4: Number of students in each city, sorted by count descending, NULL-city group last
SELECT City, COUNT(*) AS NumStudents
FROM Student
GROUP BY City
ORDER BY (City IS NULL), NumStudents DESC;

-- Q5: Number of courses offered by each department, sorted by count descending
SELECT Department, COUNT(*) AS NumCourses
FROM Course
GROUP BY Department
ORDER BY NumCourses DESC;

-- Q6: For each course, number of students enrolled and average marks, sorted by avg marks descending
SELECT c.CourseName,
       COUNT(e.EnrollID) AS NumStudents,
       ROUND(AVG(e.Marks), 2) AS AvgMarks
FROM Course c
JOIN Enrollment e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName
ORDER BY AvgMarks DESC;

-- Q7: Courses with an average marks above 80
SELECT c.CourseName,
       ROUND(AVG(e.Marks), 2) AS AvgMarks
FROM Course c
JOIN Enrollment e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName
HAVING AVG(e.Marks) > 80;

-- Q8: Total fee revenue per department (each enrolled student paid the course fee)
SELECT c.Department,
       SUM(c.Fee) AS TotalRevenue
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
JOIN Course c     ON e.CourseID = c.CourseID
GROUP BY c.Department
ORDER BY TotalRevenue DESC;

-- Q9: For each student, number of courses enrolled and average marks, including students with no enrollments
SELECT s.FullName,
       COUNT(e.EnrollID) AS NumCourses,
       ROUND(AVG(e.Marks), 2) AS AvgMarks
FROM Student s
LEFT JOIN Enrollment e ON s.StudentID = e.StudentID
GROUP BY s.StudentID, s.FullName;

-- Q10: Students who scored above 85 in at least one course, with their highest mark
SELECT s.FullName,
       MAX(e.Marks) AS HighestMark
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
GROUP BY s.StudentID, s.FullName
HAVING MAX(e.Marks) > 85;

-- Q11: Departments where the average marks across all their courses is below 75
SELECT c.Department,
       ROUND(AVG(e.Marks), 2) AS OverallAvgMarks
FROM Enrollment e
JOIN Course c ON e.CourseID = c.CourseID
GROUP BY c.Department
HAVING AVG(e.Marks) < 75;

-- Q12: Top 3 students by total fee they have paid
SELECT s.FullName,
       SUM(c.Fee) AS TotalFee
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
JOIN Course c     ON e.CourseID = c.CourseID
GROUP BY s.StudentID, s.FullName
ORDER BY TotalFee DESC
LIMIT 3;
