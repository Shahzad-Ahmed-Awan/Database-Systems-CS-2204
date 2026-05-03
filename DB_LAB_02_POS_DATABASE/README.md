<div align="center">

# 🛒 POS Database — Lab 02

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-10.4-003545?style=flat-square&logo=mariadb&logoColor=white)
![XAMPP](https://img.shields.io/badge/XAMPP-Stack-FB7A24?style=flat-square&logo=xampp&logoColor=white)
![Status](https://img.shields.io/badge/Lab-Completed_✓-brightgreen?style=flat-square)

**Shahzad Ahmed Awan** · `2024-SE-15` · CS-2204 Database Systems · UAJK Muzaffarabad

</div>

---

## What It Is

A fully relational **Point of Sale** database (`pos_system`) built in MySQL — covering schema design, data population, FK enforcement, and business reporting.

**13 tables · 162 rows · 14 foreign keys · 8 reporting queries**

---

## Files

| File | Purpose |
|---|---|
| `Pos_System_DB_Schema.sql` | All `CREATE TABLE` + `INSERT` statements. **Import this once** to get the full database live. |
| `Report_Generation_Queries.sql` | 8 `SELECT` queries for business intelligence. Run on demand after import. Kept separate so they can be reused without touching the schema. |
| `DB_LAB_02.pdf / .docx` | Lab report with screenshots of table structures, ER diagram, and query output. |

---

## Schema

| Domain | Tables |
|---|---|
| 👥 Users & Access | `roles`, `users` |
| 🏷️ Product Catalogue | `categories`, `suppliers`, `products`, `discounts` |
| 📦 Inventory | `stock_status`, `inventory` |
| 💳 Sales & Payments | `order_status`, `orders`, `order_items`, `payment_methods`, `payments` |

All FKs use `ON UPDATE CASCADE`. Delete is `RESTRICT` on most tables; `CASCADE` on `order_items` and `payments` (child rows follow their parent order).

---

## Setup

```
1. Start XAMPP → Apache + MySQL
2. Open http://localhost/phpmyadmin
3. Create database → name: pos_system · collation: utf8mb4_general_ci
4. Select pos_system → Import → Pos_System_DB_Schema.sql → Go
5. Verify: 13 tables, 162 rows ✓
```

**Run reports:** `pos_system` → SQL tab → paste from `Report_Generation_Queries.sql` → Go

---

## Reports

| # | Report | What It Answers |
|---|---|---|
| 1 | Full order summary | Every order — customer, status, discount |
| 2 | Itemised receipt | Products per order with qty & price |
| 3 | Revenue per customer | Top spenders + order count |
| 4 | Revenue by category | Which category earns most |
| 5 | Inventory status | Available stock per product |
| 6 | Payment summary | Total paid, balance due, methods used |
| 7 | Active discounts | Live promo codes and their scope |
| 8 | Best-selling products | Top products by units sold & revenue |

---

## Design Notes

- `price_at_purchase` on `order_items` — preserves historical accuracy when product prices change.
- Nullable `discount_id` on `orders` — no discount = `NULL`, not a dummy row.
- Multiple `payments` rows per order — supports split cash + card transactions.
- `available_stock = quantity_on_hand − reserved_quantity` — accurate real-time figure.
- `InnoDB` engine — required for FK constraint enforcement in MySQL.

---

## Objectives ✅

- [x] 13 tables with correct types, constraints, and FK relationships
- [x] Minimum 10 records per table
- [x] Referential integrity verified (invalid deletes raise constraint errors)
- [x] 8 reporting queries executed successfully
- [x] ER diagram confirmed in phpMyAdmin Designer

---

<div align="center">
<sub>Made by <strong>Shahzad Ahmed Awan</strong> · 2024-SE-15 · CS-2204 · UAJK Dept. of Software Engineering</sub>
</div>