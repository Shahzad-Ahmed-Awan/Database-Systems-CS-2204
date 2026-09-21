# Lab 05 — Functional Dependencies, Anomalies & 1NF

**Course:** Database Systems | **Topic:** Database Normalization
**Tools:** MySQL 8.x (Workbench or Command Line Client)
**Script:** `Lab05_Normalization_1NF.sql`
**Run order:** this file first — `Lab06_Normalization_2NF_3NF.sql` builds on the tables created here.

## Learning objectives
- Explain why unnormalized, redundant data causes insertion, update, and deletion anomalies.
- Identify functional dependencies (FDs) in a relation and determine its candidate key.
- Convert an unnormalized (UNF) relation into 1NF by removing repeating groups.

## Deliverables covered here

| # | Requirement | Scenario |
|---|---|---|
| Task 1 | FDs + insertion/update/deletion anomalies | Bookstore (lab task) |
| Task 2 | 1NF table `OrderBook_1NF`, PK stated, built in MySQL | Bookstore (lab task) |
| Deliverable 1 — 10 marks | FDs + candidate key, as SQL comments | Hospital (assessment) |
| Deliverable 2 — 15 marks | 1NF table `Visit_1NF`, schema + INSERTs | Hospital (assessment) |

## How to run
```bash
mysql -u root -p < Lab05_Normalization_1NF.sql
```
The script drops and recreates `bookstore_db` and `hospital_db`, so it's safe to re-run from scratch.

---

## Part A — Online Bookstore

**Functional dependencies**
| FD | Meaning |
|---|---|
| `OrderID → OrderDate, CustID` | one order = one date, one customer |
| `CustID → CustName, CustEmail` | one customer = one name/email |
| `BookID → BookTitle, Publisher, UnitPrice` | one book = one title/publisher/price |
| `(OrderID, BookID) → Qty` | qty depends on the pair |

Transitive: `OrderID → CustID → CustName, CustEmail` (this is what 3NF removes in Lab 06).
**Candidate key:** `(OrderID, BookID)` — closure reaches every attribute; neither column alone does.

**Anomalies**
- **Insertion** — can't catalogue a new book until it's ordered (`BookID` is half the PK).
- **Update** — Bilal's email is repeated on every one of his orders; each copy must be edited by hand.
- **Deletion** — cancelling Areeba's only order (`O-502`) erases her record entirely.

**Table created — `OrderBook_1NF`** *(PK: `OrderID, BookID`)*

| OrderID | OrderDate | CustID | CustName | CustEmail | BookID | BookTitle | Publisher | UnitPrice | Qty |
|---|---|---|---|---|---|---|---|---|---|
| O-501 | 2026-04-02 | C-11 | Bilal | bilal@x.com | B-1 | SQL Basics | Pearson | 1200.00 | 1 |
| O-501 | 2026-04-02 | C-11 | Bilal | bilal@x.com | B-2 | Python 101 | OReilly | 1500.00 | 2 |
| O-502 | 2026-04-03 | C-12 | Areeba | areeba@x.com | B-1 | SQL Basics | Pearson | 1200.00 | 3 |
| O-503 | 2026-04-05 | C-11 | Bilal | bilal@x.com | B-3 | Networks | Pearson | 1800.00 | 1 |
| O-503 | 2026-04-05 | C-11 | Bilal | bilal@x.com | B-2 | Python 101 | OReilly | 1500.00 | 1 |

Redundancy is now *visible*, not gone: Bilal's name/email appears 3x, book B-2's details appear 2x — exactly the motivation for 2NF/3NF in Lab 06.

---

## Part B — Hospital Patient Visits (graded)

**Functional dependencies**
| FD | Meaning |
|---|---|
| `VisitID → VisitDate, PatientID, DoctorID, Diagnosis, Fee` | one visit = one date/patient/doctor/diagnosis/fee |
| `PatientID → PatientName, PatientPhone` | |
| `DoctorID → DoctorName, Specialty, DeptName` | |
| `DeptName → DeptHead` | |

Design notes: `Fee` is **not** doctor-determined (Dr. Imran charges 2500 and 3000 on different visits); `Diagnosis` belongs to the visit, not the patient (same patient, different diagnoses across visits).
**Candidate key:** `VisitID` alone — its closure reaches every attribute; no other column is unique per row.

**Table created — `Visit_1NF`** *(PK: `VisitID`)*

| VisitID | VisitDate | PatientID | PatientName | PatientPhone | DoctorID | DoctorName | Specialty | DeptName | DeptHead | Diagnosis | Fee |
|---|---|---|---|---|---|---|---|---|---|---|---|
| V-9001 | 2026-04-10 | P-201 | Hassan | 0300-1112233 | D-30 | Dr. Imran | Cardiology | Heart Care | Dr. Tariq | Hypertension | 2500 |
| V-9002 | 2026-04-10 | P-202 | Mehreen | 0301-4445566 | D-31 | Dr. Asma | Dermatology | Skin Clinic | Dr. Asma | Eczema | 2000 |
| V-9003 | 2026-04-11 | P-201 | Hassan | 0300-1112233 | D-31 | Dr. Asma | Dermatology | Skin Clinic | Dr. Asma | Allergy | 2000 |
| V-9004 | 2026-04-12 | P-203 | Junaid | 0302-7778899 | D-30 | Dr. Imran | Cardiology | Heart Care | Dr. Tariq | Arrhythmia | 3000 |

Every cell is already atomic and `VisitID` is unique per row, so this merge **is** 1NF as built. Redundancy still visible: Hassan appears 2x, Dr. Imran's details appear 2x — targeted next in Lab 06.

---

## Common mistakes to avoid (this stage)
- Treating a comma-separated string in one column as 1NF — it isn't; atomic means a single value per cell.
- Choosing a primary key by intuition instead of deriving it from the FDs and their closure.
- Assuming 1NF removes redundancy — it only removes repeating groups; the GROUP BY checks at the end of each part exist to prove redundancy is still there.

## Expected results
`OrderBook_1NF` → 5 rows | `Visit_1NF` → 4 rows

## Summary
Both parts now have a clean, atomic, uniquely-keyed 1NF table — but each still repeats customer/book (Part A) or patient/doctor/department (Part B) facts across multiple rows. `Lab06_Normalization_2NF_3NF.sql` picks up from here and removes that redundancy via 2NF and 3NF decomposition.
