-- ############################################################################
-- #                                                                          #
-- #   DATABASE MANAGEMENT SYSTEM  |  OPEN-ENDED LAB ASSIGNMENT               #
-- #   PROJECT : CarGo Rentals - Car Rental Management System                 #
-- #   DBMS    : MySQL 8.x (InnoDB)                                           #
-- #                                                                          #
-- #   Name    : Shahzad Ahmed Awan                                   #
-- #   Roll No : 2024-SE-15                                     #
-- #   Section : SE                                     #
-- #   Submitted to : Sir Awais Rathore                                     #
-- #                                                                          #
-- ############################################################################
--
-- ----------------------------------------------------------------------------
-- HOW TO READ AND RUN THIS FILE
-- ----------------------------------------------------------------------------
-- The file follows the lab manual task by task, in the manual's own order:
--
--   SECTION 0 ....... Clean start (drop and recreate the database)
--   SECTION 1 ....... TASK 1 - Database design and implementation
--                     1.1 Tables      1.2 Sample data      1.3 Verification
--   SECTION 2 ....... TASK 2 - Normalization (1NF, 2NF, 3NF) demonstrated live
--   SECTION 3 ....... TASK 3 - The four JOIN queries
--   SECTION 4 ....... TASK 4 - The VIEW
--   SECTION 5 ....... TASK 5 - The TRIGGER (required by the submission
--                              requirements and by the marking rubric)
--   SECTION 6 ....... TASK 6 - The STORED PROCEDURE
--   SECTION 7 ....... TASK 7 - Optimization analysis
--   SECTION 8 ....... End-to-end demonstration and testing
--
-- Run it top to bottom the first time:
--       mysql -u root -p < CarRental_OpenEndedLab.sql
-- or open it in MySQL Workbench and execute one section at a time, taking a
-- screenshot after each section for the report.
--
-- NAMING CONVENTION used throughout:
--       tbl columns  PascalCase        e.g. RentalDate
--       constraints  pk_ / fk_ / chk_  e.g. fk_rental_vehicle
--       triggers     trg_<table>_<when>
--       procedures   sp_<Action>
--       view         vw_<Subject>
-- ############################################################################


-- ############################################################################
-- SECTION 0 | CLEAN START
-- ############################################################################

DROP DATABASE IF EXISTS carrental_db;

CREATE DATABASE carrental_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE carrental_db;


-- ############################################################################
-- SECTION 1 | TASK 1 - DATABASE DESIGN AND IMPLEMENTATION
-- ----------------------------------------------------------------------------
-- Tables: Customer, VehicleCategory, Vehicle, Rental, Payment
-- Relationships: VehicleCategory 1-* Vehicle, Customer 1-* Rental, Vehicle 1-* Rental, Rental 1-* Payment
-- Design decisions explained in README §2
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 1.1 TABLES
-- ----------------------------------------------------------------------------

-- Parent table 1: the people who rent cars.
CREATE TABLE Customer (
    CustomerID    INT             AUTO_INCREMENT PRIMARY KEY,
    FullName      VARCHAR(60)     NOT NULL,
    CNIC          CHAR(15)        NOT NULL UNIQUE,   -- 35201-1234567-1
    Phone         VARCHAR(15)     NOT NULL UNIQUE,   -- one account per number
    Email         VARCHAR(60)     NULL     UNIQUE,   -- optional, still unique
    City          VARCHAR(30)     NULL,
    LicenseNumber VARCHAR(20)     NOT NULL UNIQUE,   -- legally required to rent
    RegisteredOn  DATE            NOT NULL DEFAULT (CURRENT_DATE),

    CONSTRAINT chk_customer_cnic CHECK (CHAR_LENGTH(CNIC) = 15)
) ENGINE = InnoDB;

-- Parent table 2: the vehicle classes and their guideline tariff.
CREATE TABLE VehicleCategory (
    CategoryID      INT           AUTO_INCREMENT PRIMARY KEY,
    CategoryName    VARCHAR(20)   NOT NULL UNIQUE,   -- Economy, Sedan, SUV, Van
    ReferenceRate   DECIMAL(8,2)  NOT NULL,          -- guideline PKR per day
    SeatingCapacity TINYINT       NOT NULL,

    CONSTRAINT chk_category_rate  CHECK (ReferenceRate > 0),
    CONSTRAINT chk_category_seats CHECK (SeatingCapacity BETWEEN 2 AND 20)
) ENGINE = InnoDB;

-- The fleet. RegistrationNo is the real-world key; VehicleID is the surrogate
-- key used by the foreign keys so that a re-registered plate does not break
-- historical rentals.
CREATE TABLE Vehicle (
    VehicleID      INT            AUTO_INCREMENT PRIMARY KEY,
    RegistrationNo VARCHAR(15)    NOT NULL UNIQUE,
    Make           VARCHAR(25)    NOT NULL,
    Model          VARCHAR(30)    NOT NULL,
    ModelYear      SMALLINT       NOT NULL,
    CategoryID     INT            NOT NULL,
    DailyRate      DECIMAL(8,2)   NOT NULL,          -- actual rate of THIS car
    Status         ENUM('Available','Rented','Maintenance')
                                  NOT NULL DEFAULT 'Available',
    Odometer       INT            NOT NULL DEFAULT 0,

    CONSTRAINT fk_vehicle_category FOREIGN KEY (CategoryID)
        REFERENCES VehicleCategory(CategoryID),
    CONSTRAINT chk_vehicle_rate CHECK (DailyRate > 0),
    CONSTRAINT chk_vehicle_year CHECK (ModelYear BETWEEN 1990 AND 2100),
    CONSTRAINT chk_vehicle_odo  CHECK (Odometer >= 0)
) ENGINE = InnoDB;

-- The rental transaction. ReturnDate IS NULL means the car is still out.
CREATE TABLE Rental (
    RentalID      INT             AUTO_INCREMENT PRIMARY KEY,
    CustomerID    INT             NOT NULL,
    VehicleID     INT             NOT NULL,
    RentalDate    DATE            NOT NULL,
    DueDate       DATE            NOT NULL,          -- agreed return date
    ReturnDate    DATE            NULL,              -- NULL = not returned yet
    DailyRate     DECIMAL(8,2)    NOT NULL,          -- agreed price (snapshot)
    LateFeePerDay DECIMAL(8,2)    NOT NULL DEFAULT 0,-- penalty  (snapshot)
    TotalCharge   DECIMAL(10,2)   NULL,              -- computed on return
    CreatedAt     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_rental_customer FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID),
    CONSTRAINT fk_rental_vehicle FOREIGN KEY (VehicleID)
        REFERENCES Vehicle(VehicleID),
    CONSTRAINT chk_rental_due    CHECK (DueDate >= RentalDate),
    CONSTRAINT chk_rental_return CHECK (ReturnDate IS NULL OR ReturnDate >= RentalDate),
    CONSTRAINT chk_rental_rate   CHECK (DailyRate > 0),
    CONSTRAINT chk_rental_late   CHECK (LateFeePerDay >= 0),
    CONSTRAINT chk_rental_total  CHECK (TotalCharge IS NULL OR TotalCharge >= 0)
) ENGINE = InnoDB;

-- Money received against a rental. ON DELETE CASCADE because a payment has no
-- meaning once its rental is gone.
CREATE TABLE Payment (
    PaymentID   INT              AUTO_INCREMENT PRIMARY KEY,
    RentalID    INT              NOT NULL,
    PaymentDate DATE             NOT NULL DEFAULT (CURRENT_DATE),
    Amount      DECIMAL(10,2)    NOT NULL,
    Method      ENUM('Cash','Card','Bank Transfer','Mobile Wallet')
                                 NOT NULL DEFAULT 'Cash',
    Reference   VARCHAR(40)      NULL,               -- receipt / transaction id

    CONSTRAINT fk_payment_rental FOREIGN KEY (RentalID)
        REFERENCES Rental(RentalID) ON DELETE CASCADE,
    CONSTRAINT chk_payment_amount CHECK (Amount > 0)
) ENGINE = InnoDB;


-- ----------------------------------------------------------------------------
-- 1.2 SAMPLE DATA
-- ----------------------------------------------------------------------------
-- The data is deliberately chosen so that every later query has something real
-- to show:
--     * two customers who have never rented        -> Q2 and Q4 (LEFT JOIN)
--     * one car that has never been rented         -> Q3
--     * one car in the workshop                    -> Q3 and the trigger test
--     * three cars out on rental right now         -> Q3, the view, the trigger
--     * three late returns                         -> the charge calculation
--     * one part-paid invoice                      -> the view's Balance column
-- ----------------------------------------------------------------------------

INSERT INTO VehicleCategory (CategoryName, ReferenceRate, SeatingCapacity) VALUES
('Economy',  4500.00,  4),
('Sedan',    6500.00,  5),
('SUV',     12000.00,  7),
('Van',     12000.00, 12);

INSERT INTO Customer (FullName, CNIC, Phone, Email, City, LicenseNumber, RegisteredOn) VALUES
('Ali Khan',      '35201-1234567-1', '0300-1234567', 'ali.khan@gmail.com',    'Lahore',       'LHR-DL-33421', '2025-11-02'),
('Sara Iqbal',    '35202-7654321-8', '0321-7654321', 'sara.iqbal@gmail.com',  'Lahore',       'LHR-DL-51220', '2025-12-14'),
('Bilal Ahmed',   '42101-9988776-5', '0333-9988776', NULL,                    'Karachi',      'KHI-DL-19087', '2026-01-08'),
('Fatima Sheikh', '61101-4455667-2', '0345-4455667', 'f.sheikh@outlook.com',  'Islamabad',    'ISB-DL-72310', '2026-01-27'),
('Usman Tariq',   '61101-1122334-9', '0301-1122334', 'usman.t@gmail.com',     'Islamabad',    'ISB-DL-66015', '2026-02-19'),
('Ayesha Noor',   '42201-5566778-4', '0311-5566778', 'ayesha.noor@gmail.com', 'Karachi',      'KHI-DL-44872', '2026-03-05'),
('Zain Abbas',    '35201-3344556-7', '0322-3344556', NULL,                    'Lahore',       'LHR-DL-90114', '2026-08-21'),
('Hira Yousaf',   '81101-2233445-6', '0344-2233445', 'hira.y@gmail.com',      'Muzaffarabad', 'AJK-DL-10233', '2026-09-10');

-- Vehicles 5, 6 and 8 are already out (they have open rentals below), vehicle 9
-- is in the workshop. From SECTION 5 onwards the triggers maintain this column
-- automatically; here it is set by hand because the triggers do not exist yet.
INSERT INTO Vehicle (RegistrationNo, Make, Model, ModelYear, CategoryID, DailyRate, Status, Odometer) VALUES
('LEB-4521', 'Toyota', 'Corolla',      2021, 2,  6500.00, 'Available',    68400),
('LEA-7788', 'Honda',  'City',         2020, 2,  6000.00, 'Available',    82150),
('KHI-3092', 'Suzuki', 'Cultus',       2019, 1,  4000.00, 'Available',    95600),
('ISB-1145', 'Suzuki', 'Alto',         2022, 1,  4500.00, 'Available',    41200),
('LEC-9001', 'Toyota', 'Fortuner',     2021, 3, 14000.00, 'Rented',       53900),
('KHI-6612', 'Kia',    'Sportage',     2022, 3, 11000.00, 'Rented',       37450),
('ISB-8834', 'Toyota', 'Hiace',        2018, 4, 12000.00, 'Available',   128700),
('LEB-2210', 'Honda',  'Civic',        2023, 2,  8500.00, 'Rented',       19800),
('KHI-4455', 'Suzuki', 'Wagon R',      2020, 1,  4200.00, 'Maintenance',  73300),
('ISB-3377', 'Toyota', 'Land Cruiser', 2019, 3, 25000.00, 'Available',    61050);

-- Completed rentals. TotalCharge = chargeable days x DailyRate
--                                + late days x LateFeePerDay
INSERT INTO Rental (CustomerID, VehicleID, RentalDate, DueDate, ReturnDate, DailyRate, LateFeePerDay, TotalCharge) VALUES
(1, 1, '2026-06-01', '2026-06-04', '2026-06-04',  6500.00, 1625.00,  19500.00),
(2, 3, '2026-06-10', '2026-06-12', '2026-06-13',  4000.00, 1000.00,  13000.00),  -- 1 day late
(3, 2, '2026-06-15', '2026-06-20', '2026-06-20',  6000.00, 1500.00,  30000.00),
(4, 5, '2026-07-01', '2026-07-05', '2026-07-05', 14000.00, 3500.00,  56000.00),
(1, 4, '2026-07-08', '2026-07-10', '2026-07-10',  4500.00, 1125.00,   9000.00),
(5, 7, '2026-07-15', '2026-07-22', '2026-07-24', 12000.00, 3000.00, 114000.00),  -- 2 days late
(6, 6, '2026-08-01', '2026-08-04', '2026-08-04', 11000.00, 2750.00,  33000.00),
(2, 8, '2026-08-05', '2026-08-09', '2026-08-09',  8500.00, 2125.00,  34000.00),
(3, 1, '2026-08-12', '2026-08-15', '2026-08-16',  6500.00, 1625.00,  27625.00),  -- 1 day late
(1, 2, '2026-09-05', '2026-09-08', '2026-09-08',  6000.00, 1500.00,  18000.00);

-- Rentals that are still running (no ReturnDate, no TotalCharge yet).
INSERT INTO Rental (CustomerID, VehicleID, RentalDate, DueDate, DailyRate, LateFeePerDay) VALUES
(4, 5, '2026-09-16', '2026-09-20', 14000.00, 3500.00),
(6, 8, '2026-09-17', '2026-09-19',  8500.00, 2125.00),
(5, 6, '2026-09-18', '2026-09-25', 11000.00, 2750.00);

INSERT INTO Payment (RentalID, PaymentDate, Amount, Method, Reference) VALUES
( 1, '2026-06-04',  19500.00, 'Card',          'RCPT-1001'),
( 2, '2026-06-13',  13000.00, 'Cash',          'RCPT-1002'),
( 3, '2026-06-20',  30000.00, 'Bank Transfer', 'TXN-778120'),
( 4, '2026-07-05',  56000.00, 'Card',          'RCPT-1004'),
( 5, '2026-07-10',   9000.00, 'Cash',          'RCPT-1005'),
( 6, '2026-07-24', 100000.00, 'Bank Transfer', 'TXN-881344'),  -- part payment
( 7, '2026-08-04',  33000.00, 'Card',          'RCPT-1007'),
( 8, '2026-08-09',  34000.00, 'Mobile Wallet', 'JC-559021'),
( 9, '2026-08-16',  27625.00, 'Cash',          'RCPT-1009'),
(10, '2026-09-08',  18000.00, 'Card',          'RCPT-1010'),
(11, '2026-09-16',  30000.00, 'Card',          'RCPT-1011');  -- advance, still open


-- ----------------------------------------------------------------------------
-- 1.3 VERIFICATION  (screenshot 1)
-- ----------------------------------------------------------------------------

-- Structure of the tables.
DESCRIBE Customer;
DESCRIBE VehicleCategory;
DESCRIBE Vehicle;
DESCRIBE Rental;
DESCRIBE Payment;

-- How many rows landed in each table.
SELECT 'Customer' AS TableName, COUNT(*) AS TotalRows FROM Customer
UNION ALL SELECT 'VehicleCategory', COUNT(*) FROM VehicleCategory
UNION ALL SELECT 'Vehicle',         COUNT(*) FROM Vehicle
UNION ALL SELECT 'Rental',          COUNT(*) FROM Rental
UNION ALL SELECT 'Payment',         COUNT(*) FROM Payment;

-- The fleet, grouped by availability.
SELECT VehicleID, RegistrationNo, CONCAT(Make,' ',Model) AS Vehicle, Status
FROM Vehicle
ORDER BY Status, RegistrationNo;

-- Proof that the CHECK constraints really work: this UPDATE must fail with
-- "Check constraint 'chk_vehicle_rate' is violated".
-- UPDATE Vehicle SET DailyRate = -500 WHERE VehicleID = 1;

-- Vehicle-status consistency verification: ensure Vehicle.Status matches
-- the actual open-rental state. Expected result: empty set (no inconsistencies).
SELECT
    v.VehicleID,
    v.RegistrationNo,
    v.Status,
    COUNT(r.RentalID) AS OpenRentals
FROM Vehicle v
LEFT JOIN Rental r
    ON v.VehicleID = r.VehicleID
   AND r.ReturnDate IS NULL
GROUP BY v.VehicleID, v.RegistrationNo, v.Status
HAVING
    (v.Status = 'Rented' AND COUNT(r.RentalID) = 0)
    OR
    (v.Status <> 'Rented' AND COUNT(r.RentalID) > 0);


-- ############################################################################
-- SECTION 2 | TASK 2 - NORMALIZATION (1NF -> 2NF -> 3NF)
-- ----------------------------------------------------------------------------
-- The manual gives the company's current flat record:
--
--   RentalID | CustomerName | CustomerPhone | VehicleNumber | VehicleModel |
--   DailyRate | RentalDate | ReturnDate | PaymentAmount
--
-- To make the analysis concrete rather than theoretical, the un-normalized
-- table is actually built below and queried, so the redundancy and the three
-- anomalies can be SEEN. It is dropped again at the end of this section; the
-- 3NF result of this analysis is the schema already created in SECTION 1.
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 2.1 UN-NORMALIZED TABLE (UNF) - flat record from manual
-- ----------------------------------------------------------------------------
CREATE TABLE Rental_UNF (
    RentalID      VARCHAR(10),
    CustomerName  VARCHAR(60),
    CustomerPhone VARCHAR(15),
    VehicleNumber VARCHAR(15),
    VehicleModel  VARCHAR(40),
    DailyRate     DECIMAL(8,2),
    RentalDate    DATE,
    ReturnDate    DATE,
    PaymentAmount VARCHAR(40)
);

INSERT INTO Rental_UNF VALUES
('R001','Ali Khan',   '0300-1234567','ABC-123','Toyota Corolla',5000,'2026-09-01','2026-09-04','15000'),
('R002','Ali Khan',   '0300-1234567','XYZ-987','Honda City',    4500,'2026-09-06','2026-09-08','9000'),
('R003','Sara Iqbal', '0321-7654321','ABC-123','Toyota Corolla',5000,'2026-09-10','2026-09-12','5000 + 5000'),
('R004','Ali Khan',   '0300-1234567','ABC-123','Toyota Corolla',5000,'2026-09-14','2026-09-16','10000');

-- 2.1.1 REDUNDANCY: customer facts repeated
SELECT CustomerName, CustomerPhone, COUNT(*) AS TimesRepeated
FROM Rental_UNF
GROUP BY CustomerName, CustomerPhone;

-- 2.1.2 REDUNDANCY: vehicle facts repeated
SELECT VehicleNumber, VehicleModel, DailyRate, COUNT(*) AS TimesRepeated
FROM Rental_UNF
GROUP BY VehicleNumber, VehicleModel, DailyRate;

-- 2.1.3 ANOMALIES: INSERT, UPDATE, DELETE problems (see README §4 for details)

-- ----------------------------------------------------------------------------
-- 2.2 FIRST NORMAL FORM (1NF)
-- ----------------------------------------------------------------------------
-- FIX: Split repeating payments, introduce PaymentID, composite PK (RentalID, PaymentID)
-- RESOLVED: Atomic values, no repeating groups
-- REMAINING: Partial dependencies

-- DEMONSTRATION: Create and populate Rental_1NF to show the structure
CREATE TABLE Rental_1NF (
    RentalID      VARCHAR(10),
    PaymentID     VARCHAR(10),
    CustomerName  VARCHAR(60),
    CustomerPhone VARCHAR(15),
    VehicleNumber VARCHAR(15),
    VehicleModel  VARCHAR(40),
    DailyRate     DECIMAL(8,2),
    RentalDate    DATE,
    ReturnDate    DATE,
    PaymentAmount DECIMAL(10,2),
    PRIMARY KEY (RentalID, PaymentID)
);

INSERT INTO Rental_1NF VALUES
('R001','P001','Ali Khan',   '0300-1234567','ABC-123','Toyota Corolla',5000,'2026-09-01','2026-09-04',15000),
('R002','P002','Ali Khan',   '0300-1234567','XYZ-987','Honda City',    4500,'2026-09-06','2026-09-08', 9000),
('R003','P003','Sara Iqbal', '0321-7654321','ABC-123','Toyota Corolla',5000,'2026-09-10','2026-09-12', 5000),
('R003','P004','Sara Iqbal', '0321-7654321','ABC-123','Toyota Corolla',5000,'2026-09-10','2026-09-12', 5000),
('R004','P005','Ali Khan',   '0300-1234567','ABC-123','Toyota Corolla',5000,'2026-09-14','2026-09-16',10000);

-- Display Rental_1NF structure and data
SELECT 'Rental_1NF Table Structure:' AS Info;
DESCRIBE Rental_1NF;
SELECT 'Rental_1NF Sample Data:' AS Info;
SELECT * FROM Rental_1NF ORDER BY RentalID, PaymentID;

-- ----------------------------------------------------------------------------
-- 2.3 SECOND NORMAL FORM (2NF)
-- ----------------------------------------------------------------------------
-- FIX: Separate Rental and Payment to remove partial dependencies
-- RESOLVED: Rental details stored once
-- REMAINING: Transitive dependencies

-- DEMONSTRATION: Create and populate Rental_2NF and Payment to show the 2NF structure
CREATE TABLE Rental_2NF (
    RentalID      VARCHAR(10) PRIMARY KEY,
    CustomerName  VARCHAR(60),
    CustomerPhone VARCHAR(15),
    VehicleNumber VARCHAR(15),
    VehicleModel  VARCHAR(40),
    DailyRate     DECIMAL(8,2),
    RentalDate    DATE,
    ReturnDate    DATE
);

CREATE TABLE Payment_2NF (
    PaymentID     VARCHAR(10) PRIMARY KEY,
    RentalID      VARCHAR(10),
    PaymentDate   DATE,
    Amount        DECIMAL(10,2),
    Method        VARCHAR(20),
    Reference     VARCHAR(40),
    FOREIGN KEY (RentalID) REFERENCES Rental_2NF(RentalID)
);

INSERT INTO Rental_2NF VALUES
('R001','Ali Khan',   '0300-1234567','ABC-123','Toyota Corolla',5000,'2026-09-01','2026-09-04'),
('R002','Ali Khan',   '0300-1234567','XYZ-987','Honda City',    4500,'2026-09-06','2026-09-08'),
('R003','Sara Iqbal', '0321-7654321','ABC-123','Toyota Corolla',5000,'2026-09-10','2026-09-12'),
('R004','Ali Khan',   '0300-1234567','ABC-123','Toyota Corolla',5000,'2026-09-14','2026-09-16');

INSERT INTO Payment_2NF VALUES
('P001','R001','2026-09-04',15000,'Cash','RCPT-1001'),
('P002','R002','2026-09-08', 9000,'Card','RCPT-1002'),
('P003','R003','2026-09-10', 5000,'Bank Transfer','TXN-778120'),
('P004','R003','2026-09-12', 5000,'Bank Transfer','TXN-778121'),
('P005','R004','2026-09-16',10000,'Card','RCPT-1004');

-- Display Rental_2NF and Payment_2NF structure and data
SELECT 'Rental_2NF Table Structure:' AS Info;
DESCRIBE Rental_2NF;
SELECT 'Rental_2NF Sample Data:' AS Info;
SELECT * FROM Rental_2NF ORDER BY RentalID;

SELECT 'Payment_2NF Table Structure:' AS Info;
DESCRIBE Payment_2NF;
SELECT 'Payment_2NF Sample Data:' AS Info;
SELECT * FROM Payment_2NF ORDER BY PaymentID;

-- ----------------------------------------------------------------------------
-- 2.4 THIRD NORMAL FORM (3NF)
-- ----------------------------------------------------------------------------
-- FIX: Separate Customer, Vehicle, VehicleCategory into independent relations
-- RESOLVED: No transitive dependencies
-- RESULT: Five tables matching SECTION 1

-- DEMONSTRATION: Create and populate 3NF tables to show the final normalized structure
CREATE TABLE Customer_3NF (
    CustomerID    INT PRIMARY KEY,
    FullName      VARCHAR(60),
    CNIC          CHAR(15),
    Phone         VARCHAR(15),
    Email         VARCHAR(60),
    City          VARCHAR(30),
    LicenseNumber VARCHAR(20)
);

CREATE TABLE VehicleCategory_3NF (
    CategoryID      INT PRIMARY KEY,
    CategoryName    VARCHAR(20),
    ReferenceRate   DECIMAL(8,2),
    SeatingCapacity TINYINT
);

CREATE TABLE Vehicle_3NF (
    VehicleID      INT PRIMARY KEY,
    RegistrationNo VARCHAR(15),
    Make           VARCHAR(25),
    Model          VARCHAR(30),
    ModelYear      SMALLINT,
    CategoryID     INT,
    DailyRate      DECIMAL(8,2),
    Status         VARCHAR(15),
    FOREIGN KEY (CategoryID) REFERENCES VehicleCategory_3NF(CategoryID)
);

CREATE TABLE Rental_3NF (
    RentalID      INT PRIMARY KEY,
    CustomerID    INT,
    VehicleID     INT,
    RentalDate    DATE,
    ReturnDate    DATE,
    DailyRate     DECIMAL(8,2),
    TotalCharge   DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customer_3NF(CustomerID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicle_3NF(VehicleID)
);

CREATE TABLE Payment_3NF (
    PaymentID   INT PRIMARY KEY,
    RentalID    INT,
    PaymentDate DATE,
    Amount      DECIMAL(10,2),
    Method      VARCHAR(20),
    Reference   VARCHAR(40),
    FOREIGN KEY (RentalID) REFERENCES Rental_3NF(RentalID)
);

INSERT INTO VehicleCategory_3NF VALUES
(1, 'Economy', 4500.00, 4),
(2, 'Sedan', 6500.00, 5);

INSERT INTO Customer_3NF VALUES
(1, 'Ali Khan', '35201-1234567-1', '0300-1234567', 'ali.khan@gmail.com', 'Lahore', 'LHR-DL-33421'),
(2, 'Sara Iqbal', '35202-7654321-8', '0321-7654321', 'sara.iqbal@gmail.com', 'Lahore', 'LHR-DL-51220');

INSERT INTO Vehicle_3NF VALUES
(1, 'ABC-123', 'Toyota', 'Corolla', 2021, 2, 5000, 'Available'),
(2, 'XYZ-987', 'Honda', 'City', 2020, 2, 4500, 'Available');

INSERT INTO Rental_3NF VALUES
(1, 1, 1, '2026-09-01', '2026-09-04', 5000, 15000),
(2, 1, 2, '2026-09-06', '2026-09-08', 4500, 9000),
(3, 2, 1, '2026-09-10', '2026-09-12', 5000, 10000);

INSERT INTO Payment_3NF VALUES
(1, 1, '2026-09-04', 15000, 'Cash', 'RCPT-1001'),
(2, 2, '2026-09-08', 9000, 'Card', 'RCPT-1002'),
(3, 3, '2026-09-10', 5000, 'Bank Transfer', 'TXN-778120'),
(4, 3, '2026-09-12', 5000, 'Bank Transfer', 'TXN-778121');

-- Display all 3NF table structures and data
SELECT 'VehicleCategory_3NF Table Structure:' AS Info;
DESCRIBE VehicleCategory_3NF;
SELECT 'VehicleCategory_3NF Sample Data:' AS Info;
SELECT * FROM VehicleCategory_3NF;

SELECT 'Customer_3NF Table Structure:' AS Info;
DESCRIBE Customer_3NF;
SELECT 'Customer_3NF Sample Data:' AS Info;
SELECT * FROM Customer_3NF;

SELECT 'Vehicle_3NF Table Structure:' AS Info;
DESCRIBE Vehicle_3NF;
SELECT 'Vehicle_3NF Sample Data:' AS Info;
SELECT * FROM Vehicle_3NF;

SELECT 'Rental_3NF Table Structure:' AS Info;
DESCRIBE Rental_3NF;
SELECT 'Rental_3NF Sample Data:' AS Info;
SELECT * FROM Rental_3NF;

SELECT 'Payment_3NF Table Structure:' AS Info;
DESCRIBE Payment_3NF;
SELECT 'Payment_3NF Sample Data:' AS Info;
SELECT * FROM Payment_3NF;

-- Clean up demonstration tables
DROP TABLE IF EXISTS Payment_3NF, Rental_3NF, Vehicle_3NF, Customer_3NF, VehicleCategory_3NF;
DROP TABLE IF EXISTS Payment_2NF, Rental_2NF;
DROP TABLE IF EXISTS Rental_1NF;
--
-- WHY Rental.DailyRate IS NOT A 3NF VIOLATION
--   It looks like a copy of Vehicle.DailyRate, but the two mean different
--   things: Vehicle.DailyRate is the current tariff, Rental.DailyRate is the
--   agreed price of that one contract. It depends on RentalID alone, so there
--   is no transitive dependency and the design stays in 3NF.

-- ----------------------------------------------------------------------------
-- 2.5 PROOF THAT THE ANOMALIES ARE GONE
-- ----------------------------------------------------------------------------

-- INSERT anomaly solved: a car can be registered before anyone rents it.
-- (Vehicle 10, the Land Cruiser, has never been rented and exists happily.)
SELECT v.RegistrationNo, CONCAT(v.Make,' ',v.Model) AS Vehicle, COUNT(r.RentalID) AS TimesRented
FROM Vehicle v
LEFT JOIN Rental r ON v.VehicleID = r.VehicleID
GROUP BY v.VehicleID, v.RegistrationNo, v.Make, v.Model
HAVING TimesRented = 0;

-- UPDATE anomaly solved: a phone number lives in exactly one row.
SELECT COUNT(*) AS RowsToEditWhenAliChangesHisPhone
FROM Customer
WHERE FullName = 'Ali Khan';

-- DELETE anomaly solved: customers exist independently of their rentals.
SELECT c.FullName, COUNT(r.RentalID) AS Rentals
FROM Customer c
LEFT JOIN Rental r ON c.CustomerID = r.CustomerID
GROUP BY c.CustomerID, c.FullName
HAVING Rentals = 0;

-- The demonstration table has served its purpose.
DROP TABLE Rental_UNF;


-- ############################################################################
-- SECTION 3 | TASK 3 - JOIN QUERIES
-- ----------------------------------------------------------------------------
-- Q1: Rental details (INNER JOIN - all rentals have customer and vehicle)
-- ----------------------------------------------------------------------------
SELECT r.RentalID,
       c.FullName                   AS CustomerName,
       v.RegistrationNo             AS VehicleNumber,
       CONCAT(v.Make, ' ', v.Model) AS VehicleModel,
       r.RentalDate,
       r.ReturnDate
FROM Rental r
INNER JOIN Customer c ON r.CustomerID = c.CustomerID
INNER JOIN Vehicle  v ON r.VehicleID  = v.VehicleID
ORDER BY r.RentalID;

-- ----------------------------------------------------------------------------
-- Q2: All customers with rentals (LEFT JOIN - include non-renters)
-- ----------------------------------------------------------------------------
SELECT c.CustomerID,
       c.FullName                   AS CustomerName,
       v.RegistrationNo             AS VehicleNumber,
       CONCAT(v.Make, ' ', v.Model) AS VehicleModel,
       r.RentalDate
FROM Customer c
LEFT JOIN Rental  r ON c.CustomerID = r.CustomerID
LEFT JOIN Vehicle v ON r.VehicleID  = v.VehicleID
ORDER BY c.FullName, r.RentalDate;

-- ----------------------------------------------------------------------------
-- Q3: All vehicles with current rentals (LEFT JOIN - include unrented)
-- ----------------------------------------------------------------------------
SELECT v.RegistrationNo             AS VehicleNumber,
       CONCAT(v.Make, ' ', v.Model) AS VehicleModel,
       v.Status,
       c.FullName                   AS RentedBy,
       r.RentalDate,
       r.DueDate
FROM Vehicle v
LEFT JOIN Rental   r ON v.VehicleID  = r.VehicleID
                    AND r.ReturnDate IS NULL
LEFT JOIN Customer c ON r.CustomerID = c.CustomerID
ORDER BY v.RegistrationNo;

-- ----------------------------------------------------------------------------
-- Q4: Rental count per customer (LEFT JOIN + COUNT - include zero rentals)
-- ----------------------------------------------------------------------------
SELECT c.CustomerID,
       c.FullName                      AS CustomerName,
       c.City,
       COUNT(r.RentalID)               AS TotalRentals,
       COALESCE(SUM(r.TotalCharge), 0) AS TotalBilled
FROM Customer c
LEFT JOIN Rental r ON c.CustomerID = r.CustomerID
GROUP BY c.CustomerID, c.FullName, c.City
ORDER BY TotalRentals DESC, c.FullName;


-- ############################################################################
-- SECTION 4 | TASK 4 - VIEW
-- ----------------------------------------------------------------------------
-- vw_RentalReport: Consolidated rental report (see README §6 for justification)
-- ############################################################################

CREATE VIEW vw_RentalReport AS
SELECT r.RentalID,
       c.FullName                    AS CustomerName,
       c.Phone,
       v.RegistrationNo              AS VehicleNumber,
       CONCAT(v.Make, ' ', v.Model)  AS VehicleModel,
       cat.CategoryName,
       r.RentalDate,
       r.DueDate,
       r.ReturnDate,
       CASE WHEN r.ReturnDate IS NULL THEN 'Open' ELSE 'Closed' END AS RentalStatus,
       DATEDIFF(COALESCE(r.ReturnDate, CURRENT_DATE), r.RentalDate)  AS DaysOut,
       r.DailyRate,
       r.TotalCharge,
       COALESCE(p.AmountPaid, 0)     AS AmountPaid,
       CASE WHEN r.ReturnDate IS NOT NULL
            THEN r.TotalCharge - COALESCE(p.AmountPaid, 0)
       END                           AS Balance
FROM Rental r
INNER JOIN Customer        c   ON r.CustomerID = c.CustomerID
INNER JOIN Vehicle         v   ON r.VehicleID  = v.VehicleID
INNER JOIN VehicleCategory cat ON v.CategoryID = cat.CategoryID
LEFT JOIN (
        SELECT RentalID, SUM(Amount) AS AmountPaid
        FROM Payment
        GROUP BY RentalID
     ) p ON p.RentalID = r.RentalID;

-- 4.1 The full consolidated report.
SELECT * FROM vw_RentalReport ORDER BY RentalID;

-- 4.2 Report the manager asks for every morning: what is out, and when is it due?
SELECT RentalID, CustomerName, Phone, VehicleNumber, DueDate
FROM vw_RentalReport
WHERE RentalStatus = 'Open'
ORDER BY DueDate;

-- 4.3 Report accounts asks for: which closed rentals still owe money?
SELECT RentalID, CustomerName, VehicleNumber, TotalCharge, AmountPaid, Balance
FROM vw_RentalReport
WHERE Balance > 0;


-- ############################################################################
-- SECTION 5 | TASK 5 - TRIGGER
-- ----------------------------------------------------------------------------
-- Business rule: Vehicle cannot be double-booked or rented while in maintenance
-- Triggers: BEFORE INSERT (check), BEFORE UPDATE (prevent vehicle change), AFTER INSERT (set Rented), AFTER UPDATE (set Available)
-- See README §7 for details
-- ############################################################################

DELIMITER $$

-- 5.1 BEFORE INSERT: Check availability and maintenance status
CREATE TRIGGER trg_rental_before_insert
BEFORE INSERT ON Rental
FOR EACH ROW
BEGIN
    DECLARE v_open_count INT;
    DECLARE v_status     VARCHAR(15);

    -- Only live bookings are checked. A back-dated entry that already carries
    -- a ReturnDate is history and cannot clash with anything.
    IF NEW.ReturnDate IS NULL THEN

        SELECT COUNT(*) INTO v_open_count
        FROM Rental
        WHERE VehicleID  = NEW.VehicleID
          AND ReturnDate IS NULL;

        IF v_open_count > 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Vehicle is already on an open rental.';
        END IF;

        SELECT Status INTO v_status
        FROM Vehicle
        WHERE VehicleID = NEW.VehicleID;

        IF v_status = 'Maintenance' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Vehicle is under maintenance and cannot be rented.';
        END IF;

    END IF;
END$$

-- 5.1.1 BEFORE UPDATE: Prevent changing assigned vehicle
CREATE TRIGGER trg_rental_before_update
BEFORE UPDATE ON Rental
FOR EACH ROW
BEGIN
    IF OLD.VehicleID <> NEW.VehicleID THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Vehicle cannot be changed after a rental is created.';
    END IF;
END$$

-- 5.2 AFTER INSERT: Set vehicle status to Rented
CREATE TRIGGER trg_rental_after_insert
AFTER INSERT ON Rental
FOR EACH ROW
BEGIN
    IF NEW.ReturnDate IS NULL THEN
        UPDATE Vehicle
        SET Status = 'Rented'
        WHERE VehicleID = NEW.VehicleID;
    END IF;
END$$

-- 5.3 AFTER UPDATE: Set vehicle status to Available when returned
CREATE TRIGGER trg_rental_after_update
AFTER UPDATE ON Rental
FOR EACH ROW
BEGIN
    IF OLD.ReturnDate IS NULL AND NEW.ReturnDate IS NOT NULL THEN
        UPDATE Vehicle
        SET Status = 'Available'
        WHERE VehicleID = NEW.VehicleID;
    END IF;
END$$

DELIMITER ;

SHOW TRIGGERS FROM carrental_db;

-- Trigger tests are in SECTION 8.1 and 8.2.


-- ############################################################################
-- SECTION 6 | TASK 6 - STORED PROCEDURE
-- ----------------------------------------------------------------------------
-- sp_RegisterRental: Register a new rental and calculate the rental charge
-- sp_CloseRental: Close the rental, record return, apply late fee, settle outstanding amount
-- See README §8 for details
-- ############################################################################

DELIMITER $$

-- ----------------------------------------------------------------------------
-- 6.1 sp_RegisterRental
--     IN: CustomerID, VehicleID, RentalDate, DueDate
--     OUT: RentalID, EstimatedCharge
-- ----------------------------------------------------------------------------
CREATE PROCEDURE sp_RegisterRental(
    IN  p_CustomerID      INT,
    IN  p_VehicleID       INT,
    IN  p_RentalDate      DATE,
    IN  p_DueDate         DATE,
    OUT p_RentalID        INT,
    OUT p_EstimatedCharge DECIMAL(10,2)
)
BEGIN
    DECLARE v_Rate DECIMAL(8,2);
    DECLARE v_Days INT;
    DECLARE v_CustomerExists INT;

    -- Validate the customer exists before proceeding.
    SELECT COUNT(*) INTO v_CustomerExists
    FROM Customer
    WHERE CustomerID = p_CustomerID;

    IF v_CustomerExists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No such customer.';
    END IF;

    -- Validate the period before touching the database.
    IF p_DueDate < p_RentalDate THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Due date cannot be earlier than the rental date.';
    END IF;

    -- Pick up the vehicle's current tariff.
    SELECT DailyRate INTO v_Rate
    FROM Vehicle
    WHERE VehicleID = p_VehicleID;

    IF v_Rate IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No such vehicle.';
    END IF;

    -- A same-day rental is still charged as one full day.
    SET v_Days            = GREATEST(DATEDIFF(p_DueDate, p_RentalDate), 1);
    SET p_EstimatedCharge = v_Days * v_Rate;

    -- Company policy: the late fee is 25% of the daily rate, frozen here so a
    -- later policy change cannot alter an existing contract.
    INSERT INTO Rental (CustomerID, VehicleID, RentalDate, DueDate,
                        DailyRate, LateFeePerDay)
    VALUES (p_CustomerID, p_VehicleID, p_RentalDate, p_DueDate,
            v_Rate, ROUND(v_Rate * 0.25, 2));

    SET p_RentalID = LAST_INSERT_ID();
END$$

-- ----------------------------------------------------------------------------
-- 6.2 sp_CloseRental
--     IN: RentalID, ReturnDate, PaymentMethod
--     OUT: ChargeableDays, LateDays, TotalCharge, CollectedNow
-- ----------------------------------------------------------------------------
CREATE PROCEDURE sp_CloseRental(
    IN p_RentalID   INT,
    IN p_ReturnDate DATE,
    IN p_Method     VARCHAR(20)
)
BEGIN
    DECLARE v_RentalDate  DATE;
    DECLARE v_DueDate     DATE;
    DECLARE v_Returned    DATE;
    DECLARE v_Rate        DECIMAL(8,2);
    DECLARE v_LateFee     DECIMAL(8,2);
    DECLARE v_Days        INT;
    DECLARE v_LateDays    INT;
    DECLARE v_Total       DECIMAL(10,2);
    DECLARE v_Paid        DECIMAL(10,2);
    DECLARE v_Outstanding DECIMAL(10,2);

    SELECT RentalDate, DueDate, ReturnDate, DailyRate, LateFeePerDay
      INTO v_RentalDate, v_DueDate, v_Returned, v_Rate, v_LateFee
    FROM Rental
    WHERE RentalID = p_RentalID;

    -- Guard clauses.
    IF v_RentalDate IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No such rental.';
    END IF;

    IF v_Returned IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This rental is already closed.';
    END IF;

    IF p_ReturnDate < v_RentalDate THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Return date cannot be earlier than the rental date.';
    END IF;

    -- Charge calculation.
    SET v_Days     = GREATEST(DATEDIFF(p_ReturnDate, v_RentalDate), 1);
    SET v_LateDays = GREATEST(DATEDIFF(p_ReturnDate, v_DueDate),    0);
    SET v_Total    = (v_Days * v_Rate) + (v_LateDays * v_LateFee);

    -- This UPDATE fires trg_rental_after_update, which frees the vehicle.
    UPDATE Rental
    SET ReturnDate  = p_ReturnDate,
        TotalCharge = v_Total
    WHERE RentalID = p_RentalID;

    -- Settle the balance, allowing for any advance already taken.
    SELECT COALESCE(SUM(Amount), 0) INTO v_Paid
    FROM Payment
    WHERE RentalID = p_RentalID;

    SET v_Outstanding = v_Total - v_Paid;

    IF v_Outstanding > 0 THEN
        INSERT INTO Payment (RentalID, PaymentDate, Amount, Method, Reference)
        VALUES (p_RentalID, p_ReturnDate, v_Outstanding, p_Method,
                CONCAT('Settlement R', p_RentalID));
    END IF;

    -- Hand the counter clerk a receipt summary.
    SELECT p_RentalID               AS RentalID,
           v_Days                   AS ChargeableDays,
           v_LateDays               AS LateDays,
           v_Rate                   AS DailyRate,
           v_LateFee                AS LateFeePerDay,
           v_Total                  AS TotalCharge,
           v_Paid                   AS AlreadyPaid,
           GREATEST(v_Outstanding,0) AS CollectedNow;
END$$

DELIMITER ;

SHOW PROCEDURE STATUS WHERE Db = 'carrental_db';


-- ############################################################################
-- SECTION 7 | TASK 7 - OPTIMIZATION ANALYSIS
-- ----------------------------------------------------------------------------
-- 7.1 PROBLEM: Availability check and date reports lack indexes
-- 7.2 IMPACT: Table scans increase query cost as Rental grows
-- 7.3 SOLUTION: Composite index (VehicleID, ReturnDate) + RentalDate index
-- See README §9 for details
-- ############################################################################

-- 7.4 BEFORE EXPLAIN (screenshot: note type and key)
EXPLAIN SELECT COUNT(*) FROM Rental
WHERE VehicleID = 5 AND ReturnDate IS NULL;

EXPLAIN SELECT RentalID, CustomerID, TotalCharge FROM Rental
WHERE RentalDate BETWEEN '2026-08-01' AND '2026-08-31';

-- 7.5 CREATE INDEXES
CREATE INDEX idx_rental_vehicle_open ON Rental (VehicleID, ReturnDate);
CREATE INDEX idx_rental_date         ON Rental (RentalDate);

-- 7.6 AFTER EXPLAIN (screenshot: compare with before)
EXPLAIN SELECT COUNT(*) FROM Rental
WHERE VehicleID = 5 AND ReturnDate IS NULL;

EXPLAIN SELECT RentalID, CustomerID, TotalCharge FROM Rental
WHERE RentalDate BETWEEN '2026-08-01' AND '2026-08-31';

SHOW INDEX FROM Rental;

-- 7.7 NOTE: With small dataset, optimizer may still choose table scan. Benefit grows as table size increases.


-- ############################################################################
-- SECTION 8 | DEMONSTRATION AND TESTING
-- ----------------------------------------------------------------------------
-- Run these blocks one at a time and capture a screenshot of each.
-- ############################################################################

-- ----------------------------------------------------------------------------
-- 8.1 TRIGGER TEST A - the double-booking rule
--     Vehicle 5 (LEC-9001 Fortuner) is already out on rental 11.
--     EXPECTED: ERROR 1644 (45000): Vehicle is already on an open rental.
--     >>> Remove the comment markers to run it. <<<
-- ----------------------------------------------------------------------------
-- INSERT INTO Rental (CustomerID, VehicleID, RentalDate, DueDate, DailyRate)
-- VALUES (7, 5, '2026-09-19', '2026-09-21', 14000.00);

-- ----------------------------------------------------------------------------
-- 8.2 TRIGGER TEST B - the maintenance rule
--     Vehicle 9 (KHI-4455 Wagon R) is in the workshop.
--     EXPECTED: ERROR 1644 (45000): Vehicle is under maintenance and cannot
--               be rented.
--     >>> Remove the comment markers to run it. <<<
-- ----------------------------------------------------------------------------
-- INSERT INTO Rental (CustomerID, VehicleID, RentalDate, DueDate, DailyRate)
-- VALUES (7, 9, '2026-09-19', '2026-09-21', 4200.00);

-- ----------------------------------------------------------------------------
-- 8.3 STORED PROCEDURE TEST 1 - register a rental
--     Zain Abbas (customer 7), who had never rented before, books the Toyota
--     Corolla (vehicle 1) from 19 Sep to 22 Sep 2026.
--     EXPECTED: RentalID 14, estimated charge 3 x 6500 = 19500.
-- ----------------------------------------------------------------------------
CALL sp_RegisterRental(7, 1, '2026-09-19', '2026-09-22', @new_rental, @estimate);
SELECT @new_rental AS NewRentalID, @estimate AS EstimatedCharge;

-- The AFTER INSERT trigger has taken the Corolla off the available list.
SELECT RegistrationNo, Status FROM Vehicle WHERE VehicleID = 1;

-- ----------------------------------------------------------------------------
-- 8.4 STORED PROCEDURE TEST 2 - close the rental, returned one day late
--     EXPECTED: 4 chargeable days x 6500 = 26000, plus 1 late day x 1625,
--               total 27625; the Corolla becomes Available again.
-- ----------------------------------------------------------------------------
CALL sp_CloseRental(@new_rental, '2026-09-23', 'Cash');

SELECT RegistrationNo, Status FROM Vehicle WHERE VehicleID = 1;
SELECT * FROM vw_RentalReport WHERE RentalID = @new_rental;

-- ----------------------------------------------------------------------------
-- 8.5 FINAL STATE OF THE DATABASE
-- ----------------------------------------------------------------------------
SELECT 'Customer' AS TableName, COUNT(*) AS TotalRows FROM Customer
UNION ALL SELECT 'VehicleCategory', COUNT(*) FROM VehicleCategory
UNION ALL SELECT 'Vehicle',         COUNT(*) FROM Vehicle
UNION ALL SELECT 'Rental',          COUNT(*) FROM Rental
UNION ALL SELECT 'Payment',         COUNT(*) FROM Payment;

SELECT Status, COUNT(*) AS Vehicles FROM Vehicle GROUP BY Status;

-- ############################################################################
-- END OF SCRIPT
-- ############################################################################
