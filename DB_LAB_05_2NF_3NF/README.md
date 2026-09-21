# Lab 06 — 2NF & 3NF Decomposition

**Course:** Database Systems | **Topic:** Database Normalization
**Tools:** MySQL 8.x (Workbench or Command Line Client)
**Script:** `Lab06_Normalization_2NF_3NF.sql`
**Continuation of Lab 05 — run Lab 05 first.** This script opens each part with a row-count sanity check against `OrderBook_1NF` / `Visit_1NF`.

## Learning objectives
- Refine a 1NF relation into 2NF by eliminating partial dependencies.
- Refine a 2NF relation into 3NF by eliminating transitive dependencies.
- Implement the decomposition in MySQL: tables, keys, foreign keys, and verification queries.

## Deliverables covered here (assessment marks in brackets)

| # | Requirement | Scenario |
|---|---|---|
| Task 3 | 2NF decomposition, keys stated | Bookstore (lab task) |
| Task 4 | 3NF decomposition, FKs implemented | Bookstore (lab task) |
| Task 5 | Verification queries (report + total spend) | Bookstore (lab task) |
| Task 6 | Written reflection + live anomaly demo | Bookstore (lab task) |
| Deliverable 3 (20) | 2NF schema + justification | Hospital (assessment) |
| Deliverable 4 (30) | 3NF schema, FKs, fully populated | Hospital (assessment) |
| Deliverable 5 (15) | Single SELECT recreating Table 8.1 | Hospital (assessment) |
| Deliverable 6 (10) | Anomalies eliminated, as comments | Hospital (assessment) |

Hospital assessment total: **75/100** here + **25/100** from Lab 05 (Deliverables 1–2) = 100.

## How to run
```bash
mysql -u root -p < Lab06_Normalization_2NF_3NF.sql
```
Re-runnable: drops dependent tables (children before parents) before rebuilding each part.

---

## Part A — Online Bookstore

### 2NF (Task 3)
PK of `OrderBook_1NF` is `(OrderID, BookID)`. Non-prime attributes split by what they actually depend on:

| Attribute(s) | Depends on | Verdict |
|---|---|---|
| `OrderDate, CustID, CustName, CustEmail` | `OrderID` only | partial → `Orders_2NF` |
| `BookTitle, Publisher, UnitPrice` | `BookID` only | partial → `Book_2NF` |
| `Qty` | full key | stays → `OrderItem_2NF` |

**`Orders_2NF`** (PK `OrderID`)

| OrderID | OrderDate | CustID | CustName | CustEmail |
|---|---|---|---|---|
| O-501 | 2026-04-02 | C-11 | Bilal | bilal@x.com |
| O-502 | 2026-04-03 | C-12 | Areeba | areeba@x.com |
| O-503 | 2026-04-05 | C-11 | Bilal | bilal@x.com |

**`Book_2NF`** (PK `BookID`)

| BookID | BookTitle | Publisher | UnitPrice |
|---|---|---|---|
| B-1 | SQL Basics | Pearson | 1200.00 |
| B-2 | Python 101 | OReilly | 1500.00 |
| B-3 | Networks | Pearson | 1800.00 |

**`OrderItem_2NF`** (PK `OrderID, BookID`, FK → both above)

| OrderID | BookID | Qty |
|---|---|---|
| O-501 | B-1 | 1 |
| O-501 | B-2 | 2 |
| O-502 | B-1 | 3 |
| O-503 | B-3 | 1 |
| O-503 | B-2 | 1 |

Still redundant: Bilal (`C-11`) repeats across `Orders_2NF` rows O-501/O-503 — a transitive dependency, fixed next.

### 3NF (Task 4)
Transitive: `OrderID → CustID → CustName, CustEmail`. Customer facts extracted out of `Orders_2NF`:
```
Customer  (CustID PK, CustName, CustEmail)
Orders    (OrderID PK, OrderDate, CustID FK → Customer)
Book, OrderItem   -- unchanged, already 3NF
```
*(Publisher stays as a plain column — no other publisher facts exist, so a separate table would over-normalize.)*

**`Customer`** (PK `CustID`)

| CustID | CustName | CustEmail |
|---|---|---|
| C-11 | Bilal | bilal@x.com |
| C-12 | Areeba | areeba@x.com |

**`Orders`** (PK `OrderID`, FK `CustID` → `Customer`)

| OrderID | OrderDate | CustID |
|---|---|---|
| O-501 | 2026-04-02 | C-11 |
| O-502 | 2026-04-03 | C-12 |
| O-503 | 2026-04-05 | C-11 |

`Book` and `OrderItem` carry over unchanged from their 2NF versions above; the `_2NF` tables are dropped once data is copied over.

### Verification (Task 5)
- **5(a)** `OrderItem ⋈ Orders ⋈ Customer ⋈ Book` reproduces the original 5-row report; lossless-join check confirms `rows_in_1NF = rows_from_3NF_join = 5`.
- **5(b)** Total spend per customer:

| CustID | CustName | total_spend |
|---|---|---|
| C-11 | Bilal | 7500.00 |
| C-12 | Areeba | 3600.00 |

### Reflection + live demo (Task 6)
In 3NF every fact is stored once, so all three Task-1 anomalies are gone: a new book/customer no longer needs an order; a shared fact (email, price) lives in one row so one `UPDATE` fixes it everywhere; deleting an order only removes rows from `Orders`/`OrderItem`, leaving the customer and book intact.

Proved live, inside `START TRANSACTION … ROLLBACK` (nothing persists):
1. **Insert** book `B-4` with zero orders — succeeds.
2. **Update** Bilal's email once in `Customer` — both his orders reflect it via the join.
3. **Delete** order `O-502` — `Areeba` and `B-1` both survive in their own tables.

---

## Part B — Hospital Patient Visits (graded)

### 2NF (Deliverable 3)
`Visit_1NF`'s key, `VisitID`, is a **single column** — a partial dependency needs a composite key to divide, so none can exist here. Every non-prime attribute already depends on the whole (only) key.

**Justification / conclusion:** `Visit_1NF` is already in 2NF — no table changes at this step; `Visit_2NF` is structurally identical to `Visit_1NF`. The script confirms the PK is single-column via `INFORMATION_SCHEMA.KEY_COLUMN_USAGE`.

### 3NF (Deliverable 4)
Transitive dependencies:

| Chain | Extracted table |
|---|---|
| `VisitID → PatientID → PatientName, PatientPhone` | `Patient` |
| `VisitID → DoctorID → DoctorName, Specialty, DeptName` | `Doctor` |
| `DoctorID → DeptName → DeptHead` | `Department` |

**`Patient`** (PK `PatientID`)

| PatientID | PatientName | PatientPhone |
|---|---|---|
| P-201 | Hassan | 0300-1112233 |
| P-202 | Mehreen | 0301-4445566 |
| P-203 | Junaid | 0302-7778899 |

**`Department`** (PK `DeptName`)

| DeptName | DeptHead |
|---|---|
| Heart Care | Dr. Tariq |
| Skin Clinic | Dr. Asma |

**`Doctor`** (PK `DoctorID`, FK `DeptName` → `Department`)

| DoctorID | DoctorName | Specialty | DeptName |
|---|---|---|---|
| D-30 | Dr. Imran | Cardiology | Heart Care |
| D-31 | Dr. Asma | Dermatology | Skin Clinic |

**`Visit`** (PK `VisitID`, FK `PatientID` → `Patient`, FK `DoctorID` → `Doctor`)

| VisitID | VisitDate | PatientID | DoctorID | Diagnosis | Fee |
|---|---|---|---|---|---|
| V-9001 | 2026-04-10 | P-201 | D-30 | Hypertension | 2500 |
| V-9002 | 2026-04-10 | P-202 | D-31 | Eczema | 2000 |
| V-9003 | 2026-04-11 | P-201 | D-31 | Allergy | 2000 |
| V-9004 | 2026-04-12 | P-203 | D-30 | Arrhythmia | 3000 |

*(`DeptName` used as Department's key — no separate ID exists and names are unique; `DeptHead` kept as text since heads aren't necessarily in `Doctor`.)*

### Recreate the report (Deliverable 5)
`Visit ⋈ Patient ⋈ Doctor ⋈ Department` reproduces the original 4-row Table 8.1 exactly; lossless-join check confirms `rows_in_1NF = rows_from_3NF_join = 4`.

### Anomalies eliminated (Deliverable 6)

| Anomaly | Before (flat table) | After (3NF) |
|---|---|---|
| Insertion | can't add a doctor/dept/patient without a visit | each is its own table, independent of `Visit` |
| Update | a shared fact repeats across every visit row | one row per fact — one `UPDATE` fixes it everywhere |
| Deletion | deleting a patient's only visit erases the patient | `Visit` row deleted, `Patient`/`Doctor`/`Department` untouched; `ON DELETE RESTRICT` also blocks deleting a still-referenced row |

---

## Final schema at a glance

**Bookstore (`bookstore_db`):**
```
Customer(CustID PK, CustName, CustEmail)
   └── Orders(OrderID PK, OrderDate, CustID FK)
          └── OrderItem(OrderID FK, BookID FK, Qty)  PK(OrderID, BookID)
                 └── Book(BookID PK, BookTitle, Publisher, UnitPrice)
```
**Hospital (`hospital_db`):**
```
Department(DeptName PK, DeptHead)
   └── Doctor(DoctorID PK, DoctorName, Specialty, DeptName FK)
Patient(PatientID PK, PatientName, PatientPhone)
Visit(VisitID PK, VisitDate, PatientID FK, DoctorID FK, Diagnosis, Fee)
```
Both satisfy 3NF: every non-key attribute depends on the key, the whole key, and nothing but the key.

## Common mistakes to avoid
- Forgetting foreign keys after decomposition — the schema is logically split but referential integrity isn't enforced without them.
- Stopping at 2NF when a transitive dependency still exists (Orders_2NF → Customer was the case here).
- Over-normalizing a small, unchanging lookup like `Publisher` — deliberately not split out in this design.

## Submission (per lab manual, Hospital assessment)
Push a single `RollNo_Normalization.sql` (containing all CREATE/INSERT/SELECT statements from both labs, commented `-- 1NF` / `-- 2NF` / `-- 3NF`) to your GitHub repo, in a folder named `Lab-Normalization/`, and share the folder link before the deadline.

## Expected row counts
`Customer`=2 · `Orders`=3 · `Book`=3 · `OrderItem`=5 · `Patient`=3 · `Department`=2 · `Doctor`=2 · `Visit`=4 · `orders_after_rollback`=3
