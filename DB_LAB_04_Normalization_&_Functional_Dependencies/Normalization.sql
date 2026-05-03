-- =====================================================
-- RollNo_2024-SE-15_Normalization.sql
-- Course  : Database Systems
-- Lab     : Normalization (1NF, 2NF, 3NF)
-- Scenario: Hospital Patient Visits
-- =====================================================


CREATE DATABASE IF NOT EXISTS hospital_normalization;
USE hospital_normalization;


-- =====================================================
-- STAGE 0 : UNNORMALIZED FORM (UNF)
-- =====================================================
-- A table is in UNF when it breaks the basic rules:
--   - Cells contain multiple values (non-atomic)
--   - Repeating groups of columns exist
--   - No clear primary key
--   - High data redundancy
--   - Insert / Update / Delete anomalies exist
--
-- Below the raw hospital data is stored exactly the
-- way a non-technical person might first record it
-- in a spreadsheet -- all information crammed together.
--
-- Notice:
--   * BookedDates column holds MULTIPLE visit dates
--     for the same patient in one cell  (non-atomic)
--   * Diagnosis1, Diagnosis2 are REPEATING GROUPS
--     (same type of data split across columns)
--   * DoctorInfo stores name + specialty together
--     in one cell  (nested / complex attribute)
--   * No PRIMARY KEY is defined
--   * Same patient info repeats across rows
-- =====================================================

DROP TABLE IF EXISTS Hospital_UNF;

CREATE TABLE Hospital_UNF (
    VisitID      VARCHAR(20),
    BookedDates  VARCHAR(100),
    PatientInfo  VARCHAR(100),
    DoctorInfo   VARCHAR(100),
    DeptInfo     VARCHAR(100),
    Diagnosis1   VARCHAR(50),
    Diagnosis2   VARCHAR(50),
    Fee1         INT,
    Fee2         INT
);

INSERT INTO Hospital_UNF VALUES
('V-9001, V-9003', '2026-04-10, 2026-04-11', 'Hassan / 0300-1112233',  'Dr. Imran / Cardiology',  'Heart Care / Dr. Tariq', 'Hypertension', 'Allergy',  2500, 2000),
('V-9002',         '2026-04-10',              'Mehreen / 0301-4445566', 'Dr. Asma / Dermatology',  'Skin Clinic / Dr. Asma', 'Eczema',       NULL,       2000, NULL),
('V-9004',         '2026-04-12',              'Junaid / 0302-7778899',  'Dr. Imran / Cardiology',  'Heart Care / Dr. Tariq', 'Arrhythmia',   NULL,       3000, NULL);

-- Anomalies in this UNF table:
--
-- INSERT ANOMALY:
--   Cannot add a new doctor (e.g. Dr. Zara, Neurology)
--   without having a patient visit for her. She has no
--   row to live in since doctor data is mixed with visits.
--
-- UPDATE ANOMALY:
--   If Dr. Imran changes his specialty, we must find
--   and update every row containing his name inside
--   the DoctorInfo text. Missing one = inconsistency.
--
-- DELETE ANOMALY:
--   Deleting Junaid row (V-9004) destroys the only copy
--   of Dr. Imran being a Cardiologist in Heart Care.

SELECT '=== UNF: Raw unnormalized data (non-atomic cells + repeating groups) ===' AS '';
SELECT * FROM Hospital_UNF;


-- =====================================================
-- STAGE 1 : FIRST NORMAL FORM (1NF)
-- =====================================================
-- Rules to satisfy 1NF:
--   1. Every cell must hold ONE atomic (single) value
--   2. No repeating groups of columns
--   3. Each row must be uniquely identifiable (PRIMARY KEY)
--
-- Changes made from UNF:
--   * BookedDates split -- each visit gets its OWN row
--   * PatientInfo split into PatientID, PatientName,
--     PatientPhone  (one value per cell, not combined)
--   * DoctorInfo split into DoctorID, DoctorName,
--     Specialty  (one value per cell, not combined)
--   * DeptInfo split into DeptName, DeptHead
--   * Diagnosis1 + Diagnosis2 repeating groups removed
--     -- each visit row has exactly one Diagnosis column
--   * Fee1 + Fee2 repeating groups removed
--     -- each visit row has exactly one Fee column
--   * PRIMARY KEY (VisitID) declared
-- =====================================================

DROP TABLE IF EXISTS Hospital_1NF;

CREATE TABLE Hospital_1NF (
    VisitID      VARCHAR(10)  NOT NULL,
    VisitDate    DATE         NOT NULL,
    PatientID    VARCHAR(10)  NOT NULL,
    PatientName  VARCHAR(50)  NOT NULL,
    PatientPhone VARCHAR(20),
    DoctorID     VARCHAR(10)  NOT NULL,
    DoctorName   VARCHAR(50)  NOT NULL,
    Specialty    VARCHAR(50),
    DeptName     VARCHAR(50),
    DeptHead     VARCHAR(50),
    Diagnosis    VARCHAR(100),
    Fee          INT,
    PRIMARY KEY (VisitID)
);

INSERT INTO Hospital_1NF VALUES
('V-9001','2026-04-10','P-201','Hassan', '0300-1112233','D-30','Dr. Imran','Cardiology', 'Heart Care', 'Dr. Tariq','Hypertension',2500),
('V-9002','2026-04-10','P-202','Mehreen','0301-4445566','D-31','Dr. Asma', 'Dermatology','Skin Clinic','Dr. Asma',  'Eczema',      2000),
('V-9003','2026-04-11','P-201','Hassan', '0300-1112233','D-31','Dr. Asma', 'Dermatology','Skin Clinic','Dr. Asma',  'Allergy',     2000),
('V-9004','2026-04-12','P-203','Junaid', '0302-7778899','D-30','Dr. Imran','Cardiology', 'Heart Care', 'Dr. Tariq','Arrhythmia',  3000);

-- Still not perfect. Problems remaining after 1NF:
--   Hassan name/phone repeat in V-9001 and V-9003
--   Dr. Imran info repeats in V-9001 and V-9004
--   Heart Care / Dr. Tariq repeats in V-9001 and V-9004
-- These are TRANSITIVE DEPENDENCIES that 3NF will fix.

SELECT '=== 1NF: Atomic values, no repeating groups, PK declared ===' AS '';
SELECT * FROM Hospital_1NF;


-- =====================================================
-- FUNCTIONAL DEPENDENCIES FOUND IN 1NF
-- =====================================================
--
-- FD1:  VisitID   --> VisitDate, PatientID,
--                     DoctorID, Diagnosis, Fee
--
-- FD2:  PatientID --> PatientName, PatientPhone
--       (name and phone describe the PATIENT,
--        not the visit -- transitive via PatientID)
--
-- FD3:  DoctorID  --> DoctorName, Specialty, DeptName
--       (these describe the DOCTOR, not the visit
--        -- transitive via DoctorID)
--
-- FD4:  DeptName  --> DeptHead
--       (DeptHead describes the DEPARTMENT, not the
--        doctor -- transitive via DeptName)
--
-- Transitive chains to break for 3NF:
--   VisitID --> PatientID --> PatientName, PatientPhone
--   VisitID --> DoctorID  --> DoctorName, Specialty, DeptName
--   VisitID --> DoctorID  --> DeptName --> DeptHead
--
-- Candidate Key: VisitID
--   Single column, uniquely identifies every row.
-- =====================================================


-- =====================================================
-- STAGE 2 : SECOND NORMAL FORM (2NF)
-- =====================================================
-- Rule: Must be in 1NF AND no PARTIAL DEPENDENCY.
-- Partial dependency = a non-key column depends on
-- only PART of a composite (multi-column) primary key.
--
-- Analysis:
--   Our primary key is VisitID -- just ONE column.
--   A partial dependency can only exist when the PK
--   has TWO OR MORE columns combined. Since our key
--   has only one column, no partial subset of it
--   exists, so partial dependencies are impossible.
--
-- Result: Hospital_1NF is already in 2NF.
--
-- We still create Hospital_2NF explicitly below to
-- show the stage in the schema and add the indexes
-- that prepare the table for eventual decomposition.
-- The remaining problems are TRANSITIVE dependencies.
-- Those are a 3NF concern, handled in Stage 3.
-- =====================================================

DROP TABLE IF EXISTS Hospital_2NF;

CREATE TABLE Hospital_2NF (
    VisitID      VARCHAR(10)  NOT NULL,
    VisitDate    DATE         NOT NULL,
    PatientID    VARCHAR(10)  NOT NULL,
    PatientName  VARCHAR(50)  NOT NULL,
    PatientPhone VARCHAR(20),
    DoctorID     VARCHAR(10)  NOT NULL,
    DoctorName   VARCHAR(50)  NOT NULL,
    Specialty    VARCHAR(50),
    DeptName     VARCHAR(50),
    DeptHead     VARCHAR(50),
    Diagnosis    VARCHAR(100),
    Fee          INT,
    PRIMARY KEY (VisitID),
    INDEX idx_patient (PatientID),
    INDEX idx_doctor  (DoctorID)
    -- 2NF satisfied: single-column PK means no partial
    -- dependency is possible by definition.
    -- Transitive deps still exist -- 3NF fixes them.
);

INSERT INTO Hospital_2NF
SELECT * FROM Hospital_1NF;

SELECT '=== 2NF: No partial deps (single-col PK). Transitive deps still present. ===' AS '';
SELECT * FROM Hospital_2NF;


-- =====================================================
-- STAGE 3 : THIRD NORMAL FORM (3NF)
-- =====================================================
-- Rule: Must be in 2NF AND no TRANSITIVE DEPENDENCY.
-- "Every non-prime attribute must depend on the key,
--  the whole key, and nothing but the key."
--
-- Decompose Hospital_2NF into 4 separate tables,
-- one for each functional dependency group:
--
--   Patient    table  <-- FD2
--   Department table  <-- FD4
--   Doctor     table  <-- FD3 (references Department)
--   Visit      table  <-- FD1 (references Patient + Doctor)
-- =====================================================

DROP TABLE IF EXISTS Visit;
DROP TABLE IF EXISTS Doctor;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Patient;


-- ---------------------------------------------------
-- 3NF TABLE 1 : Patient
-- PatientName and PatientPhone depend on PatientID,
-- NOT on VisitID. They describe the person, not the
-- visit. Extracting them removes the transitive chain:
--   VisitID --> PatientID --> PatientName, PatientPhone
-- ---------------------------------------------------
CREATE TABLE Patient (
    PatientID    VARCHAR(10)  NOT NULL,
    PatientName  VARCHAR(50)  NOT NULL,
    PatientPhone VARCHAR(20),
    PRIMARY KEY (PatientID)
);

INSERT INTO Patient VALUES
('P-201', 'Hassan',  '0300-1112233'),
('P-202', 'Mehreen', '0301-4445566'),
('P-203', 'Junaid',  '0302-7778899');

SELECT '=== 3NF Patient table ===' AS '';
SELECT * FROM Patient;


-- ---------------------------------------------------
-- 3NF TABLE 2 : Department
-- DeptHead depends on DeptName, NOT on DoctorID.
-- Extracting it removes the transitive chain:
--   DoctorID --> DeptName --> DeptHead
-- Created before Doctor because Doctor references it.
-- ---------------------------------------------------
CREATE TABLE Department (
    DeptName  VARCHAR(50)  NOT NULL,
    DeptHead  VARCHAR(50),
    PRIMARY KEY (DeptName)
);

INSERT INTO Department VALUES
('Heart Care',  'Dr. Tariq'),
('Skin Clinic', 'Dr. Asma');

SELECT '=== 3NF Department table ===' AS '';
SELECT * FROM Department;


-- ---------------------------------------------------
-- 3NF TABLE 3 : Doctor
-- DoctorName and Specialty depend on DoctorID, not
-- on VisitID. Extracting them removes:
--   VisitID --> DoctorID --> DoctorName, Specialty, DeptName
-- DeptName stays here as FK linking to Department.
-- ---------------------------------------------------
CREATE TABLE Doctor (
    DoctorID   VARCHAR(10)  NOT NULL,
    DoctorName VARCHAR(50)  NOT NULL,
    Specialty  VARCHAR(50),
    DeptName   VARCHAR(50)  NOT NULL,
    PRIMARY KEY (DoctorID),
    FOREIGN KEY (DeptName) REFERENCES Department(DeptName)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO Doctor VALUES
('D-30', 'Dr. Imran', 'Cardiology',  'Heart Care'),
('D-31', 'Dr. Asma',  'Dermatology', 'Skin Clinic');

SELECT '=== 3NF Doctor table ===' AS '';
SELECT * FROM Doctor;


-- ---------------------------------------------------
-- 3NF TABLE 4 : Visit
-- Only visit-specific facts remain: when, who, which
-- doctor, diagnosis, fee. PatientID and DoctorID are
-- FOREIGN KEYS -- links, not repeated descriptive data.
-- ---------------------------------------------------
CREATE TABLE Visit (
    VisitID    VARCHAR(10)   NOT NULL,
    VisitDate  DATE          NOT NULL,
    PatientID  VARCHAR(10)   NOT NULL,
    DoctorID   VARCHAR(10)   NOT NULL,
    Diagnosis  VARCHAR(100),
    Fee        INT,
    PRIMARY KEY (VisitID),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (DoctorID)  REFERENCES Doctor(DoctorID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO Visit VALUES
('V-9001', '2026-04-10', 'P-201', 'D-30', 'Hypertension', 2500),
('V-9002', '2026-04-10', 'P-202', 'D-31', 'Eczema',       2000),
('V-9003', '2026-04-11', 'P-201', 'D-31', 'Allergy',      2000),
('V-9004', '2026-04-12', 'P-203', 'D-30', 'Arrhythmia',   3000);

SELECT '=== 3NF Visit table ===' AS '';
SELECT * FROM Visit;


-- =====================================================
-- DELIVERABLE 5 : VERIFICATION QUERIES
-- =====================================================

-- Query 1: Rebuild the full original Table 8.1
SELECT '=== Full original report rebuilt from 3NF ===' AS '';
SELECT
    v.VisitID,
    v.VisitDate,
    p.PatientID,
    p.PatientName,
    p.PatientPhone,
    d.DoctorID,
    d.DoctorName,
    d.Specialty,
    dep.DeptName,
    dep.DeptHead,
    v.Diagnosis,
    v.Fee
FROM       Visit      v
JOIN       Patient    p   ON v.PatientID = p.PatientID
JOIN       Doctor     d   ON v.DoctorID  = d.DoctorID
JOIN       Department dep ON d.DeptName  = dep.DeptName
ORDER BY   v.VisitID;

-- Query 2: Row count check
SELECT '=== Row count check ===' AS '';
SELECT COUNT(*) AS Rows_in_1NF  FROM Hospital_1NF;
SELECT COUNT(*) AS Rows_in_Visit FROM Visit;

-- Query 3: Total spend per patient
SELECT '=== Patient total spend ===' AS '';
SELECT
    p.PatientID,
    p.PatientName,
    COUNT(v.VisitID) AS TotalVisits,
    SUM(v.Fee)       AS TotalFee_PKR
FROM  Patient p
LEFT JOIN Visit v ON p.PatientID = v.PatientID
GROUP BY p.PatientID, p.PatientName
ORDER BY TotalFee_PKR DESC;

-- Query 4: Revenue per department
SELECT '=== Revenue by department ===' AS '';
SELECT
    dep.DeptName,
    dep.DeptHead,
    COUNT(v.VisitID) AS Visits,
    SUM(v.Fee)       AS Revenue_PKR
FROM  Department dep
JOIN  Doctor     d   ON dep.DeptName = d.DeptName
JOIN  Visit      v   ON d.DoctorID   = v.DoctorID
GROUP BY dep.DeptName, dep.DeptHead
ORDER BY Revenue_PKR DESC;

-- Query 5: Doctors independent of visits
SELECT '=== Doctors exist independently of any visit ===' AS '';
SELECT d.DoctorID, d.DoctorName, d.Specialty, dep.DeptName, dep.DeptHead
FROM Doctor d
JOIN Department dep ON d.DeptName = dep.DeptName;


-- =====================================================
-- DELIVERABLE 6 : HOW 3NF ELIMINATES EVERY ANOMALY
-- =====================================================
--
-- INSERT ANOMALY -- ELIMINATED:
--   Before: Dr. Zara could not be recorded without
--   a patient visit. Doctor info was buried in Visit.
--   After: INSERT INTO Department + Doctor independently.
--   No visit row needed. No dummy data.
--
-- UPDATE ANOMALY -- ELIMINATED:
--   Before: Moving Dr. Imran to a new department meant
--   updating V-9001 AND V-9004 in DoctorInfo text.
--   After: ONE row updated in Doctor table. ON UPDATE
--   CASCADE propagates the change everywhere. One fact,
--   one place, one update.
--
-- DELETE ANOMALY -- ELIMINATED:
--   Before: Deleting V-9004 (Junaid) destroyed
--   Dr. Imran's specialty and department record.
--   After: Visit rows and Doctor rows are separate.
--   Deleting a visit never touches Doctor or Department.
--   ON DELETE RESTRICT prevents accidental removal of
--   a doctor who still has active visits on record.
--
-- =====================================================
-- SCHEMA VISIBLE AFTER IMPORT (7 tables total):
--   Hospital_UNF  -- non-atomic cells, repeating groups, no PK
--   Hospital_1NF  -- atomic values, PK declared
--   Hospital_2NF  -- 2NF confirmed, transitive deps noted
--   Patient       -- 3NF master table
--   Department    -- 3NF master table
--   Doctor        -- 3NF master table, FK -> Department
--   Visit         -- 3NF fact table, FK -> Patient + Doctor
-- =====================================================
