/* =====================================================================
   DATABASE SYSTEMS  |  LAB 05  -  Database Normalization
   Topic     : Introduction to normalization, functional dependencies,
               anomalies, and First Normal Form (1NF)
   Name      : ______________________        Roll No : ______________
   Tools     : MySQL 8.x  (Workbench or Command Line Client)

   CONTINUES IN : Lab06_Normalization_2NF_3NF.sql
                  (Run THIS file first. Lab 06 reads the 1NF tables
                   created here and normalizes them further.)

   CONTENTS
     PART A  Bookstore scenario   (Lab Manual, Section 7 - Lab Tasks)
             Task 1   Functional dependencies and anomalies
             Task 2   Convert to 1NF (table: OrderBook_1NF)

     PART B  Hospital problem     (Lab Manual, Section 8 - Assessment)
             Deliverable 1   Functional dependencies and candidate key
             Deliverable 2   1NF version of the table (schema + INSERTs)
   ===================================================================== */


/* #####################################################################
   PART A  -  ONLINE BOOKSTORE
   ##################################################################### */

-- Clean start so the script can be re-run safely.
DROP DATABASE IF EXISTS bookstore_db;
CREATE DATABASE bookstore_db;
USE bookstore_db;


-- =====================================================================
-- TASK 1 : Identify functional dependencies and anomalies
-- =====================================================================
/*
  RAW DATA (UNF) - Table 7.1, multi-valued cells shown with ';'

  OrderID | OrderDate  | CustID | CustName | CustEmail       | Books (BookID)                     | Publisher        | UnitPrice  | Qty
  --------+------------+--------+----------+-----------------+------------------------------------+------------------+------------+------
  O-501   | 2026-04-02 | C-11   | Bilal    | bilal@x.com     | SQL Basics (B-1); Python 101 (B-2) | Pearson; OReilly | 1200; 1500 | 1; 2
  O-502   | 2026-04-03 | C-12   | Areeba   | areeba@x.com    | SQL Basics (B-1)                   | Pearson          | 1200       | 3
  O-503   | 2026-04-05 | C-11   | Bilal    | bilal@x.com     | Networks (B-3); Python 101 (B-2)   | Pearson; OReilly | 1800; 1500 | 1; 1

  ---------------------------------------------------------------------
  1.1  FUNCTIONAL DEPENDENCIES
  ---------------------------------------------------------------------
  FD1 : OrderID            -> OrderDate, CustID
        (an order is placed on one date by exactly one customer)
  FD2 : CustID             -> CustName, CustEmail
        (a customer ID maps to one name and one email)
  FD3 : BookID             -> BookTitle, Publisher, UnitPrice
        (each book has exactly one title, one publisher, one price)
  FD4 : (OrderID, BookID)  -> Qty
        (the quantity depends on BOTH the order and the book)

  Derived (transitive) dependency:
  FD5 : OrderID -> CustID -> CustName, CustEmail
        so OrderID -> CustName, CustEmail holds only through CustID.

  Candidate key of the flattened relation:
        (OrderID, BookID)
        Closure: {OrderID, BookID}+ = OrderDate, CustID, CustName,
        CustEmail, BookTitle, Publisher, UnitPrice, Qty  (all attributes)
        Neither OrderID alone nor BookID alone reaches every attribute
        (Qty is missing), so the composite key is minimal.

  Assumptions: CustEmail is treated as a plain attribute (CustID is the
  identifier). Publisher is a name only - the data gives no other
  publisher facts, so nothing depends on Publisher.

  ---------------------------------------------------------------------
  1.2  ANOMALIES IN THE FLAT DESIGN
  ---------------------------------------------------------------------
  INSERTION anomaly:
    We cannot add a new book (e.g. B-4 "Data Structures", Pearson, 2000)
    to the catalogue until some customer orders it, because a row needs
    an OrderID (part of the key, so it cannot be NULL). The same is true
    for registering a new customer who has not yet placed an order.

  UPDATE anomaly:
    Bilal (C-11) appears in the rows of orders O-501 and O-503. If his
    email changes, every one of those rows must be edited. Missing even
    one leaves the database contradicting itself. The same happens when
    the price of "Python 101" changes: it is stored in several rows.

  DELETION anomaly:
    Areeba (C-12) appears only in order O-502. If that order is cancelled
    and deleted, all information about Areeba is lost. Likewise, deleting
    O-503 would erase the only record of the book "Networks" (B-3).
*/


-- =====================================================================
-- TASK 2 : Convert to 1NF
-- =====================================================================
/*
  1NF RULE : every cell holds ONE atomic value, there are no repeating
             groups, and every row is uniquely identifiable.

  What we do : split each multi-valued order into one row PER BOOK
               PURCHASED. Values that were packed together
               ("SQL Basics (B-1); Python 101 (B-2)", "1200; 1500",
               "1; 2") become separate, single-valued cells.

  PRIMARY KEY : (OrderID, BookID)
    - OrderID alone repeats when an order has several books.
    - BookID  alone repeats when a book is sold in several orders.
    - The pair is unique for every row and determines every other column.

  Table 7.1 redrawn in 1NF:

  OrderID | OrderDate  | CustID | CustName | CustEmail    | BookID | BookTitle  | Publisher | UnitPrice | Qty
  --------+------------+--------+----------+--------------+--------+------------+-----------+-----------+-----
  O-501   | 2026-04-02 | C-11   | Bilal    | bilal@x.com  | B-1    | SQL Basics | Pearson   | 1200      | 1
  O-501   | 2026-04-02 | C-11   | Bilal    | bilal@x.com  | B-2    | Python 101 | OReilly   | 1500      | 2
  O-502   | 2026-04-03 | C-12   | Areeba   | areeba@x.com | B-1    | SQL Basics | Pearson   | 1200      | 3
  O-503   | 2026-04-05 | C-11   | Bilal    | bilal@x.com  | B-3    | Networks   | Pearson   | 1800      | 1
  O-503   | 2026-04-05 | C-11   | Bilal    | bilal@x.com  | B-2    | Python 101 | OReilly   | 1500      | 1
*/

-- 1NF
CREATE TABLE OrderBook_1NF (
    OrderID     VARCHAR(10)    NOT NULL,
    OrderDate   DATE           NOT NULL,
    CustID      VARCHAR(10)    NOT NULL,
    CustName    VARCHAR(50)    NOT NULL,
    CustEmail   VARCHAR(80)    NOT NULL,
    BookID      VARCHAR(10)    NOT NULL,
    BookTitle   VARCHAR(80)    NOT NULL,
    Publisher   VARCHAR(50)    NOT NULL,
    UnitPrice   DECIMAL(10,2)  NOT NULL,
    Qty         INT            NOT NULL,
    PRIMARY KEY (OrderID, BookID)
);

-- 1NF
INSERT INTO OrderBook_1NF
    (OrderID, OrderDate, CustID, CustName, CustEmail, BookID, BookTitle, Publisher, UnitPrice, Qty)
VALUES
    ('O-501', '2026-04-02', 'C-11', 'Bilal',  'bilal@x.com',  'B-1', 'SQL Basics', 'Pearson', 1200.00, 1),
    ('O-501', '2026-04-02', 'C-11', 'Bilal',  'bilal@x.com',  'B-2', 'Python 101', 'OReilly', 1500.00, 2),
    ('O-502', '2026-04-03', 'C-12', 'Areeba', 'areeba@x.com', 'B-1', 'SQL Basics', 'Pearson', 1200.00, 3),
    ('O-503', '2026-04-05', 'C-11', 'Bilal',  'bilal@x.com',  'B-3', 'Networks',   'Pearson', 1800.00, 1),
    ('O-503', '2026-04-05', 'C-11', 'Bilal',  'bilal@x.com',  'B-2', 'Python 101', 'OReilly', 1500.00, 1);

-- Check the result
DESCRIBE OrderBook_1NF;
SELECT * FROM OrderBook_1NF ORDER BY OrderID, BookID;      -- expect 5 rows

-- 1NF only made the data atomic. Redundancy is still visible:
-- Bilal's name/email and each book's title/price are repeated in several rows.
-- (This is exactly what 2NF and 3NF will fix in Lab 06.)
SELECT CustID, CustName, CustEmail, COUNT(*) AS times_repeated
FROM   OrderBook_1NF
GROUP  BY CustID, CustName, CustEmail;

SELECT BookID, BookTitle, Publisher, UnitPrice, COUNT(*) AS times_repeated
FROM   OrderBook_1NF
GROUP  BY BookID, BookTitle, Publisher, UnitPrice;



/* #####################################################################
   PART B  -  HOSPITAL PATIENT VISITS  (Assessment Problem)
   ##################################################################### */

DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db;
USE hospital_db;


-- =====================================================================
-- DELIVERABLE 1 : Functional dependencies and candidate key   (10 marks)
-- =====================================================================
/*
  The three views in Table 8.1 share the same VisitIDs, so they describe
  ONE relation with these attributes:

  Visit(VisitID, VisitDate, PatientID, PatientName, PatientPhone,
        DoctorID, DoctorName, Specialty, DeptName, DeptHead,
        Diagnosis, Fee)

  ---------------------------------------------------------------------
  FUNCTIONAL DEPENDENCIES
  ---------------------------------------------------------------------
  FD1 : VisitID    -> VisitDate, PatientID, DoctorID, Diagnosis, Fee
        (each visit happens once, with one patient and one doctor,
         and has one diagnosis and one fee)
  FD2 : PatientID  -> PatientName, PatientPhone
  FD3 : DoctorID   -> DoctorName, Specialty, DeptName
  FD4 : DeptName   -> DeptHead

  Derived (transitive) dependencies:
  FD5 : VisitID -> PatientID -> PatientName, PatientPhone
  FD6 : VisitID -> DoctorID  -> DoctorName, Specialty, DeptName
  FD7 : DoctorID -> DeptName -> DeptHead
        (and therefore VisitID -> DeptHead)

  Notes on attributes that could be misread:
    * Fee is NOT determined by DoctorID: Dr. Imran (D-30) charged 2500
      for V-9001 but 3000 for V-9004. Fee therefore belongs to the visit.
    * Diagnosis belongs to the visit: it differs between visits even for
      the same patient (Hassan: Hypertension on V-9001, Allergy on
      V-9003), so it depends on VisitID only.
    * Specialty and DeptName happen to move together in this sample
      (Cardiology/Heart Care, Dermatology/Skin Clinic), but the data does
      not prove a general rule, so no FD Specialty -> DeptName is assumed.

  ---------------------------------------------------------------------
  CANDIDATE KEY
  ---------------------------------------------------------------------
      VisitID   (single attribute)

  Closure: {VisitID}+ = every attribute of the relation
    VisitID -> VisitDate, PatientID, DoctorID, Diagnosis, Fee   (FD1)
    PatientID -> PatientName, PatientPhone                      (FD2)
    DoctorID  -> DoctorName, Specialty, DeptName                (FD3)
    DeptName  -> DeptHead                                       (FD4)

  No other attribute is unique per row (PatientID repeats: P-201 has two
  visits; DoctorID repeats: D-30 and D-31 each have two visits), so
  VisitID is the only candidate key and is chosen as the PRIMARY KEY.
*/


-- =====================================================================
-- DELIVERABLE 2 : 1NF version of the table                    (15 marks)
-- =====================================================================
/*
  Merging the three views of Table 8.1 on VisitID gives one row per visit.
  Every cell already holds a single atomic value (one phone number, one
  diagnosis, one fee, ...), there are no repeating groups, and VisitID
  identifies each row uniquely - so the merged table IS in 1NF.
*/

-- 1NF
CREATE TABLE Visit_1NF (
    VisitID       VARCHAR(10)   NOT NULL,
    VisitDate     DATE          NOT NULL,
    PatientID     VARCHAR(10)   NOT NULL,
    PatientName   VARCHAR(50)   NOT NULL,
    PatientPhone  VARCHAR(15)   NOT NULL,
    DoctorID      VARCHAR(10)   NOT NULL,
    DoctorName    VARCHAR(50)   NOT NULL,
    Specialty     VARCHAR(50)   NOT NULL,
    DeptName      VARCHAR(50)   NOT NULL,
    DeptHead      VARCHAR(50)   NOT NULL,
    Diagnosis     VARCHAR(80)   NOT NULL,
    Fee           INT           NOT NULL,          -- in PKR
    PRIMARY KEY (VisitID)
);

-- 1NF
INSERT INTO Visit_1NF
    (VisitID, VisitDate, PatientID, PatientName, PatientPhone,
     DoctorID, DoctorName, Specialty, DeptName, DeptHead, Diagnosis, Fee)
VALUES
    ('V-9001', '2026-04-10', 'P-201', 'Hassan',  '0300-1112233', 'D-30', 'Dr. Imran', 'Cardiology',   'Heart Care', 'Dr. Tariq', 'Hypertension', 2500),
    ('V-9002', '2026-04-10', 'P-202', 'Mehreen', '0301-4445566', 'D-31', 'Dr. Asma',  'Dermatology',  'Skin Clinic','Dr. Asma',  'Eczema',       2000),
    ('V-9003', '2026-04-11', 'P-201', 'Hassan',  '0300-1112233', 'D-31', 'Dr. Asma',  'Dermatology',  'Skin Clinic','Dr. Asma',  'Allergy',      2000),
    ('V-9004', '2026-04-12', 'P-203', 'Junaid',  '0302-7778899', 'D-30', 'Dr. Imran', 'Cardiology',   'Heart Care', 'Dr. Tariq', 'Arrhythmia',   3000);

-- Check the result
DESCRIBE Visit_1NF;
SELECT * FROM Visit_1NF ORDER BY VisitID;                 -- expect 4 rows

-- Redundancy that remains in 1NF (to be removed in Lab 06):
-- Hassan's details, Dr. Imran / Dr. Asma details and department details
-- are each stored more than once.
SELECT PatientID, PatientName, PatientPhone, COUNT(*) AS times_repeated
FROM   Visit_1NF
GROUP  BY PatientID, PatientName, PatientPhone;

SELECT DoctorID, DoctorName, Specialty, DeptName, DeptHead, COUNT(*) AS times_repeated
FROM   Visit_1NF
GROUP  BY DoctorID, DoctorName, Specialty, DeptName, DeptHead;

/* ---------------------------------------------------------------------
   END OF LAB 05.
   NEXT: run Lab06_Normalization_2NF_3NF.sql (2NF and 3NF for both parts).
   --------------------------------------------------------------------- */
