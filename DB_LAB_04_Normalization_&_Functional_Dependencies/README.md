# Lab 04 — Database Normalization (UNF → 1NF → 2NF → 3NF)

> **Course:** Database Systems &nbsp;|&nbsp; **Lab:** 04 &nbsp;|&nbsp; **Scenario:** Hospital Patient Visits  
> **File:** `RollNo_2024-SE-15_Normalization.sql` &nbsp;|&nbsp; **Database:** `hospital_normalization`

---

## Table of Contents

1. [What This Lab Is About](#1-what-this-lab-is-about)
2. [How to Run](#2-how-to-run)
3. [The Problem — Unnormalized Data (UNF)](#3-the-problem--unnormalized-data-unf)
4. [Stage 1 — First Normal Form (1NF)](#4-stage-1--first-normal-form-1nf)
5. [Stage 2 — Second Normal Form (2NF)](#5-stage-2--second-normal-form-2nf)
6. [Stage 3 — Third Normal Form (3NF)](#6-stage-3--third-normal-form-3nf)
7. [Final Schema Overview](#7-final-schema-overview)
8. [Verification Queries](#8-verification-queries)
9. [How 3NF Eliminates Every Anomaly](#9-how-3nf-eliminates-every-anomaly)
10. [Key Concepts Quick Reference](#10-key-concepts-quick-reference)

---

## 1. What This Lab Is About

Normalization is the process of structuring a relational database to **reduce data redundancy** and **prevent data anomalies**. This lab walks through a real-world hospital scenario where patient visit data starts as a poorly designed flat table (UNF) and is progressively decomposed into a clean, fully normalized schema (3NF).

The lab demonstrates:
- All three anomaly types (Insert, Update, Delete) in the UNF table
- Functional dependency analysis that drives each decomposition step
- Why 2NF is automatically satisfied when the primary key is a single column
- How 3NF breaks transitive dependency chains into separate master tables

**7 tables are created in total**, each serving a specific role in showing the normalization journey.

---

## 2. How to Run

**Option A — phpMyAdmin**
1. Open phpMyAdmin in your browser
2. Click the **SQL** tab
3. Paste the entire contents of `RollNo_2024-SE-15_Normalization.sql`
4. Click **Go**

**Option B — MySQL Command Line**
```bash
mysql -u root -p < RollNo_2024-SE-15_Normalization.sql
```

**Option C — MySQL Workbench**
1. Open the `.sql` file via **File → Open SQL Script**
2. Click the lightning bolt (**Execute**) button

After running, the database `hospital_normalization` will contain all 7 tables with data loaded and all verification queries printed to the results panel.

---

## 3. The Problem — Unnormalized Data (UNF)

### What the raw data looks like

The lab starts by simulating how a non-technical person might record hospital data in a spreadsheet — everything crammed into one flat table with no structure.

**Table:** `Hospital_UNF`

| VisitID | BookedDates | PatientInfo | DoctorInfo | DeptInfo | Diagnosis1 | Diagnosis2 | Fee1 | Fee2 |
|---|---|---|---|---|---|---|---|---|
| V-9001, V-9003 | 2026-04-10, 2026-04-11 | Hassan / 0300-1112233 | Dr. Imran / Cardiology | Heart Care / Dr. Tariq | Hypertension | Allergy | 2500 | 2000 |
| V-9002 | 2026-04-10 | Mehreen / 0301-4445566 | Dr. Asma / Dermatology | Skin Clinic / Dr. Asma | Eczema | NULL | 2000 | NULL |
| V-9004 | 2026-04-12 | Junaid / 0302-7778899 | Dr. Imran / Cardiology | Heart Care / Dr. Tariq | Arrhythmia | NULL | 3000 | NULL |

### Problems identified in UNF

**Non-atomic cells** — `BookedDates` holds two dates in one cell (`2026-04-10, 2026-04-11`). A single cell should hold exactly one value.

**Repeating groups** — `Diagnosis1`, `Diagnosis2`, `Fee1`, `Fee2` are the same type of data split across columns. This pattern breaks as soon as a patient has a third diagnosis.

**Composite attributes** — `PatientInfo` bundles name and phone together (`Hassan / 0300-1112233`). `DoctorInfo` bundles name and specialty. These cannot be queried or sorted individually.

**No primary key** — No column uniquely identifies each row. `VisitID` itself contains multiple IDs in one cell.

**Three data anomalies present:**

| Anomaly | What goes wrong |
|---|---|
| **Insert** | A new doctor (e.g. Dr. Zara, Neurology) cannot be added to the database without creating a patient visit for her first. Doctor information has no independent home. |
| **Update** | If Dr. Imran changes his specialty, every row containing his name inside `DoctorInfo` must be found and updated manually. Missing even one row causes inconsistency. |
| **Delete** | Deleting Junaid's visit (V-9004) permanently destroys the only record that Dr. Imran is a Cardiologist in Heart Care. |

---

## 4. Stage 1 — First Normal Form (1NF)

### Rules to satisfy 1NF
1. Every cell must hold **one atomic (single) value**
2. **No repeating groups** of columns
3. Each row must be **uniquely identifiable** — a Primary Key must exist

### Changes made from UNF to 1NF

| Problem in UNF | Fix applied in 1NF |
|---|---|
| `BookedDates` held multiple dates in one cell | Each visit gets its **own row** with one date |
| `PatientInfo` held name + phone combined | Split into `PatientName` and `PatientPhone` (separate columns) |
| `DoctorInfo` held name + specialty combined | Split into `DoctorName` and `Specialty` (separate columns) |
| `DeptInfo` held dept name + head combined | Split into `DeptName` and `DeptHead` (separate columns) |
| `Diagnosis1`, `Diagnosis2` repeating group | Collapsed into a **single** `Diagnosis` column per row |
| `Fee1`, `Fee2` repeating group | Collapsed into a **single** `Fee` column per row |
| No primary key | `VisitID` declared as `PRIMARY KEY` |

**Table:** `Hospital_1NF` — 4 clean rows, one visit per row, one value per cell

```
VisitID | VisitDate  | PatientID | PatientName | PatientPhone  | DoctorID | DoctorName | Specialty   | DeptName    | DeptHead  | Diagnosis    | Fee
V-9001  | 2026-04-10 | P-201     | Hassan      | 0300-1112233  | D-30     | Dr. Imran  | Cardiology  | Heart Care  | Dr. Tariq | Hypertension | 2500
V-9002  | 2026-04-10 | P-202     | Mehreen     | 0301-4445566  | D-31     | Dr. Asma   | Dermatology | Skin Clinic | Dr. Asma  | Eczema       | 2000
V-9003  | 2026-04-11 | P-201     | Hassan      | 0300-1112233  | D-31     | Dr. Asma   | Dermatology | Skin Clinic | Dr. Asma  | Allergy      | 2000
V-9004  | 2026-04-12 | P-203     | Junaid      | 0302-7778899  | D-30     | Dr. Imran  | Cardiology  | Heart Care  | Dr. Tariq | Arrhythmia   | 3000
```

### What is still wrong after 1NF?

The table is cleaner, but **data still repeats**:
- Hassan's name and phone appear in both V-9001 and V-9003
- Dr. Imran's name, specialty, and department appear in both V-9001 and V-9004
- `Heart Care / Dr. Tariq` appears in both rows above

These are **transitive dependencies** — columns like `PatientName` don't really describe the *visit*, they describe the *patient*. This is what 3NF will fix.

---

## 5. Stage 2 — Second Normal Form (2NF)

### Rule to satisfy 2NF
Must be in 1NF **AND** have no **partial dependency**.

> A **partial dependency** occurs when a non-key column depends on only *part* of a composite (multi-column) primary key.

### Analysis for this schema

Our primary key is `VisitID` — **a single column**. A partial dependency can only exist when the primary key is made of two or more columns, because only then can a subset of it exist.

Since `VisitID` is a single column, **no subset of it is possible**, and therefore **partial dependencies are impossible by definition**.

**Result: `Hospital_1NF` is already in 2NF.**

The lab creates `Hospital_2NF` explicitly as a separate table to:
- Show the stage clearly in the database schema
- Add named indexes (`idx_patient`, `idx_doctor`) that document the transitive dependency groups
- Serve as the source from which 3NF tables are decomposed

The remaining problems — Hassan's name repeating, Dr. Imran's info repeating — are **transitive dependencies**, which are a 3NF concern.

---

## 6. Stage 3 — Third Normal Form (3NF)

### Rule to satisfy 3NF
Must be in 2NF **AND** have no **transitive dependency**.

> A **transitive dependency** exists when a non-key column depends on another non-key column rather than directly on the primary key. The classic statement: *"Every non-prime attribute must depend on the key, the whole key, and nothing but the key."*

### Functional dependencies identified in 1NF

These were formally identified before decomposition:

```
FD1:  VisitID   →  VisitDate, PatientID, DoctorID, Diagnosis, Fee
      (these facts describe the VISIT itself)

FD2:  PatientID →  PatientName, PatientPhone
      (these facts describe the PATIENT, not the visit)

FD3:  DoctorID  →  DoctorName, Specialty, DeptName
      (these facts describe the DOCTOR, not the visit)

FD4:  DeptName  →  DeptHead
      (DeptHead describes the DEPARTMENT, not the doctor)
```

**Transitive chains eliminated:**
```
VisitID → PatientID → PatientName, PatientPhone
VisitID → DoctorID  → DoctorName, Specialty, DeptName
VisitID → DoctorID  → DeptName → DeptHead
```

### Decomposition into 4 tables

Each functional dependency becomes its own table. Tables are created in dependency order so foreign keys can be established immediately.

---

#### Table 1 — `Patient`  *(resolves FD2)*

Eliminates: `VisitID → PatientID → PatientName, PatientPhone`

`PatientName` and `PatientPhone` describe the **person**, not the hospital visit. They now live in their own table keyed by `PatientID`.

```sql
Patient (PatientID PK, PatientName, PatientPhone)
```

| PatientID | PatientName | PatientPhone |
|---|---|---|
| P-201 | Hassan | 0300-1112233 |
| P-202 | Mehreen | 0301-4445566 |
| P-203 | Junaid | 0302-7778899 |

---

#### Table 2 — `Department`  *(resolves FD4)*

Eliminates: `DoctorID → DeptName → DeptHead`

`DeptHead` describes the **department**, not the doctor. Created before `Doctor` because `Doctor` references it via foreign key.

```sql
Department (DeptName PK, DeptHead)
```

| DeptName | DeptHead |
|---|---|
| Heart Care | Dr. Tariq |
| Skin Clinic | Dr. Asma |

---

#### Table 3 — `Doctor`  *(resolves FD3)*

Eliminates: `VisitID → DoctorID → DoctorName, Specialty, DeptName`

`DoctorName` and `Specialty` describe the **doctor**, not the visit. `DeptName` stays here as a foreign key linking to `Department`.

```sql
Doctor (DoctorID PK, DoctorName, Specialty, DeptName FK→Department)
```

| DoctorID | DoctorName | Specialty | DeptName |
|---|---|---|---|
| D-30 | Dr. Imran | Cardiology | Heart Care |
| D-31 | Dr. Asma | Dermatology | Skin Clinic |

---

#### Table 4 — `Visit`  *(pure FD1)*

Only visit-specific facts remain. `PatientID` and `DoctorID` are foreign keys — they are references, not repeated descriptive data.

```sql
Visit (VisitID PK, VisitDate, PatientID FK→Patient, DoctorID FK→Doctor, Diagnosis, Fee)
```

| VisitID | VisitDate | PatientID | DoctorID | Diagnosis | Fee |
|---|---|---|---|---|---|
| V-9001 | 2026-04-10 | P-201 | D-30 | Hypertension | 2500 |
| V-9002 | 2026-04-10 | P-202 | D-31 | Eczema | 2000 |
| V-9003 | 2026-04-11 | P-201 | D-31 | Allergy | 2000 |
| V-9004 | 2026-04-12 | P-203 | D-30 | Arrhythmia | 3000 |

---

## 7. Final Schema Overview

```
hospital_normalization
│
├── Hospital_UNF      ← Stage 0: Raw flat data, all anomalies present
├── Hospital_1NF      ← Stage 1: Atomic values, PK declared
├── Hospital_2NF      ← Stage 2: 2NF confirmed (single-col PK), transitive deps noted
│
├── Patient           ← 3NF master table  (PatientID PK)
├── Department        ← 3NF master table  (DeptName PK)
├── Doctor            ← 3NF master table  (DoctorID PK, FK → Department)
└── Visit             ← 3NF fact table    (VisitID PK, FK → Patient, FK → Doctor)
```

### Relationship map

```
Department ◄──── Doctor ◄──── Visit ────► Patient
(DeptName)       (DoctorID)   (VisitID)    (PatientID)
```

**Foreign key constraints:**

| Constraint | From | To | On Update | On Delete |
|---|---|---|---|---|
| `fk_doctor_dept` | `Doctor.DeptName` | `Department.DeptName` | CASCADE | RESTRICT |
| `fk_visit_patient` | `Visit.PatientID` | `Patient.PatientID` | CASCADE | RESTRICT |
| `fk_visit_doctor` | `Visit.DoctorID` | `Doctor.DoctorID` | CASCADE | RESTRICT |

---

## 8. Verification Queries

Five queries are included at the end of the SQL file to confirm correctness.

### Query 1 — Full reconstruction
Joins all four 3NF tables back together to reproduce the original complete dataset. If the output matches `Hospital_1NF` exactly, normalization preserved all data without loss.

```sql
SELECT v.VisitID, v.VisitDate, p.PatientName, d.DoctorName,
       d.Specialty, dep.DeptName, dep.DeptHead, v.Diagnosis, v.Fee
FROM   Visit v
JOIN   Patient    p   ON v.PatientID = p.PatientID
JOIN   Doctor     d   ON v.DoctorID  = d.DoctorID
JOIN   Department dep ON d.DeptName  = dep.DeptName
ORDER BY v.VisitID;
```

### Query 2 — Row count check
Confirms that `Hospital_1NF` and `Visit` both contain exactly 4 rows. No data was lost or duplicated during decomposition.

### Query 3 — Patient total spend
Aggregates visits and fees per patient using `GROUP BY`. Demonstrates the analytical power that properly structured data enables.

### Query 4 — Revenue by department
Chains three tables (`Department → Doctor → Visit`) to calculate total revenue per department — a query that would be impossible or unreliable against the UNF table.

### Query 5 — Doctors independent of visits
Confirms that doctors exist as independent entities and can be queried without any visit records. This directly proves the Insert Anomaly is eliminated.

---

## 9. How 3NF Eliminates Every Anomaly

| Anomaly | Before (UNF) | After (3NF) |
|---|---|---|
| **Insert** | Dr. Zara (Neurology) cannot be recorded without a patient visit. Doctor info had no independent table to live in. | `INSERT INTO Department` then `INSERT INTO Doctor` independently. No visit row needed whatsoever. |
| **Update** | Changing Dr. Imran's specialty meant finding and updating every `DoctorInfo` text cell across all rows. Missing one causes permanent inconsistency. | Update **one row** in the `Doctor` table. `ON UPDATE CASCADE` propagates changes automatically. One fact, one place, one update. |
| **Delete** | Deleting Junaid's visit (V-9004) permanently destroyed Dr. Imran's specialty and department record — it existed nowhere else. | Visit rows and Doctor rows are completely separate. Deleting a visit never touches `Doctor` or `Department`. `ON DELETE RESTRICT` also prevents accidental removal of a doctor who still has active visits on record. |

---

## 10. Key Concepts Quick Reference

| Term | Definition | Example in this lab |
|---|---|---|
| **UNF** | Table with non-atomic cells, repeating groups, no PK | `Hospital_UNF` |
| **1NF** | Atomic values, no repeating groups, PK declared | `Hospital_1NF` |
| **2NF** | 1NF + no partial dependency (only relevant with composite PK) | `Hospital_2NF` — already satisfied |
| **3NF** | 2NF + no transitive dependency | `Patient`, `Department`, `Doctor`, `Visit` |
| **Functional Dependency** | Column A uniquely determines column B (A → B) | `PatientID → PatientName` |
| **Partial Dependency** | Non-key column depends on part of a composite PK | Not applicable here (single-column PK) |
| **Transitive Dependency** | A → B → C, where B is not a key | `VisitID → PatientID → PatientName` |
| **Insert Anomaly** | Cannot add data without unrelated data existing | Cannot add a doctor without a patient visit |
| **Update Anomaly** | Changing one fact requires updating many rows | Dr. Imran's specialty stored in multiple rows |
| **Delete Anomaly** | Deleting a row destroys unrelated information | Deleting a visit destroys doctor info |
| **ON DELETE RESTRICT** | Prevents deletion of a parent row referenced by child rows | Cannot delete a Doctor who has active Visits |
| **ON UPDATE CASCADE** | Automatically updates child rows when the parent key changes | Updating a DeptName propagates to Doctor |

---

*Normalization does not change what data is stored — it changes where and how it is stored. The final JOIN query in this lab proves that every piece of information from the original UNF table is fully recoverable from the 3NF schema, now without redundancy and protected against all three anomaly types.*
