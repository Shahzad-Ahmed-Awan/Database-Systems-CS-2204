/* =====================================================================
   DATABASE SYSTEMS  |  LAB 06  -  Database Normalization
   Topic     : Second Normal Form (2NF) and Third Normal Form (3NF)
   Name      : ______________________        Roll No : ______________
   Tools     : MySQL 8.x  (Workbench or Command Line Client)

   CONTINUATION OF : Lab05_Normalization_1NF.sql
                     >>> Run Lab 05 FIRST. <<<
                     This file starts from the 1NF tables built there
                     (bookstore_db.OrderBook_1NF and hospital_db.Visit_1NF)
                     and decomposes them step by step: 1NF -> 2NF -> 3NF.

   CONTENTS
     PART A  Bookstore scenario   (Lab Manual, Section 7 - Lab Tasks)
             Task 3   Convert to 2NF
             Task 4   Convert to 3NF
             Task 5   Verification queries
             Task 6   Reflection

     PART B  Hospital problem     (Lab Manual, Section 8 - Assessment)
             Deliverable 3   2NF schema with justification
             Deliverable 4   3NF schema, foreign keys, fully populated
             Deliverable 5   Single SELECT that recreates Table 8.1
             Deliverable 6   Anomalies eliminated (comments)
   ===================================================================== */


/* #####################################################################
   PART A  -  ONLINE BOOKSTORE
   ##################################################################### */

USE bookstore_db;

-- Sanity check: the 1NF table from Lab 05 must exist and hold 5 rows.
SELECT COUNT(*) AS rows_in_1NF FROM OrderBook_1NF;

-- Make this part re-runnable (children are dropped before parents).
DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS OrderItem_2NF;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Orders_2NF;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Book_2NF;


-- =====================================================================
-- TASK 3 : Convert to 2NF
-- =====================================================================
/*
  2NF RULE : the table is in 1NF AND every non-prime attribute depends on
             the WHOLE primary key (no partial dependencies).

  1NF table   : OrderBook_1NF        primary key = (OrderID, BookID)
  Prime attributes     : OrderID, BookID
  Non-prime attributes : OrderDate, CustID, CustName, CustEmail,
                         BookTitle, Publisher, UnitPrice, Qty

  ---------------------------------------------------------------------
  PARTIAL DEPENDENCIES FOUND
  ---------------------------------------------------------------------
  Attribute(s)                                    Depends on     Verdict
  ----------------------------------------------  -------------  --------------------------
  OrderDate, CustID, CustName, CustEmail          OrderID only   PARTIAL -> move to Orders
  BookTitle, Publisher, UnitPrice                 BookID only    PARTIAL -> move to Book
  Qty                                             (OrderID,      FULL    -> stays in
                                                   BookID)       OrderItem

  ---------------------------------------------------------------------
  DECOMPOSITION INTO 2NF
  ---------------------------------------------------------------------
  Orders_2NF    (OrderID PK, OrderDate, CustID, CustName, CustEmail)
  Book_2NF      (BookID  PK, BookTitle, Publisher, UnitPrice)
  OrderItem_2NF (OrderID, BookID, Qty)   PK (OrderID, BookID)
                 FK OrderID -> Orders_2NF,  FK BookID -> Book_2NF

  Every non-prime attribute now depends on the whole key of its table.
  The tables carry a _2NF suffix so they do not clash with the final
  3NF tables built in Task 4.
*/

-- 2NF
CREATE TABLE Orders_2NF (
    OrderID     VARCHAR(10)  NOT NULL,
    OrderDate   DATE         NOT NULL,
    CustID      VARCHAR(10)  NOT NULL,
    CustName    VARCHAR(50)  NOT NULL,
    CustEmail   VARCHAR(80)  NOT NULL,
    PRIMARY KEY (OrderID)
);

-- 2NF
CREATE TABLE Book_2NF (
    BookID      VARCHAR(10)    NOT NULL,
    BookTitle   VARCHAR(80)    NOT NULL,
    Publisher   VARCHAR(50)    NOT NULL,
    UnitPrice   DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (BookID)
);

-- 2NF
CREATE TABLE OrderItem_2NF (
    OrderID     VARCHAR(10)  NOT NULL,
    BookID      VARCHAR(10)  NOT NULL,
    Qty         INT          NOT NULL,
    PRIMARY KEY (OrderID, BookID),
    CONSTRAINT fk_oi2_order FOREIGN KEY (OrderID) REFERENCES Orders_2NF (OrderID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_oi2_book  FOREIGN KEY (BookID)  REFERENCES Book_2NF (BookID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 2NF : load the data from the 1NF table (DISTINCT removes the repeated facts)
INSERT INTO Orders_2NF (OrderID, OrderDate, CustID, CustName, CustEmail)
SELECT DISTINCT OrderID, OrderDate, CustID, CustName, CustEmail
FROM   OrderBook_1NF;

INSERT INTO Book_2NF (BookID, BookTitle, Publisher, UnitPrice)
SELECT DISTINCT BookID, BookTitle, Publisher, UnitPrice
FROM   OrderBook_1NF;

INSERT INTO OrderItem_2NF (OrderID, BookID, Qty)
SELECT OrderID, BookID, Qty
FROM   OrderBook_1NF;

-- Check the 2NF tables
SELECT * FROM Orders_2NF    ORDER BY OrderID;               -- expect 3 rows
SELECT * FROM Book_2NF      ORDER BY BookID;                -- expect 3 rows
SELECT * FROM OrderItem_2NF ORDER BY OrderID, BookID;       -- expect 5 rows

-- Still not finished: in Orders_2NF, Bilal's name and email are stored
-- twice (orders O-501 and O-503) - a transitive dependency remains.


-- =====================================================================
-- TASK 4 : Convert to 3NF
-- =====================================================================
/*
  3NF RULE : the table is in 2NF AND no non-prime attribute depends on
             another non-prime attribute (no transitive dependencies).
             Every non-key attribute must depend on "the key, the whole
             key, and nothing but the key".

  ---------------------------------------------------------------------
  TRANSITIVE DEPENDENCY FOUND
  ---------------------------------------------------------------------
  Orders_2NF :  OrderID -> CustID     and     CustID -> CustName, CustEmail
                so  OrderID -> CustName, CustEmail  only THROUGH CustID.
                CustName / CustEmail are facts about the customer, not
                about the order  ->  extract a Customer table.

  Book_2NF    : BookTitle, Publisher, UnitPrice depend directly on BookID.
                No non-key attribute determines another  -> already 3NF.
  OrderItem_2NF : Qty depends on the full key (OrderID, BookID)
                -> already 3NF.

  Note on Publisher: it is only a name in this data (no publisher
  address, phone, etc.), so a separate Publisher table would be
  over-normalization (see Manual Section 9). It stays in Book.

  ---------------------------------------------------------------------
  FINAL 3NF SCHEMA
  ---------------------------------------------------------------------
  Customer  (CustID PK, CustName, CustEmail)
  Orders    (OrderID PK, OrderDate, CustID FK -> Customer)
  Book      (BookID PK, BookTitle, Publisher, UnitPrice)
  OrderItem (OrderID FK -> Orders, BookID FK -> Book, Qty)  PK (OrderID, BookID)
*/

-- 3NF
CREATE TABLE Customer (
    CustID      VARCHAR(10)  NOT NULL,
    CustName    VARCHAR(50)  NOT NULL,
    CustEmail   VARCHAR(80)  NOT NULL,
    PRIMARY KEY (CustID)
);

-- 3NF
CREATE TABLE Orders (
    OrderID     VARCHAR(10)  NOT NULL,
    OrderDate   DATE         NOT NULL,
    CustID      VARCHAR(10)  NOT NULL,
    PRIMARY KEY (OrderID),
    CONSTRAINT fk_orders_customer FOREIGN KEY (CustID) REFERENCES Customer (CustID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 3NF
CREATE TABLE Book (
    BookID      VARCHAR(10)    NOT NULL,
    BookTitle   VARCHAR(80)    NOT NULL,
    Publisher   VARCHAR(50)    NOT NULL,
    UnitPrice   DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (BookID)
);

-- 3NF
CREATE TABLE OrderItem (
    OrderID     VARCHAR(10)  NOT NULL,
    BookID      VARCHAR(10)  NOT NULL,
    Qty         INT          NOT NULL,
    PRIMARY KEY (OrderID, BookID),
    CONSTRAINT fk_oi_order FOREIGN KEY (OrderID) REFERENCES Orders (OrderID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_oi_book  FOREIGN KEY (BookID)  REFERENCES Book (BookID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 3NF : load the data from the 2NF tables (parents first, children last)
INSERT INTO Customer (CustID, CustName, CustEmail)
SELECT DISTINCT CustID, CustName, CustEmail
FROM   Orders_2NF;

INSERT INTO Orders (OrderID, OrderDate, CustID)
SELECT OrderID, OrderDate, CustID
FROM   Orders_2NF;

INSERT INTO Book (BookID, BookTitle, Publisher, UnitPrice)
SELECT BookID, BookTitle, Publisher, UnitPrice
FROM   Book_2NF;

INSERT INTO OrderItem (OrderID, BookID, Qty)
SELECT OrderID, BookID, Qty
FROM   OrderItem_2NF;

-- The 2NF tables are now superseded by the 3NF tables, so remove them
-- (children first because of the foreign keys).
-- OrderBook_1NF is kept as the reference copy of the original report.
DROP TABLE OrderItem_2NF;
DROP TABLE Orders_2NF;
DROP TABLE Book_2NF;

-- Check the 3NF schema and data
SHOW TABLES;
SELECT * FROM Customer  ORDER BY CustID;                    -- expect 2 rows
SELECT * FROM Orders    ORDER BY OrderID;                   -- expect 3 rows
SELECT * FROM Book      ORDER BY BookID;                    -- expect 3 rows
SELECT * FROM OrderItem ORDER BY OrderID, BookID;           -- expect 5 rows


-- =====================================================================
-- TASK 5 : Verification queries
-- =====================================================================

-- 5(a) Recreate the original report: one row per book purchased.
SELECT o.OrderID,
       o.OrderDate,
       c.CustID,
       c.CustName,
       c.CustEmail,
       b.BookID,
       b.BookTitle,
       b.Publisher,
       b.UnitPrice,
       oi.Qty
FROM   OrderItem oi
JOIN   Orders    o ON oi.OrderID = o.OrderID
JOIN   Customer  c ON o.CustID   = c.CustID
JOIN   Book      b ON oi.BookID  = b.BookID
ORDER  BY o.OrderID, b.BookID;                              -- expect 5 rows

-- 5(a, extra) Lossless check: row count of the 3NF join must equal the
-- row count of the 1NF table (both should be 5).
SELECT (SELECT COUNT(*) FROM OrderBook_1NF) AS rows_in_1NF,
       (SELECT COUNT(*)
        FROM   OrderItem oi
        JOIN   Orders    o ON oi.OrderID = o.OrderID
        JOIN   Customer  c ON o.CustID   = c.CustID
        JOIN   Book      b ON oi.BookID  = b.BookID) AS rows_from_3NF_join;

-- 5(b) Total spend of every customer (quantity x unit price).
--      LEFT JOINs keep customers who have not ordered yet (total = 0).
SELECT c.CustID,
       c.CustName,
       COALESCE(SUM(oi.Qty * b.UnitPrice), 0) AS total_spend
FROM   Customer c
LEFT   JOIN Orders    o  ON o.CustID   = c.CustID
LEFT   JOIN OrderItem oi ON oi.OrderID = o.OrderID
LEFT   JOIN Book      b  ON oi.BookID  = b.BookID
GROUP  BY c.CustID, c.CustName
ORDER  BY total_spend DESC;
-- Expected: C-11 Bilal = 7500.00 (1x1200 + 2x1500 + 1x1800 + 1x1500)
--           C-12 Areeba = 3600.00 (3x1200)


-- =====================================================================
-- TASK 6 : Reflection (how the 3NF schema prevents each anomaly)
-- =====================================================================
/*
  In the 3NF schema every fact is stored in exactly one place, which
  removes the three anomalies from Task 1. INSERTION: a new book such as
  B-4 goes straight into Book, and a new customer goes into Customer,
  without needing any order. UPDATE: Bilal's email exists in a single row
  of Customer, so changing it once is enough and every order of his
  automatically sees the new value; the same holds for a book's price in
  Book. DELETION: cancelling order O-502 removes only rows from Orders
  and OrderItem; Areeba stays in Customer and the book B-1 stays in Book.
  Foreign keys (with ON DELETE RESTRICT) additionally stop anyone from
  deleting a customer or book that is still referenced, so the data
  cannot become inconsistent.
*/

-- Demonstration (safe: everything is rolled back at the end).
START TRANSACTION;

-- Insertion: add a book that nobody has ordered yet.
INSERT INTO Book (BookID, BookTitle, Publisher, UnitPrice)
VALUES ('B-4', 'Data Structures', 'Pearson', 2000.00);

-- Update: change Bilal's email in ONE place; both his orders reflect it.
UPDATE Customer SET CustEmail = 'bilal.new@x.com' WHERE CustID = 'C-11';
SELECT o.OrderID, c.CustName, c.CustEmail
FROM   Orders o JOIN Customer c ON o.CustID = c.CustID
ORDER  BY o.OrderID;

-- Deletion: cancel order O-502 completely; Areeba and book B-1 survive.
DELETE FROM OrderItem WHERE OrderID = 'O-502';
DELETE FROM Orders    WHERE OrderID = 'O-502';
SELECT * FROM Customer ORDER BY CustID;                     -- Areeba (C-12) still present
SELECT * FROM Book     ORDER BY BookID;                     -- B-1 and new B-4 still present

ROLLBACK;

-- Confirm the data is back to its original state.
SELECT COUNT(*) AS orders_after_rollback FROM Orders;       -- expect 3



/* #####################################################################
   PART B  -  HOSPITAL PATIENT VISITS  (Assessment Problem)
   ##################################################################### */

USE hospital_db;

-- Sanity check: the 1NF table from Lab 05 must exist and hold 4 rows.
SELECT COUNT(*) AS rows_in_1NF FROM Visit_1NF;

-- Make this part re-runnable (children are dropped before parents).
DROP TABLE IF EXISTS Visit;
DROP TABLE IF EXISTS Doctor;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Patient;


-- =====================================================================
-- DELIVERABLE 3 : 2NF schema with justification               (20 marks)
-- =====================================================================
/*
  1NF table : Visit_1NF      primary key = VisitID   (a SINGLE attribute)

  A partial dependency means "a non-prime attribute depends on only PART
  of a composite primary key". A single-attribute key has no "parts", so
  it is impossible for a partial dependency to exist.

  Check of every non-prime attribute against the key {VisitID}:
    VisitDate, PatientID, DoctorID, Diagnosis, Fee   -> depend on VisitID (FD1)
    PatientName, PatientPhone   -> depend on VisitID (through PatientID)
    DoctorName, Specialty, DeptName, DeptHead
                                -> depend on VisitID (through DoctorID / DeptName)
  Each depends on the WHOLE key (there is no smaller part of it).

  PARTIAL DEPENDENCIES REMOVED : none - there are none to remove.

  CONCLUSION : Visit_1NF is already in 2NF. The 2NF schema is therefore
  identical to the 1NF schema:

      Visit_2NF(VisitID PK, VisitDate, PatientID, PatientName,
                PatientPhone, DoctorID, DoctorName, Specialty,
                DeptName, DeptHead, Diagnosis, Fee)

  (Splitting the table at this stage would not be a 2NF step; the real
  problem in this table is TRANSITIVE dependencies, handled in 3NF.)
*/

-- 2NF : confirm the key is a single column (so no partial dependency is possible).
SELECT COLUMN_NAME AS primary_key_column
FROM   INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE  TABLE_SCHEMA = 'hospital_db'
  AND  TABLE_NAME   = 'Visit_1NF'
  AND  CONSTRAINT_NAME = 'PRIMARY';                         -- expect only VisitID


-- =====================================================================
-- DELIVERABLE 4 : 3NF schema, all foreign keys, fully populated (30 marks)
-- =====================================================================
/*
  3NF RULE : 2NF + no non-prime attribute depends on another non-prime
             attribute.

  ---------------------------------------------------------------------
  TRANSITIVE DEPENDENCIES FOUND IN Visit_1NF
  ---------------------------------------------------------------------
  T1 : VisitID -> PatientID -> PatientName, PatientPhone
       => Patient details belong to the PATIENT  -> table Patient

  T2 : VisitID -> DoctorID  -> DoctorName, Specialty, DeptName
       => Doctor details belong to the DOCTOR    -> table Doctor

  T3 : DoctorID -> DeptName -> DeptHead
       => Department head belongs to the DEPARTMENT -> table Department

  ---------------------------------------------------------------------
  FINAL 3NF SCHEMA
  ---------------------------------------------------------------------
  Patient    (PatientID PK, PatientName, PatientPhone)
  Department (DeptName PK, DeptHead)
  Doctor     (DoctorID PK, DoctorName, Specialty, DeptName FK -> Department)
  Visit      (VisitID PK, VisitDate, PatientID FK -> Patient,
              DoctorID FK -> Doctor, Diagnosis, Fee)

  Design notes:
    * DeptName is used as the Department key because the data provides no
      separate department ID and each department name is unique.
    * DeptHead is kept as text: the head (e.g. Dr. Tariq) is not
      necessarily listed as a doctor in the sample data.
    * Diagnosis and Fee depend on VisitID only, so they stay in Visit.
*/

-- 3NF
CREATE TABLE Patient (
    PatientID     VARCHAR(10)  NOT NULL,
    PatientName   VARCHAR(50)  NOT NULL,
    PatientPhone  VARCHAR(15)  NOT NULL,
    PRIMARY KEY (PatientID)
);

-- 3NF
CREATE TABLE Department (
    DeptName      VARCHAR(50)  NOT NULL,
    DeptHead      VARCHAR(50)  NOT NULL,
    PRIMARY KEY (DeptName)
);

-- 3NF
CREATE TABLE Doctor (
    DoctorID      VARCHAR(10)  NOT NULL,
    DoctorName    VARCHAR(50)  NOT NULL,
    Specialty     VARCHAR(50)  NOT NULL,
    DeptName      VARCHAR(50)  NOT NULL,
    PRIMARY KEY (DoctorID),
    CONSTRAINT fk_doctor_dept FOREIGN KEY (DeptName) REFERENCES Department (DeptName)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 3NF
CREATE TABLE Visit (
    VisitID       VARCHAR(10)  NOT NULL,
    VisitDate     DATE         NOT NULL,
    PatientID     VARCHAR(10)  NOT NULL,
    DoctorID      VARCHAR(10)  NOT NULL,
    Diagnosis     VARCHAR(80)  NOT NULL,
    Fee           INT          NOT NULL,                    -- in PKR
    PRIMARY KEY (VisitID),
    CONSTRAINT fk_visit_patient FOREIGN KEY (PatientID) REFERENCES Patient (PatientID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_visit_doctor  FOREIGN KEY (DoctorID)  REFERENCES Doctor (DoctorID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 3NF : load the data from Visit_1NF (parents first, children last)
INSERT INTO Patient (PatientID, PatientName, PatientPhone)
SELECT DISTINCT PatientID, PatientName, PatientPhone
FROM   Visit_1NF;

INSERT INTO Department (DeptName, DeptHead)
SELECT DISTINCT DeptName, DeptHead
FROM   Visit_1NF;

INSERT INTO Doctor (DoctorID, DoctorName, Specialty, DeptName)
SELECT DISTINCT DoctorID, DoctorName, Specialty, DeptName
FROM   Visit_1NF;

INSERT INTO Visit (VisitID, VisitDate, PatientID, DoctorID, Diagnosis, Fee)
SELECT VisitID, VisitDate, PatientID, DoctorID, Diagnosis, Fee
FROM   Visit_1NF;

-- Check the 3NF schema and data
SHOW TABLES;
SELECT * FROM Patient    ORDER BY PatientID;                -- expect 3 rows
SELECT * FROM Department ORDER BY DeptName;                 -- expect 2 rows
SELECT * FROM Doctor     ORDER BY DoctorID;                 -- expect 2 rows
SELECT * FROM Visit      ORDER BY VisitID;                  -- expect 4 rows


-- =====================================================================
-- DELIVERABLE 5 : One SELECT that recreates Table 8.1         (15 marks)
-- =====================================================================
SELECT v.VisitID,
       v.VisitDate,
       p.PatientID,
       p.PatientName,
       p.PatientPhone,
       d.DoctorID,
       d.DoctorName,
       d.Specialty,
       dp.DeptName,
       dp.DeptHead,
       v.Diagnosis,
       v.Fee
FROM   Visit      v
JOIN   Patient    p  ON v.PatientID = p.PatientID
JOIN   Doctor     d  ON v.DoctorID  = d.DoctorID
JOIN   Department dp ON d.DeptName  = dp.DeptName
ORDER  BY v.VisitID;                                        -- expect the 4 original rows

-- Lossless check: the join must return as many rows as Visit_1NF (both 4).
SELECT (SELECT COUNT(*) FROM Visit_1NF) AS rows_in_1NF,
       (SELECT COUNT(*)
        FROM   Visit v
        JOIN   Patient    p  ON v.PatientID = p.PatientID
        JOIN   Doctor     d  ON v.DoctorID  = d.DoctorID
        JOIN   Department dp ON d.DeptName  = dp.DeptName) AS rows_from_3NF_join;


-- =====================================================================
-- DELIVERABLE 6 : Anomalies eliminated by the design          (10 marks)
-- =====================================================================
/*
  Anomalies of the flat Visit table (before normalization):
    - INSERTION : a new doctor, department or patient could not be stored
                  until a visit existed (VisitID is the key).
    - UPDATE    : changing Dr. Imran's specialty, Dr. Tariq's head-of-
                  department role, or Hassan's phone number meant editing
                  every visit row that repeats it; missing one causes
                  inconsistent data.
    - DELETION  : deleting V-9004 (Junaid's only visit) would erase every
                  trace of patient Junaid; deleting all visits of a
                  doctor would erase the doctor and department facts.

  How the 3NF design eliminates them:
    - INSERTION anomaly ELIMINATED : Patient, Doctor and Department are
      separate tables, so a new patient, doctor or department can be
      added before any visit exists.
    - UPDATE anomaly ELIMINATED : each fact is stored once. Hassan's
      phone lives only in Patient, Dr. Imran's specialty only in Doctor,
      and Dr. Tariq's role only in Department; one UPDATE fixes it
      everywhere.
    - DELETION anomaly ELIMINATED : deleting a visit removes only that
      row in Visit; the patient, doctor and department records remain.
      Foreign keys with ON DELETE RESTRICT also block deleting a
      patient, doctor or department that is still referenced.
    - REDUNDANCY REDUCED : patient, doctor and department details are
      no longer repeated for every visit, which also saves storage and
      keeps the data consistent.
*/

/* ---------------------------------------------------------------------
   END OF LAB 06.
   --------------------------------------------------------------------- */
